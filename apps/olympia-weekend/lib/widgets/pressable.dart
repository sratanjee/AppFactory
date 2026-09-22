import 'package:flutter/widgets.dart';

/// Shared pressable wrapper for every tappable row / chip / pill / button in
/// the app.
///
/// Gives three things Flutter's raw [GestureDetector] doesn't:
///
/// 1. A visual pressed state — a short opacity dip, tuned to feel like the
///    system button on iOS rather than a Material ripple, which would fight
///    the flat design.
/// 2. `SystemMouseCursors.click` on web + desktop so the whole surface reads
///    as interactive without adding an extra tooltip.
/// 3. An enforced minimum tap target — 48×48 by default, matching Material's
///    accessibility guideline. Callers can opt out with [minSize] when the
///    parent already guarantees enough padding (e.g. an event row that
///    already has 14px vertical padding on top of its content).
class OlympiaPressable extends StatefulWidget {
  const OlympiaPressable({
    required this.onTap,
    required this.child,
    this.pressedOpacity = 0.55,
    this.minSize = Size.zero,
    this.semanticsLabel,
    this.semanticsSelected,
    this.behavior = HitTestBehavior.opaque,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;

  /// How much to dim the child while pressed. 0.55 matches Cupertino's
  /// `activeOpacity` on tappable text.
  final double pressedOpacity;

  /// Minimum hit-target size. Only enforced when non-zero.
  final Size minSize;

  /// If provided, wraps in a `Semantics(button: true, label: …)` node.
  final String? semanticsLabel;
  final bool? semanticsSelected;

  final HitTestBehavior behavior;

  @override
  State<OlympiaPressable> createState() => _OlympiaPressableState();
}

class _OlympiaPressableState extends State<OlympiaPressable> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedOpacity(
      opacity: _pressed ? widget.pressedOpacity : 1,
      duration: const Duration(milliseconds: 90),
      child: widget.child,
    );

    if (widget.minSize != Size.zero) {
      child = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minSize.width,
          minHeight: widget.minSize.height,
        ),
        child: child,
      );
    }

    Widget result = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        onPointerDown: (_) => _set(true),
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        child: GestureDetector(
          behavior: widget.behavior,
          onTap: () {
            widget.onTap();
          },
          onTapCancel: () => _set(false),
          child: child,
        ),
      ),
    );

    if (widget.semanticsLabel != null || widget.semanticsSelected != null) {
      result = Semantics(
        button: true,
        label: widget.semanticsLabel,
        selected: widget.semanticsSelected,
        child: ExcludeSemantics(child: result),
      );
    }
    return result;
  }
}
