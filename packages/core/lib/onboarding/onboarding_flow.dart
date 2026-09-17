import 'dart:async';

import 'package:factory_core/adaptive/adaptive.dart';
import 'package:factory_core/analytics/analytics.dart';
import 'package:factory_core/l10n/l10n.dart';
import 'package:factory_core/onboarding/onboarding_step.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 2–4 step onboarding container per DESIGN_GUIDE §3.
///
/// Renders one step at a time inside an [AdaptiveScaffold] with a thin
/// accent-tinted progress bar at the top and a bottom-anchored
/// [AdaptivePrimaryButton]. Fires
/// `Analytics.trackOnboardingStep(step: index)` on every step-visible
/// transition (reads `analyticsProvider` internally).
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({
    required this.steps,
    required this.onComplete,
    this.onCancel,
    super.key,
  });

  final List<OnboardingStep> steps;

  /// Fires once the terminal step's primary button is tapped. Receives a
  /// map of every answer the steps recorded via `ctx.answer(...)`.
  final void Function(Map<String, Object?> answers) onComplete;

  /// If provided, a top-left `xmark` close button is rendered and fires this.
  /// The flow does not call `onComplete` on cancel.
  final VoidCallback? onCancel;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  int _index = 0;
  bool _canAdvance = true;
  bool _pending = false;
  final Map<String, Object?> _answers = {};

  @override
  void initState() {
    super.initState();
    assert(
      widget.steps.length >= 2 && widget.steps.length <= 4,
      'OnboardingFlow requires 2 to 4 steps (DESIGN_GUIDE §3). Got '
      '${widget.steps.length}.',
    );
    _canAdvance = widget.steps.first.canAdvance;
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackStepVisible());
  }

  void _trackStepVisible() {
    if (!mounted) return;
    ref.read(analyticsProvider).trackOnboardingStep(step: _index);
  }

  Future<void> _handlePrimary() async {
    if (!_canAdvance || _pending) return;
    final step = widget.steps[_index];
    final ctx = _makeContext();
    final onPrimary = step.onPrimary;
    if (onPrimary != null) {
      setState(() => _pending = true);
      try {
        final shouldAdvance = await onPrimary(ctx);
        if (!mounted) return;
        if (shouldAdvance) _advance();
      } finally {
        if (mounted) setState(() => _pending = false);
      }
    } else {
      _advance();
    }
  }

  void _advance() {
    if (!mounted) return;
    if (_index == widget.steps.length - 1) {
      widget.onComplete(Map.of(_answers));
      return;
    }
    setState(() {
      _index++;
      _canAdvance = widget.steps[_index].canAdvance;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackStepVisible());
  }

  OnboardingStepContext _makeContext() {
    return _StepContext(
      index: _index,
      total: widget.steps.length,
      onAnswer: (key, value) => _answers[key] = value,
      onSetCanAdvance: ({required canAdvance}) {
        if (!mounted) return;
        setState(() => _canAdvance = canAdvance);
      },
      onAdvance: _advance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.adaptiveTheme;
    final step = widget.steps[_index];
    final progress = (_index + 1) / widget.steps.length;
    final isLast = _index == widget.steps.length - 1;
    final defaultLabel = isLast
        ? (context.maybeL10n?.buttonGetStarted ?? 'Get started')
        : (context.maybeL10n?.buttonContinue ?? 'Continue');
    final label = step.primaryActionLabel ?? defaultLabel;

    return AdaptiveScaffold(
      titleDisplay: TitleDisplay.none,
      body: Column(
        children: [
          if (widget.onCancel != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.sm,
                  vertical: theme.spacing.sm,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onCancel,
                  child: const AdaptiveIcon(AdaptiveIconName.xmark, size: 22),
                ),
              ),
            ),
          _OnboardingProgressBar(progress: progress, accent: theme.accent),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
              child: step.build(context, _makeContext()),
            ),
          ),
        ],
      ),
      primaryAction: AdaptivePrimaryButton(
        label: label,
        onPressed: _handlePrimary,
        enabled: _canAdvance && !_pending,
        isLoading: _pending,
      ),
    );
  }
}

class _OnboardingProgressBar extends StatelessWidget {
  const _OnboardingProgressBar({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        color: accent,
        backgroundColor: accent.withValues(alpha: 0.15),
        minHeight: 2,
      ),
    );
  }
}

class _StepContext implements OnboardingStepContext {
  _StepContext({
    required this.index,
    required this.total,
    required this.onAnswer,
    required this.onSetCanAdvance,
    required this.onAdvance,
  });

  @override
  final int index;

  @override
  final int total;

  final void Function(String, Object?) onAnswer;
  final void Function({required bool canAdvance}) onSetCanAdvance;
  final VoidCallback onAdvance;

  @override
  void answer(String key, Object? value) => onAnswer(key, value);

  @override
  void setCanAdvance({required bool canAdvance}) =>
      onSetCanAdvance(canAdvance: canAdvance);

  @override
  void advance() => onAdvance();
}
