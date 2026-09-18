import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wash_quote/features/stripe_backend.dart';

void main() {
  test('createPaymentLink returns URL on 200', () async {
    final client = MockClient((req) async {
      expect(req.method, 'POST');
      expect(req.url.path, '/v1/stripe/payment-links');
      return http.Response(
        '{"url":"https://pay.stripe.com/deadbeef"}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final backend = StripeBackend(
      baseUrl: Uri.parse('https://backend.local'),
      client: client,
    );
    final result = await backend.createPaymentLink(
      amountCents: 4500,
      currency: 'USD',
      jobNumber: 1001,
      businessName: 'Blue Wave Wash',
    );
    expect(result.url, 'https://pay.stripe.com/deadbeef');
  });

  test('createPaymentLink throws on non-200', () async {
    final client = MockClient((req) async => http.Response('boom', 500));
    final backend = StripeBackend(
      baseUrl: Uri.parse('https://backend.local'),
      client: client,
    );
    expect(
      () => backend.createPaymentLink(
        amountCents: 100,
        currency: 'USD',
        jobNumber: 1,
        businessName: 'X',
      ),
      throwsA(isA<StripeBackendException>()),
    );
  });
}
