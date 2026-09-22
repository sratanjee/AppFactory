import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/app_config.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of a confirm-sighting call.
enum ConfirmSightingResult { inserted, duplicate, rateLimited, failed, disabled }

/// Thin wrapper over the `sightings` table.
class SightingsRepo {
  SightingsRepo({SupabaseClient? client, required String deviceId})
      : _client = client,
        _deviceId = deviceId;

  final SupabaseClient? _client;
  final String _deviceId;

  /// Attempts to insert a sighting. Collapses unique-violation (23505)
  /// silently as `duplicate`, `rate_limited` as `rateLimited`.
  Future<ConfirmSightingResult> confirm({
    required String athleteId,
    required Appearance appearance,
  }) async {
    final client = _client;
    if (client == null) return ConfirmSightingResult.disabled;
    try {
      await client.from('sightings').insert({
        'athlete_id': athleteId,
        'appearance_key': appearance.appearanceKey(athleteId),
        'device_id': _deviceId,
      });
      return ConfirmSightingResult.inserted;
    } on PostgrestException catch (e) {
      if (e.code == '23505') return ConfirmSightingResult.duplicate;
      if (e.code == 'rate_limited' ||
          (e.message).toLowerCase().contains('rate')) {
        return ConfirmSightingResult.rateLimited;
      }
      return ConfirmSightingResult.failed;
    } catch (_) {
      return ConfirmSightingResult.failed;
    }
  }
}

/// Returns a stable per-device id, generated once and cached.
Future<String> resolveDeviceId(SharedPreferences prefs) async {
  const key = 'olympia.device_id';
  final existing = prefs.getString(key);
  if (existing != null && existing.isNotEmpty) return existing;

  String candidate = 'anon-${DateTime.now().microsecondsSinceEpoch}';
  try {
    final info = DeviceInfoPlugin();
    if (kIsWeb) {
      final web = await info.webBrowserInfo;
      candidate = 'web-${web.userAgent?.hashCode ?? candidate.hashCode}';
    }
  } catch (_) {
    // fallback stays
  }
  await prefs.setString(key, candidate);
  return candidate;
}

final sightingsRepoProvider = Provider<SightingsRepo>((ref) {
  throw StateError('SightingsRepo must be overridden at app start.');
});

/// True when Supabase is configured (URL + anon key present).
bool get supabaseConfigured =>
    AppConfig.supabaseUrl.isNotEmpty &&
    AppConfig.supabaseAnonKey.isNotEmpty &&
    AppConfig.supabaseUrl != 'stub' &&
    AppConfig.supabaseAnonKey != 'stub';
