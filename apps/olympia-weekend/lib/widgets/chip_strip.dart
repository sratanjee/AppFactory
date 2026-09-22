import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/design_tokens.dart';

/// Horizontal-scrolling row for filter/division chips.
///
/// Wraps a `ListView` with two things the default doesn't give you:
///
/// 1. Mouse-drag support on web + desktop. Flutter's stock `ScrollBehavior`
///    only accepts touch and trackpad, so a mouse can't drag a horizontal
///    list on chrome. Users tried to scroll Athletes' division chips and
///    nothing happened.
/// 2. A right-edge fade so there's a visual hint that more chips exist
///    off-screen (the row fades out into the background colour).
class HorizontalChipStrip extends StatelessWidget {
  const HorizontalChipStrip({
    required this.children,
    this.height = 44,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    super.key,
  });

  final List<Widget> children;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bg = context.olympiaColors.background;
    return SizedBox(
      height: height,
      child: ScrollConfiguration(
        behavior: const _DragScrollBehavior(),
        child: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.02, 0.94, 1.0],
              colors: [bg, const Color(0xFFFFFFFF), const Color(0xFFFFFFFF), bg],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: padding,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Extends `ScrollBehavior.dragDevices` to include mouse so horizontal
/// strips are draggable on web + desktop.
class _DragScrollBehavior extends ScrollBehavior {
  const _DragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };

  // Kill the default scrollbar on horizontal strips — chips are the
  // affordance; a scrollbar underneath a 44pt strip looks bad.
  @override
  Widget buildScrollbar(_, Widget child, __) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return kIsWeb
        ? const BouncingScrollPhysics()
        : super.getScrollPhysics(context);
  }
}
