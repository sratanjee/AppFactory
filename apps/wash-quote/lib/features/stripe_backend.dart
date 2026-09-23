import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Base URL of the shared factory backend (see `backend/` at the repo
/// root). The path is wired via --dart-define at build time so preview /
/// prod / staging can point at different environments.
final backendBaseUrlProvider = Provider<Uri>((ref) {
  const raw = String.fromEnvironment('BACKEND_BASE_URL');
  if (raw.isEmpty) {
    return Uri.parse('https://appfactory-backend.fly.dev');
  }
  return Uri.parse(raw);
});

/// Response from the Stripe payment-link creator. Only the URL matters
/// client-side; expiry lives on the server.
class StripeLinkResult {
  const StripeLinkResult({required this.url});
  final String url;
}

class StripeBackend {
  StripeBackend({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final Uri baseUrl;
  final http.Client _client;

  Future<StripeLinkResult> createPaymentLink({
    required int amountCents,
    required String currency,
    required int jobNumber,
    required String businessName,
  }) async {
    final uri = baseUrl.resolve('/v1/stripe/payment-links');
    final body = jsonEncode({
      'amount_cents': amountCents,
      'currency': currency,
      'job_number': jobNumber,
      'business_name': businessName,
    });
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw StripeBackendException(
        'Payment link request failed (${response.statusCode})',
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final url = decoded['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const StripeBackendException('No url in response');
    }
    return StripeLinkResult(url: url);
  }
}

class StripeBackendException implements Exception {
  const StripeBackendException(this.message);
  final String message;

  @override
  String toString() => 'StripeBackendException: $message';
}

final stripeBackendProvider = Provider<StripeBackend>((ref) {
  final base = ref.watch(backendBaseUrlProvider);
  return StripeBackend(baseUrl: base);
});

/// Silence the unused-import warning on debug builds that don't reach
/// this reference. Removing the top-level dart:io import breaks
/// Platform.localeName in Money helpers if they get bundled here later.
// ignore: unused_element
bool get _debugKeepsPlatform => kDebugMode && Platform.numberOfProcessors > 0;
