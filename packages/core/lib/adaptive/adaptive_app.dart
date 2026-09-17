import 'dart:async';

import 'package:factory_core/adaptive/platform.dart';
import 'package:factory_core/adaptive/theme.dart';
import 'package:flutter/cupertino.dart' show CupertinoApp, CupertinoThemeData;
import 'package:flutter/material.dart' show ColorScheme, MaterialApp, ThemeData;
import 'package:flutter/services.dart' show SystemChrome, SystemUiMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:go_router/go_router.dart';

class AdaptiveApp extends StatefulWidget {
  const AdaptiveApp({
    required this.router,
    required this.theme,
    this.title = '',
    this.localizationsDelegates,
    this.supportedLocales,
    this.riverpodOverrides = const [],
    super.key,
  });

  final GoRouter router;
  final AdaptiveTheme theme;
  final String title;
  final Iterable<LocalizationsDelegate<Object?>>? localizationsDelegates;
  final Iterable<Locale>? supportedLocales;
  final List<Override> riverpodOverrides;

  @override
  State<AdaptiveApp> createState() => _AdaptiveAppState();
}

class _AdaptiveAppState extends State<AdaptiveApp> {
  @override
  void initState() {
    super.initState();
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: widget.riverpodOverrides,
      child: AdaptiveTheme(
        accent: widget.theme.accent,
        spacing: widget.theme.spacing,
        cornerRadius: widget.theme.cornerRadius,
        child: _buildPlatformApp(),
      ),
    );
  }

  Widget _buildPlatformApp() {
    final delegates = <LocalizationsDelegate<Object?>>[
      ...?widget.localizationsDelegates,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
    final locales = widget.supportedLocales ?? const [Locale('en')];

    if (AdaptivePlatform.isIOS) {
      return CupertinoApp.router(
        title: widget.title,
        routerConfig: widget.router,
        theme: CupertinoThemeData(primaryColor: widget.theme.accent),
        localizationsDelegates: delegates,
        supportedLocales: locales,
      );
    }
    return MaterialApp.router(
      title: widget.title,
      routerConfig: widget.router,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: widget.theme.accent),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: widget.theme.accent,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: delegates,
      supportedLocales: locales,
    );
  }
}
