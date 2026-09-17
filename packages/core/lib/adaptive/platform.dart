import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

enum AdaptivePlatformType { ios, android }

class AdaptivePlatform {
  AdaptivePlatform._();

  static AdaptivePlatformType? _debugOverride;

  static AdaptivePlatformType get current {
    if (_debugOverride != null) return _debugOverride!;
    if (kIsWeb) return AdaptivePlatformType.android;
    if (Platform.isIOS) return AdaptivePlatformType.ios;
    if (Platform.isAndroid) return AdaptivePlatformType.android;
    return AdaptivePlatformType.ios;
  }

  static bool get isIOS => current == AdaptivePlatformType.ios;

  static bool get isAndroid => current == AdaptivePlatformType.android;

  @visibleForTesting
  static AdaptivePlatformType? get debugOverride => _debugOverride;

  @visibleForTesting
  static set debugOverride(AdaptivePlatformType? type) => _debugOverride = type;
}
