import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class OnboardingDemoScreen extends StatefulWidget {
  const OnboardingDemoScreen({super.key});

  @override
  State<OnboardingDemoScreen> createState() => _OnboardingDemoScreenState();
}

class _OnboardingDemoScreenState extends State<OnboardingDemoScreen> {
  Map<String, Object?>? _lastAnswers;
  bool _running = false;

  void _start() {
    setState(() => _running = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_running) {
      return OnboardingFlow(
        onComplete: (answers) {
          setState(() {
            _running = false;
            _lastAnswers = answers;
          });
        },
        onCancel: () {
          setState(() => _running = false);
        },
        steps: [
          const OnboardingStep(
            build: _buildPromise,
          ),
          OnboardingStep(
            build: (_, sc) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'What matters most?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  AdaptiveSecondaryButton(
                    label: 'Consistency',
                    onPressed: () {
                      sc
                        ..answer('goal', 'consistency')
                        ..advance();
                    },
                  ),
                  const SizedBox(height: 12),
                  AdaptiveSecondaryButton(
                    label: 'Novelty',
                    onPressed: () {
                      sc
                        ..answer('goal', 'novelty')
                        ..advance();
                    },
                  ),
                ],
              ),
            ),
          ),
          const OnboardingStep(
            build: _buildPermission,
          ),
        ],
      );
    }

    return AdaptiveScaffold(
      title: const Text('Onboarding'),
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
              'A three-step OnboardingFlow: a promise, a single-question '
              'picker, and a permission prompt.',
            ),
            const SizedBox(height: 24),
            if (_lastAnswers != null) ...[
              const Text(
                'Last run answers',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(_lastAnswers.toString()),
            ],
          ],
        ),
      ),
      primaryAction: AdaptivePrimaryButton(
        label: 'Start onboarding',
        onPressed: _start,
      ),
    );
  }
}

Widget _buildPromise(BuildContext context, OnboardingStepContext sc) {
  return const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Count every drink.',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'This is a one-line promise.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildPermission(BuildContext context, OnboardingStepContext sc) {
  return const PermissionPromptCard(
    icon: AdaptiveIconName.bell,
    title: 'One reminder each evening',
    body: 'At the time you set. No spam.',
  );
}
