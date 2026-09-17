import 'package:flutter/widgets.dart';

class AdaptiveTheme extends InheritedWidget {
  const AdaptiveTheme({
    required this.accent,
    required super.child,
    this.spacing = SpacingScale.standard,
    this.cornerRadius = CornerRadiusScale.standard,
    super.key,
  });

  final Color accent;
  final SpacingScale spacing;
  final CornerRadiusScale cornerRadius;

  static AdaptiveTheme of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<AdaptiveTheme>();
    assert(
      theme != null,
      'AdaptiveTheme not found in context. Wrap your app in AdaptiveApp.',
    );
    return theme!;
  }

  static AdaptiveTheme? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveTheme>();

  @override
  bool updateShouldNotify(AdaptiveTheme oldWidget) =>
      accent != oldWidget.accent ||
      spacing != oldWidget.spacing ||
      cornerRadius != oldWidget.cornerRadius;
}

class SpacingScale {
  const SpacingScale({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
  });

  static const SpacingScale standard = SpacingScale(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
    xxxl: 48,
  );

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
}

class CornerRadiusScale {
  const CornerRadiusScale({
    required this.sm,
    required this.md,
    required this.lg,
  });

  static const CornerRadiusScale standard = CornerRadiusScale(
    sm: 8,
    md: 12,
    lg: 16,
  );

  final double sm;
  final double md;
  final double lg;
}

extension AdaptiveThemeAccess on BuildContext {
  AdaptiveTheme get adaptiveTheme => AdaptiveTheme.of(this);
}
