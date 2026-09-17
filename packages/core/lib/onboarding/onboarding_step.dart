import 'package:flutter/widgets.dart';

/// One screen inside an `OnboardingFlow`.
///
/// The step's [build] callback renders the content; it receives an
/// [OnboardingStepContext] the step can use to record answers, toggle its
/// can-advance state, or advance programmatically.
class OnboardingStep {
  const OnboardingStep({
    required this.build,
    this.primaryActionLabel,
    this.canAdvance = true,
    this.onPrimary,
  });

  /// Renders the step's content. Called every time the flow rebuilds.
  final Widget Function(BuildContext, OnboardingStepContext) build;

  /// Overrides the bottom-anchored primary button label. Default is
  /// `FactoryLocalizations.buttonContinue`, or `buttonGetStarted` on the
  /// terminal step (with English fallbacks when no `Localizations` ancestor).
  final String? primaryActionLabel;

  /// Initial value for `canAdvance`. Steps requiring user input first should
  /// set `false` and call `ctx.setCanAdvance(canAdvance: true)` once the
  /// input is complete.
  final bool canAdvance;

  /// Custom primary-button action. Return `true` to advance to the next
  /// step, `false` to stay. When null, the button just advances. Use for
  /// permission-request steps that need to await a system prompt.
  final Future<bool> Function(OnboardingStepContext ctx)? onPrimary;
}

/// Handle passed to [OnboardingStep.build] and [OnboardingStep.onPrimary].
abstract class OnboardingStepContext {
  /// Zero-based index of the current step.
  int get index;

  /// Total step count.
  int get total;

  /// Records an answer into the flow's accumulated map. Delivered to
  /// `OnboardingFlow.onComplete`. Call as many times as needed; last write
  /// per key wins.
  void answer(String key, Object? value);

  /// Enables or disables the bottom primary button. Only takes effect from
  /// outside `build` (i.e. from event handlers) — calling during build
  /// triggers a setState-during-build error.
  void setCanAdvance({required bool canAdvance});

  /// Advances to the next step, bypassing `canAdvance` and `onPrimary`.
  /// Use for Skip buttons or any programmatic advance a step widget owns.
  void advance();
}
