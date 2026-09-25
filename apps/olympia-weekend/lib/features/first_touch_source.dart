import 'package:flutter/foundation.dart';
import 'package:olympia_weekend/features/referrer_reader_stub.dart'
    if (dart.library.html) 'package:olympia_weekend/features/referrer_reader_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFirstTouchSourceKey = 'olympia.first_touch_source';
const _kFirstTouchReferrerKey = 'olympia.first_touch_referrer';

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

/// Reads `document.referrer` on first web open and persists it. Later
/// opens reuse the stored value so we can attribute a device back to
/// the domain that originally sent them, even after they've come back
/// direct. On installed builds this is always `(installed)`.
Future<String> ensureFirstTouchReferrer(SharedPreferences prefs) async {
  final existing = prefs.getString(_kFirstTouchReferrerKey);
  if (existing != null && existing.isNotEmpty) return existing;

  final value = kIsWeb ? (_referrerHost() ?? '(direct)') : '(installed)';
  await prefs.setString(_kFirstTouchReferrerKey, value);
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

/// Extracts the host from a full referrer URL. `null` if unparseable
/// or empty. Exposed for tests.
String? parseReferrerHost(String? referrer) {
  if (referrer == null || referrer.isEmpty) return null;
  final uri = Uri.tryParse(referrer);
  if (uri == null || uri.host.isEmpty) return null;
  return uri.host;
}

String? _parseFirstTouchFromCurrentUrl() {
  if (!kIsWeb) return null;
  // Reading `Uri.base` on web is the platform-agnostic way to see the
  // current URL without importing dart:html.
  return parseUtmSource(Uri.base.toString());
}

String? _referrerHost() {
  final raw = readDocumentReferrer();
  return parseReferrerHost(raw);
}
