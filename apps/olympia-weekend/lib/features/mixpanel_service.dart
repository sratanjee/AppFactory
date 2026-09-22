import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:olympia_weekend/app_config.dart';
import 'package:olympia_weekend/features/first_touch_source.dart';
import 'package:olympia_weekend/features/vegas_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// Minimal Mixpanel wrapper. Adds super properties to every call and
/// gracefully no-ops when the token isn't configured (dev / test).
///
/// Not part of `core/analytics` on purpose: Olympia's tracking plan is
/// its own thing (see `data/olympia-weekend/MIXPANEL.md`, spec §7).
class MixpanelService {
  MixpanelService._(this._mp, this._sharedProps);

  final Mixpanel? _mp;
  final Map<String, Object?> _sharedProps;

  static const _kFirstOpenFlag = 'olympia.first_open_done';

  /// Boot from the token in [AppConfig]. Never throws.
  static Future<MixpanelService> init() async {
    Mixpanel? mp;
    final token = AppConfig.mixpanelToken;
    if (token.isNotEmpty && token != 'stub') {
      try {
        mp = await Mixpanel.init(
          token,
          trackAutomaticEvents: false,
          optOutTrackingDefault: false,
        );
      } catch (_) {
        mp = null;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final source = await ensureFirstTouchSource(prefs);
    final theme = _detectTheme();
    final now = tz.TZDateTime.now(vegasLocation);
    final props = <String, Object?>{
      'platform': _detectPlatform(),
      'installed': _detectInstalled(),
      'theme': theme,
      'app_version': '1.0.0',
      'day': _dayShort(now),
      'hour': now.hour,
      'source': source,
    };

    if (mp != null) {
      try {
        await mp.registerSuperProperties(props);
      } catch (_) {
        // swallow — analytics must not break the app
      }
    }

    return MixpanelService._(mp, props);
  }

  /// Merges super props into every event so downstream consumers (tests
  /// and Mixpanel Live View) get the same shape.
  Future<void> track(
    String event, [
    Map<String, Object?> properties = const {},
  ]) async {
    final mp = _mp;
    if (mp == null) return;
    try {
      await mp.track(event, properties: {..._sharedProps, ...properties});
    } catch (_) {
      // swallow
    }
  }

  /// Called from app lifecycle observer.
  Future<void> flush() async {
    final mp = _mp;
    if (mp == null) return;
    try {
      await mp.flush();
    } catch (_) {
      // swallow
    }
  }

  /// Exposed for tests.
  Map<String, Object?> get superProperties => Map.unmodifiable(_sharedProps);

  Future<void> appOpen(SharedPreferences prefs) async {
    final firstOpen = !(prefs.getBool(_kFirstOpenFlag) ?? false);
    await prefs.setBool(_kFirstOpenFlag, true);
    await track('app_open', {'first_open': firstOpen});
  }

  // Typed helpers for the 22 events from spec §7.

  Future<void> viewNow({String? nowEventId, String? nextEventId}) => track(
        'view_now',
        {'now_event_id': nowEventId, 'next_event_id': nextEventId},
      );

  Future<void> viewSchedule({required String daySelected, required String filter}) =>
      track('view_schedule', {'day_selected': daySelected, 'filter': filter});

  Future<void> filterChange(String filter) =>
      track('filter_change', {'filter': filter});

  Future<void> dayChange(String from, String to) =>
      track('day_change', {'from': from, 'to': to});

  Future<void> viewEvent({
    required String eventId,
    required String access,
    required String venue,
    required String fromScreen,
  }) =>
      track('view_event', {
        'event_id': eventId,
        'access': access,
        'venue': venue,
        'from_screen': fromScreen,
      });

  Future<void> saveEvent(String eventId) =>
      track('save_event', {'event_id': eventId});

  Future<void> unsaveEvent(String eventId) =>
      track('unsave_event', {'event_id': eventId});

  Future<void> viewSaved(int count) => track('view_saved', {'count': count});

  Future<void> viewAthletes(String division) =>
      track('view_athletes', {'division': division});

  Future<void> searchAthletes(int queryLength, int results) => track(
        'search_athletes',
        {'query_length': queryLength, 'results': results},
      );

  Future<void> viewAthlete({
    required String athleteId,
    required String division,
    required bool hasInstagram,
    required bool hasAppearance,
  }) =>
      track('view_athlete', {
        'athlete_id': athleteId,
        'division': division,
        'has_instagram': hasInstagram,
        'has_appearance': hasAppearance,
      });

  Future<void> openInstagram(String athleteId) =>
      track('open_instagram', {'athlete_id': athleteId});

  Future<void> confirmSighting({
    required String athleteId,
    required String booth,
    required String resultingStatus,
  }) =>
      track('confirm_sighting', {
        'athlete_id': athleteId,
        'booth': booth,
        'resulting_status': resultingStatus,
      });

  Future<void> reportSighting(String athleteId) =>
      track('report_sighting', {'athlete_id': athleteId});

  Future<void> viewVenues() => track('view_venues');

  Future<void> viewVenue(String venueId) =>
      track('view_venue', {'venue_id': venueId});

  Future<void> directionsTap({required String venueId, required String mapsApp}) =>
      track('directions_tap', {'venue_id': venueId, 'maps_app': mapsApp});

  Future<void> shareTap({required String screen, String? eventId}) =>
      track('share_tap', {'screen': screen, if (eventId != null) 'event_id': eventId});

  Future<void> error({required String where, required String message}) =>
      track('error', {'where': where, 'message': message});

  Future<void> installPromptShown() => track('install_prompt_shown');

  Future<void> installCompleted() => track('install_completed');
}

String _detectPlatform() {
  if (kIsWeb) return 'desktop_web';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return 'desktop_web';
}

bool _detectInstalled() {
  // On stores, we're always "installed". On web the display-mode check
  // happens in the install-hint banner shim.
  return !kIsWeb;
}

String _detectTheme() {
  final b = PlatformDispatcher.instance.platformBrightness;
  return b == Brightness.dark ? 'dark' : 'light';
}

String _dayShort(tz.TZDateTime t) {
  const map = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  return map[t.weekday - 1];
}

/// Test seam.
final mixpanelProvider = Provider<MixpanelService>((ref) {
  throw StateError('MixpanelService must be overridden at app start.');
});
