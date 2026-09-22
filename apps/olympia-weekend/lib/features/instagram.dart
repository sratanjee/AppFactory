import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Uri instagramAppUrl(String handle) =>
    Uri.parse('instagram://user?username=$handle');

Uri instagramWebUrl(String handle) =>
    Uri.parse('https://instagram.com/$handle');

/// Tries to open the native app first, falls back to the web URL.
///
/// On web the app URL is skipped entirely — [launchUrl] on a custom
/// scheme just fails silently in browsers.
Future<void> openInstagram(String handle) async {
  if (!kIsWeb) {
    if (await launchUrl(instagramAppUrl(handle))) return;
  }
  await launchUrl(instagramWebUrl(handle),
      mode: LaunchMode.externalApplication);
}
