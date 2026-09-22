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
}) {
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
      zoom: venues.length == 1 ? 15 : 11.5,
    ),
    markers: markers,
    myLocationButtonEnabled: false,
    compassEnabled: false,
    zoomControlsEnabled: false,
  );
}
