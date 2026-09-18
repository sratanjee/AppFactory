import 'dart:convert';

import 'package:http/http.dart' as http;

/// RevenueCat v2 API wrapper. Docs: https://www.revenuecat.com/reference/api-v2
///
/// Creates offerings + packages + entitlements idempotently. Store product
/// linkage (Apple/Google product IDs) is added via the same endpoints
/// after the products exist on the store side.
class RcClient {
  RcClient({
    required this.projectId,
    required this.apiToken,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String projectId;
  final String apiToken;
  final http.Client _http;

  static const _base = 'https://api.revenuecat.com/v2';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Returns the id of the entitlement with lookup key `pro`, creating it
  /// if it doesn't exist.
  Future<String> ensureEntitlement({
    required String lookupKey,
    required String displayName,
  }) async {
    final list = await _http.get(
      Uri.parse('$_base/projects/$projectId/entitlements'),
      headers: _headers,
    );
    if (list.statusCode == 200) {
      final items =
          (jsonDecode(list.body) as Map<String, dynamic>)['items']
              as List<dynamic>;
      for (final row in items) {
        if ((row as Map<String, dynamic>)['lookup_key'] == lookupKey) {
          return row['id'] as String;
        }
      }
    }
    final create = await _http.post(
      Uri.parse('$_base/projects/$projectId/entitlements'),
      headers: _headers,
      body: jsonEncode({
        'lookup_key': lookupKey,
        'display_name': displayName,
      }),
    );
    _assertOk(create, 'createEntitlement');
    return (jsonDecode(create.body) as Map<String, dynamic>)['id'] as String;
  }

  /// Returns the id of the offering with lookup key `default`, creating it
  /// if it doesn't exist.
  Future<String> ensureOffering({required String lookupKey}) async {
    final list = await _http.get(
      Uri.parse('$_base/projects/$projectId/offerings'),
      headers: _headers,
    );
    if (list.statusCode == 200) {
      final items =
          (jsonDecode(list.body) as Map<String, dynamic>)['items']
              as List<dynamic>;
      for (final row in items) {
        if ((row as Map<String, dynamic>)['lookup_key'] == lookupKey) {
          return row['id'] as String;
        }
      }
    }
    final create = await _http.post(
      Uri.parse('$_base/projects/$projectId/offerings'),
      headers: _headers,
      body: jsonEncode({
        'lookup_key': lookupKey,
        'display_name': lookupKey,
      }),
    );
    _assertOk(create, 'createOffering');
    return (jsonDecode(create.body) as Map<String, dynamic>)['id'] as String;
  }

  /// Adds a package to an offering. `packageLookupKey` is one of the
  /// reserved `$rc_annual` / `$rc_monthly` / `$rc_lifetime` / `$rc_weekly`.
  Future<void> upsertPackage({
    required String offeringId,
    required String packageLookupKey,
    required String displayName,
  }) async {
    final res = await _http.post(
      Uri.parse('$_base/projects/$projectId/offerings/$offeringId/packages'),
      headers: _headers,
      body: jsonEncode({
        'lookup_key': packageLookupKey,
        'display_name': displayName,
      }),
    );
    if (res.statusCode == 409) return; // already exists
    _assertOk(res, 'upsertPackage');
  }

  void _assertOk(http.Response res, String op) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw StateError('RC $op failed ${res.statusCode}: ${res.body}');
  }
}
