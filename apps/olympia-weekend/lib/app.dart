import 'package:factory_core/adaptive/adaptive.dart';
import 'package:factory_core/analytics/analytics.dart';
import 'package:factory_core/paywall/paywall.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olympia_weekend/app_config.dart';
import 'package:olympia_weekend/features/saved_events.dart';
import 'package:olympia_weekend/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Olympia doesn't use the factory storage layer (data ships as bundled
// JSON + Supabase per spec §4), so we intentionally skip
// `package:factory_core/factory_core.dart` — that barrel exports Drift
// via `storage/`, which pulls in `dart:ffi` and breaks `flutter build
// web`. Same reason the `appSlugProvider` override isn't set here:
// olympia has no widgets in v1 (spec §5), so nothing reads it.
class OlympiaWeekendApp extends ConsumerStatefulWidget {
  const OlympiaWeekendApp({required this.prefs, super.key});

  final SharedPreferences prefs;

  @override
  ConsumerState<OlympiaWeekendApp> createState() => _OlympiaWeekendAppState();
}

class _OlympiaWeekendAppState extends ConsumerState<OlympiaWeekendApp> {
  @override
  void initState() {
    super.initState();
    // Hydrate the saved-events store from disk before first render.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedEventsProvider.notifier).attach(widget.prefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'Olympia Weekend',
      theme: const AdaptiveTheme(
        accent: Color(0xFFe2231a),
        child: SizedBox.shrink(),
      ),
      router: buildRouter(),
      riverpodOverrides: [
        analyticsConfigProvider.overrideWithValue(AppConfig.analyticsConfig),
        paywallConfigProvider.overrideWithValue(AppConfig.paywallConfig),
      ],
    );
  }
}
