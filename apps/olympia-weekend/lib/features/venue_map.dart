import 'package:flutter/widgets.dart';
import 'package:olympia_weekend/data/models.dart';

import 'venue_map_stub.dart'
    if (dart.library.html) 'venue_map_web.dart'
    if (dart.library.io) 'venue_map_mobile.dart';

/// Interactive map with pins for each [venue]. Web uses the Google
/// Maps Embed API in an iframe; mobile uses `google_maps_flutter`.
/// Returns the shared surface via a conditional import.
///
/// [onPinTap] fires when the user taps a specific venue pin; mobile
/// wires it to marker taps, web falls back to a per-venue list under
/// the map (the Embed API doesn't expose marker clicks).
Widget buildVenueMap({
  required List<Venue> venues,
  required String apiKey,
  required void Function(Venue venue) onPinTap,
}) =>
    createVenueMap(
      venues: venues,
      apiKey: apiKey,
      onPinTap: onPinTap,
    );
