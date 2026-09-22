import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFirstTouchSourceKey = 'olympia.first_touch_source';

/// Reads `?utm_source=...` from the browser URL on first web open and
/// persists it forever. Later opens reuse the stored value. On stores
/// this defaults to `direct`.
Future<String> ensureFirstTouchSource(SharedPreferences prefs) async {
  final existing = prefs.getString(_kFirstTouchSourceKey);
  if (existing != null && existing.isNotEmpty) return existing;

  final parsed = _parseFirstTouchFromCurrentUrl();
  final value = parsed ?? 'direct';
  await prefs.setString(_kFirstTouchSourceKey, value);
  return value;
}

/// Pure helper — testable without the browser.
String? parseUtmSource(String? url) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final s = uri.queryParameters['utm_source'];
  if (s == null || s.isEmpty) return null;
  return s;
}

String? _parseFirstTouchFromCurrentUrl() {
  if (!kIsWeb) return null;
  // Reading `Uri.base` on web is the platform-agnostic way to see the
  // current URL without importing dart:html.
  return parseUtmSource(Uri.base.toString());
}
