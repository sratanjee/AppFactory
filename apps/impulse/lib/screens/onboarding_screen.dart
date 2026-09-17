import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingFlow(
      steps: const [
        OnboardingStep(build: _step1),
        OnboardingStep(build: _step2),
        OnboardingStep(build: _step3),
      ],
      onComplete: (_) async {
        // Present paywall, then mark onboarding complete regardless of
        // whether the user purchased or dismissed.
        final paywall = ref.read(paywallProvider);
        if (context.mounted) {
          await PaywallScreen.show(
            context,
            paywall: paywall,
            placement: 'after_onboarding',
          );
        }
        final kv = await ref.read(keyValueStoreProvider.future);
        await kv.setBool('hasSeenOnboarding', true);
        if (context.mounted) context.go('/home');
      },
    );
  }
}

Widget _step1(BuildContext context, OnboardingStepContext sc) {
  return const _PromiseStep(
    headline: 'Wanting and paying happen in the same moment.',
    body: 'Impulse puts 48 hours between them.',
  );
}

Widget _step2(BuildContext context, OnboardingStepContext sc) {
  return const _PromiseStep(
    headline: 'Add the thing. Wait. Then decide.',
    body: '',
  );
}

Widget _step3(BuildContext context, OnboardingStepContext sc) {
  return const _PromiseStep(
    headline: 'Every skipped item adds up.',
    body: 'Watch the number grow.',
    sample: r'$1,240',
  );
}

class _PromiseStep extends StatelessWidget {
  const _PromiseStep({
    required this.headline,
    required this.body,
    this.sample,
  });

  final String headline;
  final String body;
  final String? sample;

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sample != null) ...[
            Text(
              sample!,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: theme.accent,
              ),
            ),
            SizedBox(height: theme.spacing.xl),
          ],
          Text(
            headline,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (body.isNotEmpty) ...[
            SizedBox(height: theme.spacing.md),
            Text(body, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
