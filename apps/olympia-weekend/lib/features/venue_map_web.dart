// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/data/models.dart';

/// Web venue map — a Google Maps Embed API iframe centred on Palms.
///
/// The Embed API lets us render a real map without loading the JS SDK,
/// which keeps the bundle size down and skips a runtime script inject.
/// Trade-off: the iframe only supports one pin per view, so tapping a
/// venue in the list below the map is how users move between venues
/// (see venues_screen.dart).
Widget createVenueMap({
  required List<Venue> venues,
  required String apiKey,
  required void Function(Venue venue) onPinTap,
}) {
  if (apiKey.isEmpty) {
    return const SizedBox.shrink();
  }
  final viewType = 'olympia-venue-map-${venues.map((v) => v.id).join('-')}';
  // Fit bounds to all five venues so the map opens showing the full
  // spread from the Palms to LVCC.
  final lats = venues.map((v) => v.lat).toList()..sort();
  final lngs = venues.map((v) => v.lng).toList()..sort();
  final centerLat = (lats.first + lats.last) / 2;
  final centerLng = (lngs.first + lngs.last) / 2;
  final url = Uri.https('www.google.com', '/maps/embed/v1/view', {
    'key': apiKey,
    'center': '$centerLat,$centerLng',
    'zoom': '12',
    'maptype': 'roadmap',
  });
  // Register a factory the first time we see this view type. Repeat
  // calls with the same key are a no-op inside dart:ui_web.
  try {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int _) {
        final iframe = html.IFrameElement()
          ..src = url.toString()
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = false
          ..setAttribute('loading', 'lazy')
          ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
        return iframe;
      },
    );
  } catch (_) {
    // Duplicate registration is fine; ui_web throws instead of noop.
  }
  return HtmlElementView(viewType: viewType);
}
