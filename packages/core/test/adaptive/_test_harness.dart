import 'package:factory_core/factory_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Wraps a widget under test with just enough ambient scaffolding to render
/// both Cupertino and Material widgets, without filling to parent — golden
/// scenarios pass unbounded height, so no MaterialApp/Scaffold.
///
/// Callers set [AdaptivePlatform.debugOverride] in setUp; this helper doesn't
/// touch platform state so tests can control it.
Widget wrapForTest(
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Color accent = const Color(0xFF6750A4),
}) {
  final materialTheme =
      brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
  return Localizations(
    locale: const Locale('en'),
    delegates: const [
      FactoryLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      DefaultMaterialLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
    ],
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
          platformBrightness: brightness,
        ),
        child: CupertinoTheme(
          data: CupertinoThemeData(brightness: brightness),
          child: Theme(
            data: materialTheme,
            child: DefaultTextStyle(
              style: materialTheme.textTheme.bodyMedium!,
              child: AdaptiveTheme(
                accent: accent,
                child: Material(
                  type: MaterialType.transparency,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
