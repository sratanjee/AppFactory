import 'package:factory_core/storage/storage_providers.dart';
import 'package:factory_core/widget_bridge/widget_bridge_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's WidgetBridge. Reads the app slug from [appSlugProvider], which
/// must be overridden in `AdaptiveApp.riverpodOverrides` at boot.
final widgetBridgeProvider = Provider<WidgetBridge>((ref) {
  final slug = ref.watch(appSlugProvider);
  return WidgetBridge.forSlug(slug);
});
