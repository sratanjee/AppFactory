import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnalyticsDemoScreen extends ConsumerStatefulWidget {
  const AnalyticsDemoScreen({super.key});

  @override
  ConsumerState<AnalyticsDemoScreen> createState() =>
      _AnalyticsDemoScreenState();
}

class _AnalyticsDemoScreenState extends ConsumerState<AnalyticsDemoScreen> {
  int _stepCounter = 0;

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final analytics = ref.read(analyticsProvider);
    // The example app is a test surface; recording buffer is meant to be
    // visible here for demo purposes.
    // ignore: invalid_use_of_visible_for_testing_member
    final events = analytics.recordedEvents;

    return AdaptiveScaffold(
      title: const Text('Analytics'),
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: AdaptiveIcon(AdaptiveIconName.chevronLeft, size: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                'Analytics.testing() records in memory. Fire an event, then '
                'the list below updates.',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AdaptiveSecondaryButton(
                    label: 'Onboarding step',
                    onPressed: () {
                      analytics.trackOnboardingStep(step: _stepCounter++);
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AdaptiveSecondaryButton(
                    label: 'Paywall view',
                    onPressed: () {
                      analytics.trackPaywallView(placement: 'demo');
                      _refresh();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AdaptiveSecondaryButton(
                    label: 'Purchase',
                    onPressed: () {
                      analytics.trackPaywallPurchase(
                        sku: 'annual',
                        price: r'$49.99',
                      );
                      _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AdaptiveSecondaryButton(
                    label: 'Core action',
                    onPressed: () {
                      analytics.trackCoreAction(
                        properties: {'kind': 'demo'},
                      );
                      _refresh();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AdaptiveSecondaryButton(
              label: 'Widget added',
              onPressed: () {
                analytics.trackWidgetAdded(
                  surface: 'home_widget',
                  size: 'medium',
                );
                _refresh();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: events.isEmpty
                  ? const Center(child: Text('No events yet.'))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (_, i) {
                        final e = events[events.length - 1 - i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text('${e.name}  ${e.properties}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      primaryAction: AdaptiveDestructiveButton(
        label: 'Clear buffer',
        onPressed: () {
          // Same demo-surface exemption as recordedEvents above.
          // ignore: invalid_use_of_visible_for_testing_member
          analytics.clearRecorded();
          _refresh();
        },
      ),
    );
  }
}
