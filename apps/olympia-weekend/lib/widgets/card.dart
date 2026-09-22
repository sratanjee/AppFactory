import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/design_tokens.dart';

/// White (or dark-surface) rounded card matching the design HTML —
/// 18 px radius, 1 px shadow, 20 px padding by default.
class OlympiaCard extends StatelessWidget {
  const OlympiaCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.border,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: border,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Horizontal 1 px hairline used inside stacked list cards, indented
/// to match the design (starts after the left-column time slot).
class OlympiaDivider extends StatelessWidget {
  const OlympiaDivider({this.indent = 18, super.key});

  final double indent;

  @override
  Widget build(BuildContext context) {
    final colors = context.olympiaColors;
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(height: 1, color: colors.divider),
    );
  }
}
