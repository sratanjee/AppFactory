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
      stdout.writeln('ASC: ${p.storeProductId} already exists — skipping.');
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
