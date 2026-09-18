/// Per-app paywall configuration. Provided at boot via
/// `paywallConfigProvider.overrideWithValue(...)` in
/// `AdaptiveApp.riverpodOverrides`.
///
/// Benefits and Terms/Privacy URLs live here rather than in RevenueCat
/// metadata so an app can change paywall copy without a round-trip to the
/// RC dashboard.
class PaywallConfig {
  const PaywallConfig({
    required this.iosApiKey,
    required this.androidApiKey,
    this.entitlementId = 'pro',
    this.offeringId,
    this.termsUrl,
    this.privacyUrl,
    this.benefits = const [],
    this.smallPrint,
  });

  /// No-op mode. Apps use this when a real RevenueCat project isn't wired
  /// yet. `Paywall.hasEntitlement()` returns `false`, `present()` returns
  /// `PaywallResult.notPresented`, no network is touched.
  const PaywallConfig.disabled()
      : this(iosApiKey: '', androidApiKey: '');

  /// RevenueCat iOS project public key.
  final String iosApiKey;

  /// RevenueCat Android project public key.
  final String androidApiKey;

  /// The entitlement ID checked on `CustomerInfo`. Convention: `pro`.
  final String entitlementId;

  /// If null, RevenueCat's current default offering is used. Set when the
  /// app runs multiple offerings and wants to lock to a specific one.
  final String? offeringId;

  /// Terms of Service URL rendered as a small link at the bottom of the
  /// paywall.
  final Uri? termsUrl;

  /// Privacy Policy URL rendered as a small link at the bottom of the
  /// paywall.
  final Uri? privacyUrl;

  /// Three lines of benefit copy in the user's words (spec §6). More than
  /// three is a warning; fewer is fine.
  final List<String> benefits;

  /// Optional compliance / safety footer rendered above the primary button.
  /// Health-adjacent SKUs use this for Apple 1.4.2 disclaimers ("Talk to
  /// your vet before changing any medication."). Kept out of `benefits` so
  /// it renders in muted grey and never reads as a sales point.
  final String? smallPrint;

  bool get isDisabled => iosApiKey.isEmpty && androidApiKey.isEmpty;
}
