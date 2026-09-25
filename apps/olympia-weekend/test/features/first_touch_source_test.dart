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

  test('extracts referrer host from a full URL', () {
    expect(
      parseReferrerHost('https://www.google.com/search?q=olympia'),
      'www.google.com',
    );
    expect(
      parseReferrerHost('https://l.instagram.com/?u=https%3A%2F%2Folympiaweekend.app'),
      'l.instagram.com',
    );
  });

  test('referrer host handles empty / null / bare', () {
    expect(parseReferrerHost(null), isNull);
    expect(parseReferrerHost(''), isNull);
    expect(parseReferrerHost('not a url'), isNull);
  });
}
