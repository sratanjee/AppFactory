import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;

/// Thin wrapper over App Store Connect's REST API (v3).
///
/// Docs: https://developer.apple.com/documentation/appstoreconnectapi
class AscClient {
  AscClient({
    required this.issuerId,
    required this.keyId,
    required this.privateKeyP8,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String issuerId;
  final String keyId;
  final String privateKeyP8;
  final http.Client _http;

  static const _base = 'https://api.appstoreconnect.apple.com/v1';

  String _makeToken() {
    final jwt = JWT(
      {
        'iss': issuerId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 60 * 15,
        'aud': 'appstoreconnect-v1',
      },
      header: {'alg': 'ES256', 'kid': keyId, 'typ': 'JWT'},
    );
    return jwt.sign(ECPrivateKey(privateKeyP8), algorithm: JWTAlgorithm.ES256);
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${_makeToken()}',
        'Content-Type': 'application/json',
      };

  /// Returns the id of the app resource whose bundle ID matches.
  /// Returns null if not found. Caller must have already created the app
  /// record in ASC (the API doesn't let us create apps, only in-app
  /// products under an existing app).
  Future<String?> findAppByBundleId(String bundleId) async {
    final uri = Uri.parse('$_base/apps?filter[bundleId]=$bundleId');
    final res = await _http.get(uri, headers: _headers);
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    if (data.isEmpty) return null;
    return (data.first as Map<String, dynamic>)['id'] as String;
  }

  /// Lists existing in-app-purchase product IDs for an app.
  Future<Set<String>> listExistingProductIds(String appId) async {
    final subs = await _http.get(
      Uri.parse('$_base/apps/$appId/subscriptionGroups?include=subscriptions'),
      headers: _headers,
    );
    final iaps = await _http.get(
      Uri.parse('$_base/apps/$appId/inAppPurchasesV2'),
      headers: _headers,
    );
    final ids = <String>{};
    for (final body in [subs.body, iaps.body]) {
      if (body.isEmpty) continue;
      try {
        final parsed = jsonDecode(body) as Map<String, dynamic>;
        final included = (parsed['included'] as List<dynamic>?) ?? const [];
        final data = (parsed['data'] as List<dynamic>?) ?? const [];
        for (final row in [...included, ...data]) {
          final attrs = (row as Map<String, dynamic>)['attributes']
              as Map<String, dynamic>?;
          final pid = attrs?['productId'] as String?;
          if (pid != null) ids.add(pid);
        }
      } on FormatException {
        // fall through
      }
    }
    return ids;
  }

  /// Creates a non-consumable IAP product. Returns the created resource id.
  ///
  /// Uses the v2 create endpoint at `POST /v2/inAppPurchases` — the
  /// v1 `/v1/inAppPurchasesV2` path only exists as a read-side
  /// relationship (GET /v1/apps/{id}/inAppPurchasesV2) and returns
  /// 404 on POST.
  Future<String> createNonConsumable({
    required String appId,
    required String productId,
    required String referenceName,
  }) async {
    final res = await _http.post(
      Uri.parse('https://api.appstoreconnect.apple.com/v2/inAppPurchases'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'inAppPurchases',
          'attributes': {
            'productId': productId,
            'inAppPurchaseType': 'NON_CONSUMABLE',
            'name': referenceName,
          },
          'relationships': {
            'app': {
              'data': {'type': 'apps', 'id': appId},
            },
          },
        },
      }),
    );
    _assertOk(res, 'createNonConsumable');
    return ((jsonDecode(res.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>)['id'] as String;
  }

  /// Creates an auto-renewable subscription. Requires a subscription group
  /// (creates one on demand if none exists for this app).
  Future<String> createAutoRenewableSubscription({
    required String appId,
    required String productId,
    required String referenceName,
    required String subscriptionGroupReference,
  }) async {
    final groupId = await _getOrCreateSubscriptionGroup(
      appId: appId,
      reference: subscriptionGroupReference,
    );
    final res = await _http.post(
      Uri.parse('$_base/subscriptions'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'subscriptions',
          'attributes': {
            'productId': productId,
            'name': referenceName,
            'subscriptionPeriod': 'ONE_YEAR',
          },
          'relationships': {
            'group': {
              'data': {'type': 'subscriptionGroups', 'id': groupId},
            },
          },
        },
      }),
    );
    _assertOk(res, 'createAutoRenewableSubscription');
    return ((jsonDecode(res.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>)['id'] as String;
  }

  Future<String> _getOrCreateSubscriptionGroup({
    required String appId,
    required String reference,
  }) async {
    final list = await _http.get(
      Uri.parse('$_base/apps/$appId/subscriptionGroups'),
      headers: _headers,
    );
    if (list.statusCode == 200) {
      final data =
          (jsonDecode(list.body) as Map<String, dynamic>)['data']
              as List<dynamic>;
      for (final row in data) {
        final attrs = (row as Map<String, dynamic>)['attributes']
            as Map<String, dynamic>;
        if (attrs['referenceName'] == reference) {
          return row['id'] as String;
        }
      }
    }
    final create = await _http.post(
      Uri.parse('$_base/subscriptionGroups'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'subscriptionGroups',
          'attributes': {'referenceName': reference},
          'relationships': {
            'app': {
              'data': {'type': 'apps', 'id': appId},
            },
          },
        },
      }),
    );
    _assertOk(create, 'createSubscriptionGroup');
    return ((jsonDecode(create.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>)['id'] as String;
  }

  void _assertOk(http.Response res, String op) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw StateError('ASC $op failed ${res.statusCode}: ${res.body}');
  }
}
