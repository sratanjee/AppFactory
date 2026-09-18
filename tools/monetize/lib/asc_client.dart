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

  // ---- Existing-product lookups (used by orchestrator to attach
  //      localizations / prices to products created on earlier runs) ----

  /// Returns { productId → { 'id': resourceId, 'type': 'subscriptions' | 'inAppPurchases' } }
  /// for every existing IAP + subscription under the app. Used by the
  /// orchestrator to look up resource IDs when re-running against
  /// products that already exist from a prior run.
  Future<Map<String, Map<String, String>>> listExistingProducts(
    String appId,
  ) async {
    final out = <String, Map<String, String>>{};

    // Subscriptions: walk groups, then GET each group's subscriptions.
    // The `?include=subscriptions` variant doesn't populate `included`
    // reliably across all accounts, so we do the two-step lookup.
    final groupsRes = await _http.get(
      Uri.parse('$_base/apps/$appId/subscriptionGroups?limit=200'),
      headers: _headers,
    );
    if (groupsRes.statusCode == 200) {
      final body = jsonDecode(groupsRes.body) as Map<String, dynamic>;
      final groups = (body['data'] as List<dynamic>?) ?? const [];
      for (final g in groups) {
        final groupId = (g as Map<String, dynamic>)['id'] as String;
        final subsRes = await _http.get(
          Uri.parse('$_base/subscriptionGroups/$groupId/subscriptions?limit=200'),
          headers: _headers,
        );
        if (subsRes.statusCode != 200) continue;
        final subsBody = jsonDecode(subsRes.body) as Map<String, dynamic>;
        final data = (subsBody['data'] as List<dynamic>?) ?? const [];
        for (final row in data) {
          final m = row as Map<String, dynamic>;
          final attrs = m['attributes'] as Map<String, dynamic>;
          final pid = attrs['productId'] as String?;
          if (pid != null) {
            out[pid] = {'id': m['id'] as String, 'type': 'subscriptions'};
          }
        }
      }
    }

    final iaps = await _http.get(
      Uri.parse('$_base/apps/$appId/inAppPurchasesV2?limit=200'),
      headers: _headers,
    );
    if (iaps.statusCode == 200) {
      final body = jsonDecode(iaps.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>?) ?? const [];
      for (final row in data) {
        final m = row as Map<String, dynamic>;
        final attrs = m['attributes'] as Map<String, dynamic>;
        final pid = attrs['productId'] as String?;
        if (pid != null) {
          out[pid] = {'id': m['id'] as String, 'type': 'inAppPurchases'};
        }
      }
    }

    return out;
  }

  // ---- Localizations -------------------------------------------------

  /// Adds an en-US localization to a subscription. Returns null (and
  /// prints a warning) if the localization already exists.
  Future<void> addSubscriptionLocalization({
    required String subscriptionId,
    required String locale,
    required String name,
    String? description,
  }) async {
    final res = await _http.post(
      Uri.parse('$_base/subscriptionLocalizations'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'subscriptionLocalizations',
          'attributes': {
            'locale': locale,
            'name': name,
            if (description != null) 'description': description,
          },
          'relationships': {
            'subscription': {
              'data': {'type': 'subscriptions', 'id': subscriptionId},
            },
          },
        },
      }),
    );
    if (res.statusCode == 409) return; // already exists
    _assertOk(res, 'addSubscriptionLocalization');
  }

  Future<void> addInAppPurchaseLocalization({
    required String iapId,
    required String locale,
    required String name,
    String? description,
  }) async {
    final res = await _http.post(
      Uri.parse('$_base/inAppPurchaseLocalizations'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'inAppPurchaseLocalizations',
          'attributes': {
            'locale': locale,
            'name': name,
            if (description != null) 'description': description,
          },
          'relationships': {
            'inAppPurchaseV2': {
              'data': {'type': 'inAppPurchases', 'id': iapId},
            },
          },
        },
      }),
    );
    if (res.statusCode == 409) return;
    _assertOk(res, 'addInAppPurchaseLocalization');
  }

  // ---- Price points --------------------------------------------------

  /// Fetches Apple's USA price points for a subscription and returns
  /// the point ID whose customerPrice equals the given USD amount
  /// (formatted as "X.XX"). Returns null if no exact match.
  Future<String?> findSubscriptionUsdPricePoint({
    required String subscriptionId,
    required double priceUsd,
  }) async {
    final target = priceUsd.toStringAsFixed(2);
    var url = Uri.parse(
      '$_base/subscriptions/$subscriptionId/pricePoints'
      '?filter[territory]=USA&include=territory&limit=200',
    );
    while (true) {
      final res = await _http.get(url, headers: _headers);
      _assertOk(res, 'listSubscriptionPricePoints');
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>?) ?? const [];
      for (final row in data) {
        final m = row as Map<String, dynamic>;
        final attrs = m['attributes'] as Map<String, dynamic>;
        final price = attrs['customerPrice'] as String?;
        final territoryRel = ((m['relationships']
                as Map<String, dynamic>?)?['territory']
            as Map<String, dynamic>?)?['data'] as Map<String, dynamic>?;
        final territoryId = territoryRel?['id'] as String?;
        if (price == target && (territoryId == null || territoryId == 'USA')) {
          return m['id'] as String;
        }
      }
      final next = ((body['links'] as Map<String, dynamic>?)?['next']) as String?;
      if (next == null) return null;
      url = Uri.parse(next);
    }
  }

  Future<String?> findInAppPurchaseUsdPricePoint({
    required String iapId,
    required double priceUsd,
  }) async {
    final target = priceUsd.toStringAsFixed(2);
    // IAP price points live under a v2 relationship (not v1). The v1
    // `/inAppPurchases/{id}/pricePoints` path is where the v2 iap /
    // v1 path split lands as a 404 "relationship does not exist".
    var url = Uri.parse(
      'https://api.appstoreconnect.apple.com/v2/inAppPurchases/$iapId'
      '/pricePoints?filter[territory]=USA&limit=200',
    );
    while (true) {
      final res = await _http.get(url, headers: _headers);
      _assertOk(res, 'listInAppPurchasePricePoints');
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>?) ?? const [];
      for (final row in data) {
        final m = row as Map<String, dynamic>;
        final price = (m['attributes'] as Map<String, dynamic>)['customerPrice']
            as String?;
        if (price == target) return m['id'] as String;
      }
      final next = ((body['links'] as Map<String, dynamic>?)?['next']) as String?;
      if (next == null) return null;
      url = Uri.parse(next);
    }
  }

  /// Ensures the subscription is available in USA (base territory).
  /// A subscription without any territory availability can't be priced.
  /// Idempotent — 409 means availability already exists.
  Future<void> ensureSubscriptionAvailableInUsa({
    required String subscriptionId,
  }) async {
    final res = await _http.post(
      Uri.parse('$_base/subscriptionAvailabilities'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'subscriptionAvailabilities',
          'attributes': {'availableInNewTerritories': true},
          'relationships': {
            'subscription': {
              'data': {'type': 'subscriptions', 'id': subscriptionId},
            },
            'availableTerritories': {
              'data': [
                {'type': 'territories', 'id': 'USA'},
              ],
            },
          },
        },
      }),
    );
    if (res.statusCode == 409) return;
    _assertOk(res, 'ensureSubscriptionAvailableInUsa');
  }

  /// Sets a subscription's USA base price. Apple auto-equalises other
  /// territories from this base when a base territory is set.
  Future<void> setSubscriptionPrice({
    required String subscriptionId,
    required String pricePointId,
  }) async {
    final existing = await _http.get(
      Uri.parse(
        '$_base/subscriptions/$subscriptionId/prices?filter[territory]=USA&limit=1',
      ),
      headers: _headers,
    );
    if (existing.statusCode == 200) {
      final data = ((jsonDecode(existing.body) as Map<String, dynamic>)['data']
          as List<dynamic>?) ?? const [];
      if (data.isNotEmpty) return; // already priced in USA
    }
    // POST /v1/subscriptionPrices creates a scheduled price change.
    // For a fresh subscription with no base price, ASC often rejects
    // with 409 ENTITY_ERROR.RELATIONSHIP.INVALID unless the base
    // territory is first configured via subscriptionAvailabilities.
    // We attempt the direct create; on 409 the caller falls back to
    // asking the user to set the price manually in ASC UI once.
    final res = await _http.post(
      Uri.parse('$_base/subscriptionPrices'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'subscriptionPrices',
          'attributes': {'startDate': null, 'preserveCurrentPrice': false},
          'relationships': {
            'subscription': {
              'data': {'type': 'subscriptions', 'id': subscriptionId},
            },
            'subscriptionPricePoint': {
              'data': {
                'type': 'subscriptionPricePoints',
                'id': pricePointId,
              },
            },
            'territory': {
              'data': {'type': 'territories', 'id': 'USA'},
            },
          },
        },
      }),
    );
    _assertOk(res, 'setSubscriptionPrice');
  }

  /// Sets a non-consumable IAP's price schedule using the "baseTerritory
  /// = USA" pattern; Apple auto-equalises other territories.
  Future<void> setInAppPurchasePriceSchedule({
    required String iapId,
    required String pricePointId,
  }) async {
    // Skip if the IAP already has a price schedule.
    final existing = await _http.get(
      Uri.parse('$_base/inAppPurchases/$iapId/iapPriceSchedule'),
      headers: _headers,
    );
    if (existing.statusCode == 200 &&
        (jsonDecode(existing.body) as Map<String, dynamic>)['data'] != null) {
      return;
    }
    final res = await _http.post(
      Uri.parse('$_base/inAppPurchasePriceSchedules'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'inAppPurchasePriceSchedules',
          'relationships': {
            'inAppPurchase': {
              'data': {'type': 'inAppPurchases', 'id': iapId},
            },
            'manualPrices': {
              'data': [
                {'type': 'inAppPurchasePrices', 'id': r'${price0}'},
              ],
            },
            'baseTerritory': {
              'data': {'type': 'territories', 'id': 'USA'},
            },
          },
        },
        'included': [
          {
            'id': r'${price0}',
            'type': 'inAppPurchasePrices',
            'attributes': {'startDate': null},
            'relationships': {
              'inAppPurchasePricePoint': {
                'data': {
                  'type': 'inAppPurchasePricePoints',
                  'id': pricePointId,
                },
              },
            },
          },
        ],
      }),
    );
    _assertOk(res, 'setInAppPurchasePriceSchedule');
  }

  // ---- Introductory offer -------------------------------------------

  /// Adds a free-trial introductory offer to a subscription for USA
  /// (Apple auto-equalises based on the same territory availability
  /// as the subscription itself). Idempotent: 409 → no-op.
  Future<void> addFreeTrialIntroductoryOffer({
    required String subscriptionId,
    required int trialDays,
  }) async {
    final duration = _durationForDays(trialDays);
    if (duration == null) {
      throw StateError(
        'Unsupported trial duration $trialDays days — must be 3, 7, 14, 30, 60, 90, 180, or 365.',
      );
    }
    final res = await _http.post(
      Uri.parse('$_base/subscriptionIntroductoryOffers'),
      headers: _headers,
      body: jsonEncode({
        'data': {
          'type': 'subscriptionIntroductoryOffers',
          'attributes': {
            'offerMode': 'FREE_TRIAL',
            'duration': duration,
            'startDate': null,
            'endDate': null,
          },
          'relationships': {
            'subscription': {
              'data': {'type': 'subscriptions', 'id': subscriptionId},
            },
            'territory': {
              'data': {'type': 'territories', 'id': 'USA'},
            },
          },
        },
      }),
    );
    if (res.statusCode == 409) return;
    _assertOk(res, 'addFreeTrialIntroductoryOffer');
  }

  String? _durationForDays(int days) {
    switch (days) {
      case 3: return 'THREE_DAYS';
      case 7: return 'ONE_WEEK';
      case 14: return 'TWO_WEEKS';
      case 30: return 'ONE_MONTH';
      case 60: return 'TWO_MONTHS';
      case 90: return 'THREE_MONTHS';
      case 180: return 'SIX_MONTHS';
      case 365: return 'ONE_YEAR';
      default: return null;
    }
  }

  void _assertOk(http.Response res, String op) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw StateError('ASC $op failed ${res.statusCode}: ${res.body}');
  }
}
