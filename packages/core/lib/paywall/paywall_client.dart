import 'dart:async';

import 'package:factory_core/analytics/analytics_client.dart';
import 'package:factory_core/paywall/paywall_config.dart';
import 'package:factory_core/paywall/paywall_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

/// Outcome of a paywall interaction.
enum PaywallResult {
  purchased,
  restored,
  dismissed,
  notPresented,
  error,
}

/// A subscription plan surfaced by the paywall. Wraps RevenueCat's `Package`
/// so callers depend only on `factory_core`.
@immutable
class PaywallPackage {
  const PaywallPackage({
    required this.identifier,
    required this.title,
    required this.priceString,
    required this.period,
    this.savingString,
    this.freeTrialDays,
  });

  /// Stable identifier from RC (e.g. `annual`, `weekly`, `lifetime`).
  final String identifier;

  /// Human title shown in the plan picker (e.g. `Annual`, `Weekly`).
  final String title;

  /// Localised price string exactly as returned by the store
  /// (e.g. `$49.99`). Do not format client-side.
  final String priceString;

  /// One of `week`, `month`, `year`, `lifetime`.
  final String period;

  /// Optional discount hint shown next to non-default packages
  /// (e.g. `Save 60%`).
  final String? savingString;

  /// Free trial length in days, or null if the package has no trial.
  final int? freeTrialDays;

  bool get hasFreeTrial => freeTrialDays != null && freeTrialDays! > 0;
}

/// A single RevenueCat offering the paywall can present.
@immutable
class PaywallOffering {
  const PaywallOffering({
    required this.packages,
    required this.defaultPackageId,
  });

  final List<PaywallPackage> packages;

  /// Which package is pre-selected in the paywall UI. Convention: annual.
  final String defaultPackageId;

  PaywallPackage? packageForId(String id) {
    for (final p in packages) {
      if (p.identifier == id) return p;
    }
    return null;
  }
}

/// The factory's paywall facade. All apps consume it through
/// `paywallProvider`; direct construction is only for tests.
///
/// Track calls delegate to [Analytics] for `paywall_view` (fired from
/// `PaywallScreen.initState`) and `paywall_purchase` (fired from the screen
/// on successful purchase, so bare `Paywall.restore()` doesn't count as a
/// purchase).
class Paywall {
  factory Paywall({
    required PaywallConfig config,
    required Analytics analytics,
  }) =>
      Paywall._(config: config, analytics: analytics);

  Paywall._({
    required PaywallConfig config,
    required Analytics analytics,
    PaywallOffering? testOffering,
    PaywallResult? testNextPresentResult,
  })  : _config = config,
        _analytics = analytics,
        _testOffering = testOffering,
        _testNextPresentResult = testNextPresentResult;

  factory Paywall.disabled() => Paywall._(
        config: const PaywallConfig.disabled(),
        analytics: Analytics.disabled(),
      );

  /// Testing mode. Never touches RC. `fetchOffering()` returns `offering`.
  /// `present()`/`presentIfNotEntitled()` return `nextPresentResult` (or
  /// `PaywallResult.dismissed` by default) without rendering UI.
  ///
  /// Widget tests that need to render `PaywallScreen` with real benefit
  /// copy / URLs can pass a [config]; supplying [analytics] lets the test
  /// inspect the same instance the widget calls
  /// `trackPaywallView`/`trackPaywallPurchase` against.
  factory Paywall.testing({
    PaywallConfig? config,
    Analytics? analytics,
    PaywallOffering? offering,
    PaywallResult nextPresentResult = PaywallResult.dismissed,
  }) =>
      Paywall._(
        config: config ?? const PaywallConfig.disabled(),
        analytics: analytics ?? Analytics.testing(),
        testOffering: offering,
        testNextPresentResult: nextPresentResult,
      );

  final PaywallConfig _config;
  final Analytics _analytics;
  final PaywallOffering? _testOffering;
  final PaywallResult? _testNextPresentResult;

