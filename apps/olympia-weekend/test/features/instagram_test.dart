import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_weekend/features/instagram.dart';

void main() {
  test('builds app URL', () {
    expect(instagramAppUrl('cbum').toString(),
        'instagram://user?username=cbum');
  });

  test('builds web URL', () {
    expect(instagramWebUrl('cbum').toString(),
        'https://instagram.com/cbum');
  });
}
