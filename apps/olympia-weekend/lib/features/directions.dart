import 'dart:io' show Platform;

import 'package:factory_core/adaptive/adaptive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/l10n/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Universal Google Maps directions URL. Omits `destination_place_id`
/// when the placeholder placeId is still in the bundled data.
Uri googleMapsWebUrl(Venue venue) {
  final params = <String, String>{
    'api': '1',
    'destination': '${venue.lat},${venue.lng}',
  };
  if (!venue.placeId.startsWith('ChIJ__')) {
    params['destination_place_id'] = venue.placeId;
  }
  return Uri.https('www.google.com', '/maps/dir/', params);
}

Uri appleMapsUrl(Venue venue) =>
    Uri.parse('maps://?daddr=${venue.lat},${venue.lng}');

Uri googleMapsAppUrl(Venue venue) =>
    Uri.parse('comgooglemaps://?daddr=${venue.lat},${venue.lng}');

/// Platform-appropriate directions handler. On iOS opens an action
/// sheet offering Apple/Google Maps; on Android/web opens Google Maps
/// directly. Reports the chosen app to [onTracked].
Future<void> openDirections({
  required BuildContext context,
  required Venue venue,
  required void Function(String mapsApp) onTracked,
}) async {
  if (kIsWeb || (defaultTargetPlatform == TargetPlatform.android) ||
      (!kIsWeb && Platform.isAndroid)) {
    onTracked('google');
    await launchUrl(googleMapsWebUrl(venue),
        mode: LaunchMode.externalApplication);
    return;
  }

  // iOS: action sheet.
  final choice = await AdaptiveSheet.show<String>(
    context,
    child: Builder(
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.eventDirections,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            AdaptivePrimaryButton(
              label: AppStrings.directionsAppleMaps,
              onPressed: () => Navigator.of(ctx).pop('apple'),
            ),
            const SizedBox(height: 8),
            AdaptiveSecondaryButton(
              label: AppStrings.directionsGoogleMaps,
              onPressed: () => Navigator.of(ctx).pop('google'),
            ),
            const SizedBox(height: 8),
            AdaptiveTextButton(
              label: AppStrings.directionsCancel,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    ),
  );
  if (choice == null) return;
  onTracked(choice);
  if (choice == 'apple') {
    if (!await launchUrl(appleMapsUrl(venue))) {
      await launchUrl(googleMapsWebUrl(venue),
          mode: LaunchMode.externalApplication);
    }
  } else {
    if (!await launchUrl(googleMapsAppUrl(venue))) {
      await launchUrl(googleMapsWebUrl(venue),
          mode: LaunchMode.externalApplication);
    }
  }
}
