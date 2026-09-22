import 'dart:ui' as ui;

import 'package:factory_core/adaptive/native/sf_symbol.dart';
import 'package:factory_core/adaptive/platform.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';

enum AdaptiveIconName {
  plus('plus', CupertinoIcons.add),
  check('checkmark', CupertinoIcons.check_mark),
  chevronRight('chevron.right', CupertinoIcons.chevron_right),
  chevronLeft('chevron.left', CupertinoIcons.chevron_left),
  chevronUp('chevron.up', CupertinoIcons.chevron_up),
  chevronDown('chevron.down', CupertinoIcons.chevron_down),
  xmark('xmark', CupertinoIcons.xmark),
  gear('gearshape', CupertinoIcons.gear),
  home('house', CupertinoIcons.home),
  person('person', CupertinoIcons.person),
  search('magnifyingglass', CupertinoIcons.search),
  heart('heart', CupertinoIcons.heart),
  heartFill('heart.fill', CupertinoIcons.heart_fill),
  star('star', CupertinoIcons.star),
  starFill('star.fill', CupertinoIcons.star_fill),
  bell('bell', CupertinoIcons.bell),
  trash('trash', CupertinoIcons.trash),
  share('square.and.arrow.up', CupertinoIcons.share),
  info('info.circle', CupertinoIcons.info),
  clock('clock', CupertinoIcons.clock),
  calendar('calendar', CupertinoIcons.calendar),
  cameraSymbol('camera', CupertinoIcons.camera),
  photo('photo', CupertinoIcons.photo),
  lock('lock', CupertinoIcons.lock),
  unlock('lock.open', CupertinoIcons.lock_open),
  arrowUp('arrow.up', CupertinoIcons.arrow_up),
  arrowDown('arrow.down', CupertinoIcons.arrow_down),
  arrowClockwise('arrow.clockwise', CupertinoIcons.refresh),
  pencil('pencil', CupertinoIcons.pencil),
  ellipsis('ellipsis', CupertinoIcons.ellipsis),
  play('play.fill', CupertinoIcons.play_fill),
  pause('pause.fill', CupertinoIcons.pause_fill),
  bag('bag', CupertinoIcons.bag);

  AdaptiveIconName(this.sfSymbol, this.cupertinoFallback);
  final String sfSymbol;
  final IconData cupertinoFallback;
}

class AdaptiveIcon extends StatelessWidget {
  const AdaptiveIcon(
    this.name, {
    this.size = 24,
    this.color,
    this.weight = SymbolWeight.regular,
    super.key,
  });

  final AdaptiveIconName name;
  final double size;
  final Color? color;
  final SymbolWeight weight;

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isIOS) {
      return _SfSymbolIcon(
        symbol: name.sfSymbol,
        fallback: name.cupertinoFallback,
        size: size,
        color: color ?? DefaultTextStyle.of(context).style.color,
        weight: weight,
      );
    }
    return Icon(name.cupertinoFallback, size: size, color: color);
  }
}

class _SfSymbolIcon extends StatefulWidget {
  const _SfSymbolIcon({
    required this.symbol,
    required this.fallback,
    required this.size,
    required this.color,
    required this.weight,
  });

  final String symbol;
  final IconData fallback;
  final double size;
  final Color? color;
  final SymbolWeight weight;

  @override
  State<_SfSymbolIcon> createState() => _SfSymbolIconState();
}

class _SfSymbolIconState extends State<_SfSymbolIcon> {
  Future<ui.Image?>? _future;
  double _dpr = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeRefresh();
  }

  @override
  void didUpdateWidget(_SfSymbolIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.symbol != oldWidget.symbol ||
        widget.size != oldWidget.size ||
        widget.color != oldWidget.color ||
        widget.weight != oldWidget.weight) {
      _future = null;
      _maybeRefresh();
    }
  }

  void _maybeRefresh() {
    final newDpr = MediaQuery.of(context).devicePixelRatio;
    if (_future != null && newDpr == _dpr) return;
    _dpr = newDpr;
    _future = SfSymbol.render(
      widget.symbol,
      pointSize: widget.size,
      weight: widget.weight,
      tint: widget.color,
      devicePixelRatio: newDpr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image?>(
      future: _future,
      builder: (context, snapshot) {
        final image = snapshot.data;
        if (image != null) {
          return RawImage(
            image: image,
            width: widget.size,
            height: widget.size,
          );
        }
        if (snapshot.connectionState == ConnectionState.done && image == null) {
          return Icon(
            widget.fallback,
            size: widget.size,
            color: widget.color,
          );
        }
        return SizedBox.square(dimension: widget.size);
      },
    );
  }
}
