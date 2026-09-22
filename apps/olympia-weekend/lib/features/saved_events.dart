import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSavedEventsKey = 'olympia.saved_events';

class SavedEventsController extends Notifier<Set<String>> {
  SharedPreferences? _prefs;

  @override
  Set<String> build() {
    final prefs = _prefs;
    if (prefs == null) return const {};
    return (prefs.getStringList(_kSavedEventsKey) ?? const <String>[]).toSet();
  }

  void attach(SharedPreferences prefs) {
    _prefs = prefs;
    state = (prefs.getStringList(_kSavedEventsKey) ?? const <String>[]).toSet();
  }

  Future<void> toggle(String eventId) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final next = state.toSet();
    if (next.contains(eventId)) {
      next.remove(eventId);
    } else {
      next.add(eventId);
    }
    await prefs.setStringList(_kSavedEventsKey, next.toList());
    state = next;
  }

  bool contains(String eventId) => state.contains(eventId);
}

final savedEventsProvider =
    NotifierProvider<SavedEventsController, Set<String>>(
        SavedEventsController.new);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be overridden at app start.');
});
