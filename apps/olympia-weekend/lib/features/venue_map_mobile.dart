import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:olympia_weekend/data/models.dart';

/// Mobile venue map — uses `google_maps_flutter`. The plugin picks up
/// the API key from `Info.plist` (iOS) and `AndroidManifest.xml`
/// (Android); the key here is only used to gate an empty state on
/// dev builds.
Widget createVenueMap({
  required List<Venue> venues,
  required String apiKey,
  required void Function(Venue venue) onPinTap,
  String? query,
}) {
  // `query` is a hint the web build uses to sub-locate inside a
  // resort (Palms Casino Resort → Pearl Theater). On mobile the
  // native `google_maps_flutter` doesn't have a room-precise place
  // API, so we just zoom in a bit tighter when a query is provided.
  final singleZoom = query != null && query.isNotEmpty ? 17.0 : 15.0;
  if (apiKey.isEmpty || venues.isEmpty) {
    return const SizedBox.shrink();
  }
  final markers = <Marker>{
    for (final v in venues)
      Marker(
        markerId: MarkerId(v.id),
        position: LatLng(v.lat, v.lng),
        infoWindow: InfoWindow(title: v.short, snippet: v.role),
        onTap: () => onPinTap(v),
      ),
  };
  final lats = venues.map((v) => v.lat).toList()..sort();
  final lngs = venues.map((v) => v.lng).toList()..sort();
  return GoogleMap(
    initialCameraPosition: CameraPosition(
      target: LatLng(
        (lats.first + lats.last) / 2,
        (lngs.first + lngs.last) / 2,
      ),
      zoom: venues.length == 1 ? singleZoom : 11.5,
    ),
    markers: markers,
    myLocationButtonEnabled: false,
    compassEnabled: false,
    zoomControlsEnabled: false,
  );
}
