import 'dart:io';

import 'package:args/args.dart';
import 'package:monetize/asc_client.dart';
import 'package:monetize/product_plan.dart';
import 'package:monetize/rc_client.dart';
import 'package:path/path.dart' as p;
import 'package:scaffold/factory_config.dart';
import 'package:scaffold/spec.dart';

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addFlag('dry-run', negatable: false,
        help: 'Print the plan without calling any store or RC API.')
    ..addFlag('skip-asc', negatable: false,
        help: 'Skip App Store Connect calls (credentials not wired).')
    ..addFlag('skip-play', negatable: false,
        help: 'Skip Google Play calls (Play API integration not wired in v0.1).')
    ..addFlag('skip-rc', negatable: false,
        help: 'Skip RevenueCat calls.')
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show this help.');

  final args = parser.parse(argv);
  if (args['help'] as bool || args.rest.isEmpty) {
    stdout
      ..writeln('Usage: dart run monetize <spec-file>')
      ..writeln()
      ..writeln(parser.usage);
    exit(0);
  }

  final specPath = args.rest.first;
  final specFile = File(specPath);
  if (!specFile.existsSync()) {
    stderr.writeln('Spec file not found: $specPath');
    exit(1);
  }

  final repoRoot = _findRepoRoot(Directory.current);
  if (repoRoot == null) {
    stderr.writeln('Could not locate repo root.');
    exit(1);
  }

  final config = await FactoryConfig.load(repoRoot);
  final spec = SpecParser(
    await specFile.readAsString(),
    bundlePrefix: config.require('BUNDLE_PREFIX'),
  ).parse();

  final plan = ProductPlan.fromSpec(spec);
  if (plan.isEmpty) {
    stderr.writeln('No products to create for ${spec.slug} '
        '(spec §6 lists no chargeable plans).');
    exit(0);
  }

  stdout.writeln('Plan for ${spec.slug} (${plan.products.length} products):');
  for (final p in plan.products) {
    stdout.writeln('  ${p.storeProductId} → ${p.rcPackageId} '
        '(${p.kind.name}, \$${p.priceUsd.toStringAsFixed(2)}, '
        'trial ${p.freeTrialDays}d)');
  }

  if (args['dry-run'] as bool) {
    stdout.writeln('[dry-run] no API calls made.');
    exit(0);
  }

  // ---- App Store Connect ----
  if (!(args['skip-asc'] as bool)) {
    final issuerId = config.get('DEV_ACCOUNT_A_ASC_ISSUER_ID');
    final keyId = config.get('DEV_ACCOUNT_A_ASC_KEY_ID');
    final keyPath = config.get('DEV_ACCOUNT_A_ASC_KEY_PATH');
    if (issuerId.isEmpty || keyId.isEmpty || keyPath.isEmpty) {
      stderr.writeln('[skip] ASC — credentials not wired in factory.config.');
    } else {
      final key = await File(keyPath).readAsString();
      final asc = AscClient(
        issuerId: issuerId,
        keyId: keyId,
        privateKeyP8: key,
      );
      await _runAsc(asc, spec, plan);
    }
  }

  // ---- Google Play ----
  if (!(args['skip-play'] as bool)) {
    stderr.writeln('[stub] Google Play — Play Developer API integration '
        'lands in v0.2 (needs service-account JSON + androidpublisher scope).');
  }

  // ---- RevenueCat ----
  if (!(args['skip-rc'] as bool)) {
    final projectId = config.get('REVENUECAT_PROJECT_ID');
    final token = config.get('REVENUECAT_API_V2_TOKEN');
    if (projectId.isEmpty || token.isEmpty) {
      stderr.writeln('[skip] RC — REVENUECAT_PROJECT_ID or '
          'REVENUECAT_API_V2_TOKEN missing in factory.config.');
    } else {
      final rc = RcClient(projectId: projectId, apiToken: token);
      await _runRc(rc, spec, plan);
    }
  }

  stdout.writeln('done.');
}

