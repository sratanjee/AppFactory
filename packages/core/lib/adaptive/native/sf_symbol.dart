import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum SymbolWeight {
  ultraLight,
  thin,
  light,
  regular,
  medium,
  semibold,
  bold,
  heavy,
  black,
}

class SfSymbol {
  SfSymbol._();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel('factory_core/sf_symbol');

  static final Map<String, ui.Image> _cache = <String, ui.Image>{};

  static Future<ui.Image?> render(
    String name, {
    double pointSize = 24,
    SymbolWeight weight = SymbolWeight.regular,
    Color? tint,
    double devicePixelRatio = 1,
  }) async {
    final tintARGB = tint == null ? null : _colorToArgb(tint);
    final key = _cacheKey(name, pointSize, weight, tintARGB, devicePixelRatio);
    final cached = _cache[key];
    if (cached != null) return cached;

    Uint8List? bytes;
    try {
      bytes = await channel.invokeMethod<Uint8List>('render', <String, Object?>{
        'name': name,
        'pointSize': pointSize,
        'weight': weight.name,
        'tintARGB': tintARGB,
        'devicePixelRatio': devicePixelRatio,
      });
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
    if (bytes == null) return null;

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    _cache[key] = frame.image;
    return frame.image;
  }

  @visibleForTesting
  static void clearCache() {
    for (final image in _cache.values) {
      image.dispose();
    }
    _cache.clear();
  }

  static int _colorToArgb(Color color) {
    final a = (color.a * 255).round() & 0xff;
    final r = (color.r * 255).round() & 0xff;
    final g = (color.g * 255).round() & 0xff;
    final b = (color.b * 255).round() & 0xff;
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  static String _cacheKey(
    String name,
    double size,
    SymbolWeight weight,
    int? tintARGB,
    double dpr,
  ) =>
      '$name|$size|${weight.name}|${tintARGB ?? 'none'}|$dpr';
}
