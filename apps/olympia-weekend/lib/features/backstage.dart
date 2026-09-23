import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Access code that flips the app into Backstage mode. Chosen so staff
/// and competitors will recognise it — "Sandow" is the Mr. Olympia
/// trophy name — but keeps casual attendees out. Codified as a
/// constant so it's easy to rotate later without hunting through UI.
const String backstageCode = 'sandow';

const String _prefsKey = 'backstage_unlocked_v1';

/// Notifier backing [backstageUnlockedProvider]. Hydrates from
/// SharedPreferences at construction time so unlock survives a cold
/// start; writes are fire-and-forget (a failed write just means the
/// user re-enters the code once).
class BackstageUnlock extends Notifier<bool> {
  @override
  bool build() {
    // Hydrate asynchronously; the initial synchronous state is false
    // (locked) and flips to true once prefs come back if it was
    // previously unlocked. Downstream `ref.watch` callers will rebuild
    // when state changes.
    _hydrate();
    return false;
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlocked = prefs.getBool(_prefsKey) ?? false;
      if (unlocked && !state) {
        state = true;
      }
    } catch (_) {
      // Prefs failure just leaves the app locked — recoverable by
      // re-entering the code.
    }
  }

  /// Attempts to unlock with [code]. Case-insensitive, whitespace
  /// trimmed. Returns true on success and persists the unlocked flag.
  Future<bool> tryUnlock(String code) async {
    final ok = code.trim().toLowerCase() == backstageCode;
    if (!ok) return false;
    state = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
    } catch (_) {
      // Best-effort persistence.
    }
    return true;
  }

  /// Re-locks the app and clears the persisted flag.
  Future<void> lock() async {
    state = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {
      // Best-effort.
    }
  }
}

/// True when the user has unlocked Backstage mode via the About sheet.
/// Watched by [computeNowState], the Schedule screen, and the Now
/// header pill.
final backstageUnlockedProvider =
    NotifierProvider<BackstageUnlock, bool>(BackstageUnlock.new);
