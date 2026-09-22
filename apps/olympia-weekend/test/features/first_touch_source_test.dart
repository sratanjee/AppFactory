import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/features/first_touch_source.dart';

void main() {
  test('parses ?utm_source=instagram', () {
    expect(
      parseUtmSource('https://olympiaweekend.app/?utm_source=instagram'),
      'instagram',
    );
  });

  test('returns null when no utm_source', () {
    expect(parseUtmSource('https://olympiaweekend.app/'), isNull);
  });

  test('handles empty and null', () {
    expect(parseUtmSource(''), isNull);
    expect(parseUtmSource(null), isNull);
  });
}
