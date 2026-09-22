import 'package:factory_core/shorebird/shorebird.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/app.dart';
import 'package:olympia_weekend/app_config.dart';
import 'package:olympia_weekend/features/mixpanel_service.dart';
import 'package:olympia_weekend/features/saved_events.dart';
import 'package:olympia_weekend/features/sightings_repo.dart';
import 'package:olympia_weekend/features/vegas_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrapShorebird();
  initVegasTimeZone();

  final prefs = await SharedPreferences.getInstance();

  if (supabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (_) {
      // stays disabled — sightings gracefully no-op
    }
  }

  final mixpanel = await MixpanelService.init();
  await mixpanel.appOpen(prefs);

  final deviceId = await resolveDeviceId(prefs);
  final sightingsRepo = SightingsRepo(
    client: supabaseConfigured ? Supabase.instance.client : null,
    deviceId: deviceId,
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mixpanelProvider.overrideWithValue(mixpanel),
        sightingsRepoProvider.overrideWithValue(sightingsRepo),
      ],
      child: OlympiaWeekendApp(prefs: prefs),
    ),
  );
}
