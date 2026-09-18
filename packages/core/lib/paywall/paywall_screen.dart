import 'dart:async';

import 'package:factory_core/adaptive/adaptive.dart';
import 'package:factory_core/l10n/l10n.dart';
import 'package:factory_core/paywall/paywall_client.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen paywall UI. Present via [PaywallScreen.show] (or
/// `paywall.present(context, placement: ...)` on the facade, which
/// delegates here).
///
/// Renders:
///   * Delayed-visible top-left X close button (2s hidden per Apple's
///     "reachable within 2s" rule; symmetric on Android).
///   * Benefit list from `paywall.config.benefits`.
///   * Plan picker with `offering.defaultPackageId` pre-selected;
///     per-plan `savingString` on the right.
///   * `AdaptivePrimaryButton` — `Start free trial` when the selected
///     package has a trial, otherwise `Continue`.
///   * Footer row: Restore · Terms · Privacy (last two only when the
///     matching URL is set on the config).
///
/// Analytics: fires `trackPaywallView(placement:)` on init; RC's
/// `Paywall.purchase` fires `trackPaywallPurchase` on success.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    required this.paywall,
    required this.offering,
    required this.placement,
    super.key,
  });

  final Paywall paywall;
  final PaywallOffering offering;
  final String placement;

  /// Fetch the current offering, push the paywall full-screen, return the
  /// [PaywallResult]. Fetches use root navigator so the paywall isn't
  /// nested inside a tab's inner navigator.
  static Future<PaywallResult> show(
    BuildContext context, {
    required Paywall paywall,
    required String placement,
  }) async {
    final offering = await paywall.fetchOffering();
    if (offering == null) return PaywallResult.error;
    if (!context.mounted) return PaywallResult.error;

    Widget builder(BuildContext _) => PaywallScreen(
          paywall: paywall,
          offering: offering,
          placement: placement,
        );
    final settings = RouteSettings(name: 'paywall/$placement');
    final route = AdaptivePlatform.isIOS
        ? CupertinoPageRoute<PaywallResult>(
            fullscreenDialog: true,
            settings: settings,
            builder: builder,
          )
        : MaterialPageRoute<PaywallResult>(
            fullscreenDialog: true,
            settings: settings,
            builder: builder,
          );
    final result = await Navigator.of(context, rootNavigator: true)
        .push<PaywallResult>(route);
    return result ?? PaywallResult.dismissed;
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late String _selectedId;
  bool _closeVisible = false;
  bool _busy = false;
  String? _error;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.offering.defaultPackageId;
    widget.paywall.analytics.trackPaywallView(placement: widget.placement);
    _closeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _closeVisible = true);
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    final pkg = widget.offering.packageForId(_selectedId);
    if (pkg == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.paywall.purchase(pkg);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == PaywallResult.purchased) {
      Navigator.of(context).pop(PaywallResult.purchased);
    } else if (result == PaywallResult.error) {
      setState(() {
        _error = context.maybeL10n?.paywallErrorPurchaseFailed ??
            'Purchase failed. Try again.';
      });
    }
  }

  Future<void> _handleRestore() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.paywall.restore();
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == PaywallResult.restored) {
      Navigator.of(context).pop(PaywallResult.restored);
    } else if (result == PaywallResult.error) {
      setState(() {
        _error = context.maybeL10n?.paywallErrorRestoreFailed ??
            'Restore failed. Try again.';
      });
    }
  }

  Future<void> _launchUrl(Uri url) async {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final config = widget.paywall.config;
    final selected = widget.offering.packageForId(_selectedId) ??
        widget.offering.packages.first;
    final buttonLabel = selected.hasFreeTrial
        ? (context.maybeL10n?.buttonStartFreeTrial ?? 'Start free trial')
        : (context.maybeL10n?.buttonContinue ?? 'Continue');

    return AdaptiveScaffold(
      titleDisplay: TitleDisplay.none,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 44,
            child: _closeVisible
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: theme.spacing.sm),
                      child: GestureDetector(
                        key: const ValueKey('paywall_close'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context)
                            .pop(PaywallResult.dismissed),
                        child: const AdaptiveIcon(
                          AdaptiveIconName.xmark,
                          size: 22,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: theme.spacing.xl),
                  for (final benefit in config.benefits) ...[
                    Text(
                      benefit,
                      style: const TextStyle(fontSize: 18, height: 1.4),
                    ),
                    SizedBox(height: theme.spacing.md),
                  ],
                  SizedBox(height: theme.spacing.lg),
                  for (final pkg in widget.offering.packages)
                    _PlanRow(
                      package: pkg,
                      selected: pkg.identifier == _selectedId,
                      accent: theme.accent,
                      onTap: () =>
                          setState(() => _selectedId = pkg.identifier),
                    ),
                  if (config.smallPrint != null) ...[
                    SizedBox(height: theme.spacing.md),
                    Text(
                      config.smallPrint!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E6E73),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_error != null) ...[
                    SizedBox(height: theme.spacing.md),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFB3261E),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.lg,
              vertical: theme.spacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FooterButton(
                  label: context.maybeL10n?.buttonRestorePurchases ??
                      'Restore purchases',
                  onTap: _handleRestore,
                ),
                if (config.termsUrl != null)
                  _FooterButton(
                    label: context.maybeL10n?.buttonTerms ?? 'Terms',
                    onTap: () => _launchUrl(config.termsUrl!),
                  ),
                if (config.privacyUrl != null)
                  _FooterButton(
                    label: context.maybeL10n?.buttonPrivacy ?? 'Privacy',
                    onTap: () => _launchUrl(config.privacyUrl!),
                  ),
              ],
            ),
          ),
        ],
      ),
      primaryAction: AdaptivePrimaryButton(
        label: buttonLabel,
        onPressed: _handlePurchase,
        isLoading: _busy,
        enabled: !_busy,
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.package,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final PaywallPackage package;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: theme.spacing.md),
        padding: EdgeInsets.all(theme.spacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? accent : accent.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(theme.cornerRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('${package.priceString} / ${package.period}'),
                ],
              ),
            ),
            if (package.savingString != null)
              Padding(
                padding: EdgeInsets.only(right: theme.spacing.sm),
                child: Text(
                  package.savingString!,
                  style: TextStyle(color: accent, fontSize: 14),
                ),
              ),
            _RadioIndicator(selected: selected, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected, required this.accent});

  final bool selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent, width: 2),
        color: selected ? accent : null,
      ),
      child: selected
          ? const AdaptiveIcon(
              AdaptiveIconName.check,
              size: 12,
              color: Color(0xFFFFFFFF),
            )
          : null,
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
