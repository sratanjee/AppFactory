import 'dart:io';

import 'package:scaffold/spec.dart';
import 'package:scaffold/validate.dart';
import 'package:test/test.dart';

Future<Spec> _loadFixture() async {
  final content = await File('test/fixtures/2026-09-17-example.md').readAsString();
  return SpecParser(content).parse();
}

SpecValidator _validator({Set<String>? existing}) => SpecValidator(
      bundlePrefix: 'com.appfactory',
      existingSlugs: existing ?? const <String>{},
    );

void main() {
  test('fixture spec parses cleanly with matching bundle prefix', () async {
    // The fixture's bundle ID is wrapped in backticks by the parser; the
    // validator compares literal strings so we strip them for this baseline.
    final raw = await _loadFixture();
    final spec = _stripBundleTicks(raw);
    final report = _validator().validate(spec);
    expect(report.issues, isEmpty, reason: report.toMarkdown());
  });

  test('rejects a slug that clashes with an existing directory', () async {
    final spec = _stripBundleTicks(await _loadFixture());
    final report = _validator(existing: {'example-habits'}).validate(spec);
    expect(report.issues, isNotEmpty);
    expect(report.issues.first.field, 'slug');
  });

  test('rejects a bundle ID that does not match the prefix + slug', () async {
    final base = _stripBundleTicks(await _loadFixture());
    final spec = _copyWithBundleId(base, 'com.other.examplehabits');
    final report = _validator().validate(spec);
    expect(
      report.issues.any((i) => i.field == 'bundleId'),
      isTrue,
    );
  });

  test('report markdown lists issues', () {
    const report = ValidationReport([
      ValidationIssue('slug', 'bad slug'),
      ValidationIssue('accentHex', 'not hex'),
    ]);
    final md = report.toMarkdown();
    expect(md, contains('bad slug'));
    expect(md, contains('not hex'));
  });
}

Spec _stripBundleTicks(Spec s) => _copyWithBundleId(
      s,
      s.bundleIdRaw.replaceAll('`', ''),
    );

Spec _copyWithBundleId(Spec s, String newBundleId) => Spec(
      appName: s.appName,
      iosSubtitle: s.iosSubtitle,
      androidShortDescription: s.androidShortDescription,
      slug: s.slug,
      bundleIdRaw: newBundleId,
      storeCategory: s.storeCategory,
      developerAccount: s.developerAccount,
      factoryCategory: s.factoryCategory,
      job: s.job,
      who: s.who,
      where: s.where,
      whyPay: s.whyPay,
      screens: s.screens,
      dataModelRaw: s.dataModelRaw,
      backendMode: s.backendMode,
      syncMode: s.syncMode,
      nativeSurfaces: s.nativeSurfaces,
      monetization: s.monetization,
      onboardingSteps: s.onboardingSteps,
      designNotes: s.designNotes,
      storeSeeds: s.storeSeeds,
      outOfScope: s.outOfScope,
      doneChecks: s.doneChecks,
    );