  Future<void>? _initFuture;
  final StreamController<bool> _entitlementController =
      StreamController<bool>.broadcast();
  bool _lastEntitlement = false;
  bool _listenerAttached = false;

  bool get _isReal => !_config.isDisabled && _testOffering == null;

  // ---- Lifecycle --------------------------------------------------------

  /// Configures the RevenueCat SDK. Idempotent — safe to call multiple
  /// times, only the first triggers real setup. Uses
  /// `analytics.distinctId()` (PostHog's anonymous or identified id) as
  /// RC's `appUserID` so the two systems share an id from install.
  Future<void> initialize() {
    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    if (!_isReal) return;
    try {
      final distinctId = await _analytics.distinctId();
      final apiKey = defaultTargetPlatform == TargetPlatform.iOS
          ? _config.iosApiKey
          : _config.androidApiKey;
      if (apiKey.isEmpty) return;
      final purchasesConfig = rc.PurchasesConfiguration(apiKey);
      if (distinctId != null && distinctId.isNotEmpty) {
        purchasesConfig.appUserID = distinctId;
      }
      await rc.Purchases.configure(purchasesConfig);
      _attachEntitlementListener();
    } on Object catch (e, st) {
      _warn('initialize failed', e, st);
    }
  }

  void _attachEntitlementListener() {
    if (_listenerAttached) return;
    _listenerAttached = true;
    rc.Purchases.addCustomerInfoUpdateListener((info) {
      final active = info.entitlements.active.containsKey(_config.entitlementId);
      if (active != _lastEntitlement) {
        _lastEntitlement = active;
        _entitlementController.add(active);
      }
    });
  }

  // ---- Entitlement -----------------------------------------------------

  Future<bool> hasEntitlement() async {
    if (!_isReal) return false;
    try {
      await initialize();
      final info = await rc.Purchases.getCustomerInfo();
      final active = info.entitlements.active.containsKey(_config.entitlementId);
      _lastEntitlement = active;
      return active;
    } on Object catch (e, st) {
      _warn('hasEntitlement failed', e, st);
      return false;
    }
  }

  /// Emits the current entitlement state and updates it every time RC's
  /// customer info changes. Emits `false` immediately in disabled/testing
  /// mode.
  Stream<bool> watchEntitlement() async* {
    yield await hasEntitlement();
    yield* _entitlementController.stream;
  }

  // ---- Offerings --------------------------------------------------------

  Future<PaywallOffering?> fetchOffering() async {
    if (_testOffering != null) return _testOffering;
    if (!_isReal) return null;
    try {
      await initialize();
      final offerings = await rc.Purchases.getOfferings();
      final offering = _config.offeringId != null
          ? offerings.all[_config.offeringId]
          : offerings.current;
      if (offering == null) return null;
      return _mapOffering(offering);
    } on Object catch (e, st) {
      _warn('fetchOffering failed', e, st);
      return null;
    }
  }

  PaywallOffering _mapOffering(rc.Offering offering) {
    final packages = offering.availablePackages.map(_mapPackage).toList();
    final defaultId = packages
            .cast<PaywallPackage?>()
            .firstWhere(
              (p) => p!.identifier == 'annual' || p.period == 'year',
              orElse: () => packages.isNotEmpty ? packages.first : null,
            )
            ?.identifier ??
        (packages.isNotEmpty ? packages.first.identifier : '');
    return PaywallOffering(packages: packages, defaultPackageId: defaultId);
  }

  PaywallPackage _mapPackage(rc.Package pkg) {
    return PaywallPackage(
      identifier: pkg.identifier,
      title: pkg.storeProduct.title,
      priceString: pkg.storeProduct.priceString,
      period: _periodFromPackageType(pkg.packageType),
      freeTrialDays: _freeTrialDaysFromProduct(pkg.storeProduct),
    );
  }

