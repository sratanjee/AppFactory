import 'package:factory_core/factory_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveScaffold(
      body: const AdaptiveLoading(),
      primaryAction: AdaptivePrimaryButton(
        label: 'Continue',
        onPressed: () => context.go('/home'),
      ),
    );
  }
}