Future<void> _runAsc(AscClient asc, Spec spec, ProductPlan plan) async {
  stdout.writeln('ASC: finding app by bundle ID ${spec.bundleIdRaw}');
  final appId = await asc.findAppByBundleId(spec.bundleIdRaw);
  if (appId == null) {
    stderr.writeln('ASC: no app found for bundle ID ${spec.bundleIdRaw}. '
        'Create the app record in App Store Connect first.');
    return;
  }
  final existing = await asc.listExistingProductIds(appId);
  for (final p in plan.products) {
    if (existing.contains(p.storeProductId)) {
      stdout.writeln('ASC: ${p.storeProductId} already exists — skipping create.');
      continue;
    }
    if (p.kind == ProductKind.nonConsumable) {
      await asc.createNonConsumable(
        appId: appId,
        productId: p.storeProductId,
        referenceName: p.displayName,
      );
    } else {
      await asc.createAutoRenewableSubscription(
        appId: appId,
        productId: p.storeProductId,
        referenceName: p.displayName,
        subscriptionGroupReference: '${spec.slug}_pro_group',
      );
    }
    stdout.writeln('ASC: created ${p.storeProductId}');
  }

  // Resource IDs (subs + IAPs) — needed for prices, localizations,
  // intro offers. `listExistingProductIds` only returns product-id strings.
  final resources = await asc.listExistingProducts(appId);
  for (final p in plan.products) {
    final entry = resources[p.storeProductId];
    if (entry == null) {
      stderr.writeln('ASC: ${p.storeProductId} not found on server after '
          'create — skipping localization/pricing.');
      continue;
    }
    final resourceId = entry['id']!;
    final isSubscription = p.kind == ProductKind.autoRenewableSubscription;

    try {
      final locName = _shortName(p);
      if (isSubscription) {
        await asc.addSubscriptionLocalization(
          subscriptionId: resourceId,
          locale: 'en-US',
          name: locName,
          description: '${spec.appName} Pro membership.',
        );
      } else {
        await asc.addInAppPurchaseLocalization(
          iapId: resourceId,
          locale: 'en-US',
          name: locName,
          description: '${spec.appName} Pro — one-time unlock.',
        );
      }
      stdout.writeln('ASC: en-US localization set for ${p.storeProductId}');
    } catch (e) {
      stderr.writeln('ASC: localization failed for ${p.storeProductId}: $e');
    }

    if (isSubscription) {
      try {
        await asc.ensureSubscriptionAvailableInUsa(subscriptionId: resourceId);
      } catch (e) {
        stderr.writeln('ASC: availability failed for ${p.storeProductId}: $e');
      }
    }

    try {
      final pricePointId = isSubscription
          ? await asc.findSubscriptionUsdPricePoint(
              subscriptionId: resourceId,
              priceUsd: p.priceUsd,
            )
          : await asc.findInAppPurchaseUsdPricePoint(
              iapId: resourceId,
              priceUsd: p.priceUsd,
            );
      if (pricePointId == null) {
        stderr.writeln(
            'ASC: no USD price point matched \$${p.priceUsd.toStringAsFixed(2)} '
            'for ${p.storeProductId} — skipping price.');
      } else if (isSubscription) {
        await asc.setSubscriptionPrice(
          subscriptionId: resourceId,
          pricePointId: pricePointId,
        );
        stdout.writeln('ASC: price set on ${p.storeProductId} '
            '(\$${p.priceUsd.toStringAsFixed(2)})');
      } else {
        await asc.setInAppPurchasePriceSchedule(
          iapId: resourceId,
          pricePointId: pricePointId,
        );
        stdout.writeln('ASC: price schedule set on ${p.storeProductId} '
            '(\$${p.priceUsd.toStringAsFixed(2)})');
      }
    } catch (e) {
      stderr.writeln('ASC: pricing failed for ${p.storeProductId}: $e');
    }

    if (isSubscription && p.freeTrialDays > 0) {
      try {
        await asc.addFreeTrialIntroductoryOffer(
          subscriptionId: resourceId,
          trialDays: p.freeTrialDays,
        );
        stdout.writeln('ASC: ${p.freeTrialDays}-day free trial added on '
            '${p.storeProductId}');
      } catch (e) {
        stderr.writeln('ASC: intro offer failed for ${p.storeProductId}: $e');
      }
    }
  }
}

String _shortName(Product p) {
  switch (p.rcPackageId) {
    case r'$rc_monthly':
      return 'Pro Monthly';
    case r'$rc_annual':
      return 'Pro Annual';
    case r'$rc_lifetime':
      return 'Pro Lifetime';
    case r'$rc_weekly':
      return 'Pro Weekly';
    default:
      return p.displayName;
  }
}

Future<void> _runRc(RcClient rc, Spec spec, ProductPlan plan) async {
  stdout.writeln('RC: ensuring entitlement + offering');
  await rc.ensureEntitlement(
    lookupKey: spec.monetization.revenueCatEntitlement,
    displayName: '${spec.appName} Pro',
  );
  final offeringId = await rc.ensureOffering(lookupKey: 'default');
  for (final p in plan.products) {
    await rc.upsertPackage(
      offeringId: offeringId,
      packageLookupKey: p.rcPackageId,
      displayName: p.displayName,
    );
    stdout.writeln('RC: package ${p.rcPackageId} ensured');
  }

  final apps = await rc.listApps();
  final iosAppId = apps.entries
      .firstWhere(
        (e) => e.value == 'app_store',
        orElse: () => const MapEntry('', ''),
      )
      .key;
  if (iosAppId.isEmpty) {
    stderr.writeln('RC: no app_store app under project — provision the iOS '
        'RC app first, then re-run to attach product linkage.');
    return;
  }

  for (final p in plan.products) {
    final productId = await rc.upsertProduct(
      rcAppId: iosAppId,
      storeIdentifier: p.storeProductId,
      productType: p.kind == ProductKind.nonConsumable
          ? 'non_consumable'
          : 'subscription',
      displayName: p.displayName,
      subscriptionLookupKey: _rcSubscriptionDuration(p),
    );
    stdout.writeln('RC: product ${p.storeProductId} upserted → $productId');

    final packageId = await rc.findPackageId(
      offeringId: offeringId,
      packageLookupKey: p.rcPackageId,
    );
    if (packageId == null) {
      stderr.writeln('RC: package ${p.rcPackageId} not found — cannot attach '
          '${p.storeProductId}.');
      continue;
    }
    try {
      await rc.attachProductToPackage(
        offeringId: offeringId,
        packageId: packageId,
        productId: productId,
      );
      stdout.writeln('RC: attached ${p.storeProductId} → ${p.rcPackageId}');
    } catch (e) {
      stderr.writeln('RC: attach failed ${p.storeProductId} → '
          '${p.rcPackageId}: $e');
    }
  }
}

String? _rcSubscriptionDuration(Product p) {
  if (p.kind != ProductKind.autoRenewableSubscription) return null;
  switch (p.rcPackageId) {
    case r'$rc_weekly':
      return 'P1W';
    case r'$rc_monthly':
      return 'P1M';
    case r'$rc_annual':
      return 'P1Y';
    default:
      return null;
  }
}

String? _findRepoRoot(Directory start) {
  var dir = start;
  while (true) {
    if (File(p.join(dir.path, 'CLAUDE.md')).existsSync() &&
        File(p.join(dir.path, 'factory.config')).existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}
