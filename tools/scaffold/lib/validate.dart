import 'package:scaffold/spec.dart';

class ValidationIssue {
  const ValidationIssue(this.field, this.message);
  final String field;
  final String message;

  @override
  String toString() => '[$field] $message';
}

class ValidationReport {
  const ValidationReport(this.issues);
  final List<ValidationIssue> issues;

  bool get isClean => issues.isEmpty;

  String toMarkdown() {
    if (isClean) return '# No open questions\n\nSpec parsed cleanly.\n';
    final b = StringBuffer()
      ..writeln('# Open questions')
      ..writeln()
      ..writeln('The scaffolder found ${issues.length} problem(s) in the '
          'spec. Fix these before re-running.')
      ..writeln();
    for (final i in issues) {
      b.writeln('- **${i.field}** — ${i.message}');
    }
    return b.toString();
  }
}

class SpecValidator {
  SpecValidator({required this.bundlePrefix, required this.existingSlugs});

  final String bundlePrefix;
  final Set<String> existingSlugs;

  ValidationReport validate(Spec spec) {
    final issues = <ValidationIssue>[];

    // Slug
    if (!RegExp(r'^[a-z][a-z0-9-]{2,23}$').hasMatch(spec.slug)) {
      issues.add(ValidationIssue(
        'slug',
        'Slug must be lowercase, hyphen-separated, start with a letter, and '
        '3–24 chars. Got "${spec.slug}".',
      ));
    }
    if (existingSlugs.contains(spec.slug)) {
      issues.add(ValidationIssue(
        'slug',
        'apps/${spec.slug}/ already exists. Pick a different slug or delete '
        'the existing directory.',
      ));
    }

    // Bundle ID — Apple bundle IDs can't have hyphens.
    final expectedBundleId = '$bundlePrefix.${spec.slug.replaceAll('-', '')}';
    if (spec.bundleIdRaw != expectedBundleId) {
      issues.add(ValidationIssue(
        'bundleId',
        'Bundle ID should be "$expectedBundleId" (BUNDLE_PREFIX + slug '
        'without hyphens). Got "${spec.bundleIdRaw}".',
      ));
    }

    // Screens 3–5
    if (spec.screens.length < 3 || spec.screens.length > 5) {
      issues.add(ValidationIssue(
        'screens',
        '§3 must have 3–5 screens. Got ${spec.screens.length}.',
      ));
    }
    for (final s in spec.screens) {
      if (s.name.isEmpty || s.purpose.isEmpty || s.keyInteraction.isEmpty) {
        issues.add(ValidationIssue(
          'screens.${s.index}',
          'Every screen needs a name, purpose, and key interaction.',
        ));
      }
    }

    // Accent hex
    if (!RegExp(r'^#?[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$')
        .hasMatch(spec.designNotes.accentHex)) {
      issues.add(ValidationIssue(
        'accentHex',
        '§8 accent color must be a 6- or 8-hex string. Got '
        '"${spec.designNotes.accentHex}".',
      ));
    }

    // Monetization — an app can opt out of the paywall by declaring
    // `Paywall placement: none` in §6. That's a factory-level override of
    // CLAUDE.md non-negotiable #3 and must be spelled out in the spec's
    // §0 deviations block. When it's on we skip the price + benefits
    // checks (and the onboarding count check below), since a free app
    // has no plans to price and no paywall to warm up for.
    // Spec authors often bold "**none**" or trail explanatory copy after
    // it (e.g. "**none** (overrides CLAUDE.md 3)"), so read the placement
    // liberally: strip markdown emphasis + brackets and match the leading
    // word.
    final placementNormalised = spec.monetization.paywallPlacement
        .toLowerCase()
        .replaceAll(RegExp(r'[*_`]'), '')
        .trim();
    final free = placementNormalised.startsWith('none');
    if (spec.monetization.paywallPlacement.isEmpty) {
      issues.add(const ValidationIssue(
        'monetization.paywallPlacement',
        '§6 paywall placement is required (use "none" to opt out).',
      ));
    }
    if (!free) {
      if (spec.monetization.weeklyPrice.isEmpty &&
          spec.monetization.lifetimePrice.isEmpty) {
        issues.add(const ValidationIssue(
          'monetization.weeklyPrice',
          '§6 must have at least a weekly price or a lifetime price.',
        ));
      }
      if (spec.monetization.annualPrice.isEmpty) {
        issues.add(const ValidationIssue(
          'monetization.annualPrice',
          '§6 annual price is required — the annual plan is pre-selected on '
          'the paywall.',
        ));
      }
      if (spec.monetization.benefits.length != 3) {
        issues.add(ValidationIssue(
          'monetization.benefits',
          '§6 needs exactly 3 benefit lines. Got '
          '${spec.monetization.benefits.length}.',
        ));
      }
    }

    // Onboarding 2–4, unless the app is free (§7 is often just "None" for
    // apps with nothing to warm up for).
    if (!free &&
        (spec.onboardingSteps.length < 2 || spec.onboardingSteps.length > 4)) {
      issues.add(ValidationIssue(
        'onboarding',
        '§7 must have 2–4 steps. Got ${spec.onboardingSteps.length}.',
      ));
    }

    // Developer account
    if (!{'A', 'B', 'C'}.contains(spec.developerAccount)) {
      issues.add(ValidationIssue(
        'developerAccount',
        '§1 developer account must be A, B, or C. Got '
        '"${spec.developerAccount}".',
      ));
    }

    // Job (§2)
    if (spec.job.isEmpty) {
      issues.add(const ValidationIssue(
        'job',
        '§2 job sentence is required.',
      ));
    }

    // Store seeds
    if (spec.storeSeeds.primaryKeyword.isEmpty) {
      issues.add(const ValidationIssue(
        'storeSeeds.primaryKeyword',
        '§9 primary keyword is required.',
      ));
    }
    if (spec.storeSeeds.secondaryKeywords.length < 5) {
      issues.add(ValidationIssue(
        'storeSeeds.secondaryKeywords',
        '§9 needs at least 5 secondary keywords. Got '
        '${spec.storeSeeds.secondaryKeywords.length}.',
      ));
    }
    if (spec.storeSeeds.screenshotStory.length != 5) {
      issues.add(ValidationIssue(
        'storeSeeds.screenshotStory',
        '§9 needs exactly 5 screenshot captions. Got '
        '${spec.storeSeeds.screenshotStory.length}.',
      ));
    }

    return ValidationReport(issues);
  }
}
