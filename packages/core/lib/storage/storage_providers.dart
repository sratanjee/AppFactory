import 'package:factory_core/storage/key_value_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's spec §1 slug. Apps override this in
/// `AdaptiveApp.riverpodOverrides` at boot:
///
/// ```dart
/// runApp(AdaptiveApp(
///   ...,
///   riverpodOverrides: [
///     appSlugProvider.overrideWithValue('habits'),
///   ],
/// ));
/// ```
final appSlugProvider = Provider<String>((ref) {
  throw StateError(
    'appSlugProvider must be overridden with the app slug in '
    'AdaptiveApp.riverpodOverrides.',
  );
});

/// Async provider for the app's [KeyValueStore]. Opens the underlying Drift
/// database on first read, closes it on dispose.
final keyValueStoreProvider = FutureProvider<KeyValueStore>((ref) async {
  final slug = ref.watch(appSlugProvider);
  final kv = await KeyValueStore.open(appSlug: slug);
  ref.onDispose(kv.close);
  return kv;
});
