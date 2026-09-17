import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaywallDemoScreen extends ConsumerStatefulWidget {
  const PaywallDemoScreen({super.key});

  @override
  ConsumerState<PaywallDemoScreen> createState() => _PaywallDemoScreenState();
}

class _PaywallDemoScreenState extends ConsumerState<PaywallDemoScreen> {
  PaywallResult? _lastResult;

  Future<void> _present() async {
    final paywall = ref.read(paywallProvider);
    final offering = await paywall.fetchOffering();
    if (offering == null || !mounted) return;
    final result = await PaywallScreen.show(
      context,
      paywall: paywall,
      placement: 'demo',
    );
    if (!mounted) return;
    setState(() => _lastResult = result);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Paywall'),
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: AdaptiveIcon(AdaptiveIconName.chevronLeft, size: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Presents PaywallScreen against a fake RevenueCat offering '
              '(no keys wired). The close button appears after 2s. '
              'trackPaywallView fires on the analytics testing buffer.',
            ),
            const SizedBox(height: 24),
            if (_lastResult != null)
              Text('Last result: ${_lastResult!.name}'),
          ],
        ),
      ),
      primaryAction: AdaptivePrimaryButton(
        label: 'Present paywall',
        onPressed: _present,
      ),
    );
  }
}
