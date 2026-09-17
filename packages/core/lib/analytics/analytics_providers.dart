import 'package:factory_core/analytics/analytics_client.dart';
import 'package:factory_core/analytics/analytics_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Apps override this at boot in `AdaptiveApp.riverpodOverrides`.
///
/// ```dart
/// analyticsConfigProvider.overrideWithValue(
///   const AnalyticsConfig(apiKey: 'phc_xxx'),
/// )
/// ```
final analyticsConfigProvider = Provider<AnalyticsConfig>((ref) {
  throw StateError(
    'analyticsConfigProvider must be overridden with an AnalyticsConfig '
    'in AdaptiveApp.riverpodOverrides.',
  );
});

/// The app's Analytics facade. Reads [analyticsConfigProvider] once.
final analyticsProvider = Provider<Analytics>((ref) {
  final config = ref.watch(analyticsConfigProvider);
  return Analytics.forConfig(config);
});
