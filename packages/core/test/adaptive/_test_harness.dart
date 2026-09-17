import 'package:factory_core/factory_core.dart';
import 'package:flutter/material.dart';

/// Wraps a widget under test with the ambient theme + MediaQuery it needs.
///
/// Callers set [AdaptivePlatform.debugOverride] in setUp; this helper doesn't
/// touch platform state so tests can control it.
Widget wrapForTest(
  Widget child, {
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Color accent = const Color(0xFF6750A4),
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light(),
    home: Scaffold(
      body: SafeArea(
        child: AdaptiveTheme(
          accent: accent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
    builder: (context, appChild) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          platformBrightness: brightness,
        ),
        child: appChild ?? const SizedBox.shrink(),
      );
    },
  );
}
