import 'package:scaffold/spec.dart';

/// One store product to create.
class Product {
  const Product({
    required this.storeProductId,
    required this.rcPackageId,
    required this.kind,
    required this.priceUsd,
    required this.freeTrialDays,
    required this.displayName,
  });

  /// App Store Connect / Google Play product identifier.
  /// Convention: `<slug_underscored>_pro_<period>`.
  final String storeProductId;

  /// RevenueCat package identifier, `$rc_<period>`.
  final String rcPackageId;

  final ProductKind kind;
  final double priceUsd;
  final int freeTrialDays;
  final String displayName;
}

enum ProductKind { autoRenewableSubscription, nonConsumable }

/// Parses a spec's §6 monetization block into a list of concrete products.
///
/// Handles the queue's variations:
///   - "$X.XX/yr" → annual subscription
///   - "$X.XX/mo" → monthly subscription
///   - "$X.XX one-time" or "$X.XX" for lifetime → non-consumable
///   - "none", "no", empty → skip
///   - "7-day, on annual only" → 7 day trial on the annual sub
class ProductPlan {
  ProductPlan({required this.slugUnderscored, required this.products});

  factory ProductPlan.fromSpec(Spec spec) {
    final slugU = spec.slugUnderscored;
    final products = <Product>[];

    final trialDays = _parseTrialDays(spec.monetization.freeTrial);

    if (_hasPrice(spec.monetization.weeklyPrice)) {
      final price = _parseUsd(spec.monetization.weeklyPrice);
      if (price != null) {
        products.add(Product(
          storeProductId: '${slugU}_pro_weekly',
          rcPackageId: r'$rc_weekly',
          kind: ProductKind.autoRenewableSubscription,
          priceUsd: price,
          freeTrialDays: 0,
          displayName: '${spec.appName} Pro — Weekly',
        ));
      }
    }
    // The queue's specs use the Weekly-price field to note the monthly
    // plan when there's no weekly ("Weekly price: none (monthly instead: $9.99/mo)").
    final monthly = _extractMonthly(spec.monetization.weeklyPrice);
    if (monthly != null) {
      products.add(Product(
        storeProductId: '${slugU}_pro_monthly',
        rcPackageId: r'$rc_monthly',
        kind: ProductKind.autoRenewableSubscription,
        priceUsd: monthly,
        freeTrialDays: 0,
        displayName: '${spec.appName} Pro — Monthly',
      ));
    }

    if (_hasPrice(spec.monetization.annualPrice)) {
      final price = _parseUsd(spec.monetization.annualPrice);
      if (price != null) {
        products.add(Product(
          storeProductId: '${slugU}_pro_annual',
          rcPackageId: r'$rc_annual',
          kind: ProductKind.autoRenewableSubscription,
          priceUsd: price,
          freeTrialDays: trialDays,
          displayName: '${spec.appName} Pro — Annual',
        ));
      }
    }

    if (_hasPrice(spec.monetization.lifetimePrice)) {
      final price = _parseUsd(spec.monetization.lifetimePrice);
      if (price != null) {
        products.add(Product(
          storeProductId: '${slugU}_pro_lifetime',
          rcPackageId: r'$rc_lifetime',
          kind: ProductKind.nonConsumable,
          priceUsd: price,
          freeTrialDays: 0,
          displayName: '${spec.appName} Pro — Lifetime',
        ));
      }
    }

    return ProductPlan(slugUnderscored: slugU, products: products);
  }

  final String slugUnderscored;
  final List<Product> products;

  bool get isEmpty => products.isEmpty;
}

bool _hasPrice(String? s) {
  if (s == null) return false;
  final t = s.trim().toLowerCase();
  if (t.isEmpty) return false;
  if (t.startsWith('none') || t.startsWith('no ') || t == 'no') return false;
  return RegExp(r'\$\d').hasMatch(s);
}

double? _parseUsd(String s) {
  final match = RegExp(r'\$([0-9]+(?:\.[0-9]+)?)').firstMatch(s);
  if (match == null) return null;
  return double.tryParse(match.group(1)!);
}

double? _extractMonthly(String s) {
  final match = RegExp(r'\$([0-9]+(?:\.[0-9]+)?)\s*/\s*mo').firstMatch(s);
  if (match == null) return null;
  return double.tryParse(match.group(1)!);
}

int _parseTrialDays(String s) {
  final match = RegExp(r'([0-9]+)\s*-\s*day').firstMatch(s.toLowerCase());
  if (match == null) return 0;
  return int.tryParse(match.group(1)!) ?? 0;
}
