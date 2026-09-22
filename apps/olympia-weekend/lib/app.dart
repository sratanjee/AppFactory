import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:factory_core/adaptive/adaptive.dart';
import 'package:factory_core/analytics/analytics.dart';
import 'package:factory_core/paywall/paywall.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedEventsProvider.notifier).attach(widget.prefs);
      _wireDeepLinks();
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _wireDeepLinks() async {
    final links = AppLinks();
    final router = ref.read(routerProvider);
    final initial = await links.getInitialLink();
    if (initial != null) _go(router, initial);
    _linkSub = links.uriLinkStream.listen((uri) => _go(router, uri));
  }

  void _go(GoRouter router, Uri uri) {
    // olympia://schedule → /schedule ; olympia:///athletes → /athletes.
    final segments = [uri.host, ...uri.pathSegments].where((s) => s.isNotEmpty);
    if (segments.isEmpty) return;
    router.go('/${segments.join('/')}');
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'Olympia Weekend',
      theme: const AdaptiveTheme(
        accent: Color(0xFFe2231a),
        child: SizedBox.shrink(),
      ),
      router: ref.read(routerProvider),
      riverpodOverrides: [
        analyticsConfigProvider.overrideWithValue(AppConfig.analyticsConfig),
        paywallConfigProvider.overrideWithValue(AppConfig.paywallConfig),
      ],
    );
  }
}
