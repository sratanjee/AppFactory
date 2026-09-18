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

  /// Returns the RC package id for a given offering + lookup key, or
  /// null if not found. Needed to attach products.
  Future<String?> findPackageId({
    required String offeringId,
    required String packageLookupKey,
  }) async {
    final res = await _http.get(
      Uri.parse('$_base/projects/$projectId/offerings/$offeringId/packages?limit=200'),
      headers: _headers,
    );
    if (res.statusCode != 200) return null;
    final items = (jsonDecode(res.body) as Map<String, dynamic>)['items']
        as List<dynamic>;
    for (final row in items) {
      if ((row as Map<String, dynamic>)['lookup_key'] == packageLookupKey) {
        return row['id'] as String;
      }
    }
    return null;
  }

  // ---- Apps + products (store-side linkage) --------------------------

  /// Lists RC "apps" under the project — one per platform (app_store,
  /// play_store, amazon, etc.). Returned as { rcAppId → type }.
  Future<Map<String, String>> listApps() async {
    final res = await _http.get(
      Uri.parse('$_base/projects/$projectId/apps?limit=100'),
      headers: _headers,
    );
    _assertOk(res, 'listApps');
    final items = (jsonDecode(res.body) as Map<String, dynamic>)['items']
        as List<dynamic>;
    return {
      for (final row in items)
        (row as Map<String, dynamic>)['id'] as String:
            row['type'] as String,
    };
  }

  /// Creates or upserts a product record for a store product identifier.
  /// `productType` is 'subscription' or 'non_subscription'. Returns the
  /// RC product id. Idempotent via prior list lookup.
  ///
  /// RC v2 products are project-scoped (not nested under app) and
  /// reference the RC app id via `app_id` in the body.
  Future<String> upsertProduct({
    required String rcAppId,
    required String storeIdentifier,
    required String productType,
    required String displayName,
    String? subscriptionLookupKey,
  }) async {
    final list = await _http.get(
      Uri.parse(
        '$_base/projects/$projectId/products?limit=200',
      ),
      headers: _headers,
    );
    if (list.statusCode == 200) {
      final items = (jsonDecode(list.body) as Map<String, dynamic>)['items']
          as List<dynamic>;
      for (final row in items) {
        final m = row as Map<String, dynamic>;
        if (m['store_identifier'] == storeIdentifier &&
            m['app_id'] == rcAppId) {
          return m['id'] as String;
        }
      }
    }
    // Note: RC v2 rejects a `subscription: {duration}` block for real
    // store products — it re-reads that info from Apple/Google. Only
    // simulated products need it here. The `subscriptionLookupKey`
    // parameter is retained on the method for that future case.
    final _ = subscriptionLookupKey;
    final body = <String, dynamic>{
      'store_identifier': storeIdentifier,
      'app_id': rcAppId,
      'type': productType,
      'display_name': displayName,
    };
    final res = await _http.post(
      Uri.parse('$_base/projects/$projectId/products'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _assertOk(res, 'upsertProduct');
    return (jsonDecode(res.body) as Map<String, dynamic>)['id'] as String;
  }

  /// Attaches a product to a package via RC v2's action endpoint.
  /// Idempotent: if the same product is already attached, no-op. If
  /// a different product from the same app is attached, that product
  /// is detached first (a package can only hold one product per app).
  Future<void> attachProductToPackage({
    required String offeringId,
    required String packageId,
    required String productId,
    String? appId,
    bool eligibleForIntroPrice = false,
  }) async {
    // Inspect current attachments.
    final list = await _http.get(
      Uri.parse('$_base/projects/$projectId/packages/$packageId/products'),
      headers: _headers,
    );
    if (list.statusCode == 200) {
      final items = (jsonDecode(list.body) as Map<String, dynamic>)['items']
          as List<dynamic>;
      final existing = <String>[];
      for (final row in items) {
        final rowMap = row as Map<String, dynamic>;
        final pid = (rowMap['product'] as Map<String, dynamic>?)?['id']
            as String? ??
            rowMap['product_id'] as String?;
        if (pid == null) continue;
        if (pid == productId) return; // already attached
        existing.add(pid);
      }
      // Detach any incompatible siblings so the attach can succeed.
      if (existing.isNotEmpty) {
        final detach = await _http.post(
          Uri.parse(
            '$_base/projects/$projectId/packages/$packageId/actions/detach_products',
          ),
          headers: _headers,
          body: jsonEncode({'product_ids': existing}),
        );
        if (detach.statusCode < 200 || detach.statusCode >= 300) {
          _assertOk(detach, 'detachProductsFromPackage');
        }
      }
    }

    final res = await _http.post(
      Uri.parse(
        '$_base/projects/$projectId/packages/$packageId/actions/attach_products',
      ),
      headers: _headers,
      body: jsonEncode({
        'products': [
          {
            'product_id': productId,
            'eligibility_criteria':
                eligibleForIntroPrice ? 'google_sdk_lt_6' : 'all',
          }
        ],
      }),
    );
    if (res.statusCode == 409) return;
    _assertOk(res, 'attachProductToPackage');
  }

  void _assertOk(http.Response res, String op) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw StateError('RC $op failed ${res.statusCode}: ${res.body}');
  }
}