  String _periodFromPackageType(rc.PackageType t) {
    switch (t) {
      case rc.PackageType.weekly:
        return 'week';
      case rc.PackageType.monthly:
        return 'month';
      case rc.PackageType.twoMonth:
      case rc.PackageType.threeMonth:
      case rc.PackageType.sixMonth:
        return 'month';
      case rc.PackageType.annual:
        return 'year';
      case rc.PackageType.lifetime:
        return 'lifetime';
      case rc.PackageType.custom:
      case rc.PackageType.unknown:
        return 'month';
    }
  }

  int? _freeTrialDaysFromProduct(rc.StoreProduct product) {
    final intro = product.introductoryPrice;
    if (intro == null || intro.price != 0) return null;
    // periodNumberOfUnits + periodUnit — approximate to days.
    final n = intro.periodNumberOfUnits;
    switch (intro.periodUnit) {
      case rc.PeriodUnit.day:
        return n;
      case rc.PeriodUnit.week:
        return n * 7;
      case rc.PeriodUnit.month:
        return n * 30;
      case rc.PeriodUnit.year:
        return n * 365;
      case rc.PeriodUnit.unknown:
        return null;
    }
  }

  // ---- Presentation (facade) ------------------------------------------

  /// Present the paywall as a full-screen route. The [placement] string is
  /// recorded on the `paywall_view` analytics event.
  Future<PaywallResult> present(
    BuildContext context, {
    required String placement,
  }) async {
    if (_testNextPresentResult != null) return _testNextPresentResult;
    if (!_isReal) return PaywallResult.notPresented;
    return await PaywallScreen.show(
      context,
      paywall: this,
      placement: placement,
    );
  }

  Future<PaywallResult> presentIfNotEntitled(
    BuildContext context, {
    required String placement,
  }) async {
    if (await hasEntitlement()) return PaywallResult.notPresented;
    if (!context.mounted) return PaywallResult.notPresented;
    return await present(context, placement: placement);
  }

  // ---- Restore ---------------------------------------------------------

  /// Restore purchases without presenting UI. Fires no `paywall_purchase`
  /// analytics event (restores don't count as new purchases in the funnel).
  Future<PaywallResult> restore() async {
    if (!_isReal) return PaywallResult.notPresented;
    try {
      await initialize();
      final info = await rc.Purchases.restorePurchases();
      final active = info.entitlements.active.containsKey(_config.entitlementId);
      _lastEntitlement = active;
      _entitlementController.add(active);
      return active ? PaywallResult.restored : PaywallResult.dismissed;
    } on Object catch (e, st) {
      _warn('restore failed', e, st);
      return PaywallResult.error;
    }
  }

  /// Purchase a package. Called by `PaywallScreen`; fires
  /// `analytics.trackPaywallPurchase` on success. Returns whether the
  /// entitlement is now active.
  Future<PaywallResult> purchase(PaywallPackage pkg) async {
    if (!_isReal) return PaywallResult.error;
    try {
      await initialize();
      final offerings = await rc.Purchases.getOfferings();
      final offering = _config.offeringId != null
          ? offerings.all[_config.offeringId]
          : offerings.current;
      if (offering == null) return PaywallResult.error;
      final rcPackage = offering.availablePackages
          .cast<rc.Package?>()
          .firstWhere(
            (p) => p!.identifier == pkg.identifier,
            orElse: () => null,
          );
      if (rcPackage == null) return PaywallResult.error;
      final result = await rc.Purchases.purchase(
        rc.PurchaseParams.package(rcPackage),
      );
      final active = result.customerInfo.entitlements.active
          .containsKey(_config.entitlementId);
      if (active) {
        _analytics.trackPaywallPurchase(
          sku: pkg.identifier,
          price: pkg.priceString,
        );
        _lastEntitlement = active;
        _entitlementController.add(active);
        return PaywallResult.purchased;
      }
      return PaywallResult.error;
    } on Object catch (e, st) {
      _warn('purchase failed', e, st);
      return PaywallResult.error;
    }
  }

  Analytics get analytics => _analytics;
  PaywallConfig get config => _config;

  void _warn(String label, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('⚠️  [factory_core/paywall] $label: $error');
    }
  }
}
