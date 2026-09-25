// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Reads `document.referrer` — the domain (or full URL, browser-dependent)
/// that linked to olympiaweekend.app. Empty on direct visits, on bookmark
/// opens, and when the referring page set a strict `Referrer-Policy`.
String? readDocumentReferrer() {
  final r = html.document.referrer;
  return r.isEmpty ? null : r;
}
