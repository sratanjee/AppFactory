import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/data/models.dart';
import 'package:olympia_weekend/features/directions.dart';

void main() {
  const palms = Venue(
    id: 'palms',
    name: 'Palms Casino Resort',
    short: 'Palms',
    address: '4321 W Flamingo Rd, Las Vegas, NV 89103',
    lat: 36.1147,
    lng: -115.1946,
    placeId: 'ChIJ__PALMS__LOOKUP_AT_BUILD',
    role: 'Home base.',
    shuttle: false,
    rooms: [],
  );

  const orleans = Venue(
    id: 'orleans',
    name: 'Orleans Arena',
    short: 'Orleans',
    address: '4500 W Tropicana Ave, Las Vegas, NV 89103',
    lat: 36.1017,
    lng: -115.1868,
    placeId: 'ChIJa1b2c3d4e5f6',
    role: 'Finals.',
    shuttle: true,
    rooms: [],
  );

  test('placeholder placeId is omitted from google maps url', () {
    final uri = googleMapsWebUrl(palms);
    expect(uri.queryParameters['destination'], '36.1147,-115.1946');
    expect(uri.queryParameters.containsKey('destination_place_id'), isFalse);
  });

  test('real placeId is included', () {
    final uri = googleMapsWebUrl(orleans);
    expect(uri.queryParameters['destination_place_id'], 'ChIJa1b2c3d4e5f6');
  });

  test('apple maps and google maps app URLs use daddr', () {
    expect(appleMapsUrl(palms).toString(),
        'maps://?daddr=36.1147,-115.1946');
    expect(googleMapsAppUrl(palms).toString(),
        'comgooglemaps://?daddr=36.1147,-115.1946');
  });
}
