import 'package:scaffold/spec.dart';

/// Simple `${KEY}` substitution. No conditional blocks, no loops beyond
/// what the template context pre-renders. Keeps the tool tiny and the
/// templates readable — every field lands verbatim from the context map.
String render(String template, Map<String, String> context) {
  var out = template;
  for (final entry in context.entries) {
    out = out.replaceAll('\${${entry.key}}', entry.value);
  }
  return out;
}

/// Builds the template context for a spec + factory config values.
Map<String, String> buildContext({
  required Spec spec,
  required String bundlePrefix,
  required String flutterVersion,
  String privacyUrlBase = '',
}) {
  final className = _pascal(spec.slug);
  final accentHexClean = spec.designNotes.accentHex.replaceFirst('#', '');
  final accentHex = accentHexClean.length == 6 ? 'FF$accentHexClean' : accentHexClean;
  // Derive privacy / terms URLs. Terms is shared across the fleet;
  // privacy is per-slug. Both fall back to a factory placeholder if
  // PRIVACY_URL_BASE isn't set (dev builds don't need real URLs).
  final base = privacyUrlBase.replaceAll(RegExp(r'/+$'), '');
  final privacyUrl = base.isEmpty
      ? 'https://example.test/privacy'
      : '$base/${spec.slug}/privacy.html';
  final termsUrl =
      base.isEmpty ? 'https://example.test/terms' : '$base/terms.html';
  return {
    'slug': spec.slug,
    'slugUnderscored': spec.slugUnderscored,
    'appName': _dartString(spec.appName),
    'appNameLiteral': spec.appName,
    'appClassName': className,
    'bundleId': spec.bundleIdRaw,
    'bundlePrefix': bundlePrefix,
    'flutterVersion': flutterVersion,
    'accentHex': accentHex,
    'primaryKeyword': _dartString(spec.storeSeeds.primaryKeyword),
    'iosSubtitle': _clip(spec.iosSubtitle, 30),
    'androidShortDescription': _clip(spec.androidShortDescription, 80),
    'benefitsList': _dartListOfStrings(spec.monetization.benefits),
    'primaryPurchaseSku': spec.monetization.annualPrice.isNotEmpty ? 'annual' : 'weekly',
    'revenueCatEntitlement': spec.monetization.revenueCatEntitlement,
    'iosKeywordsCsv': spec.storeSeeds.secondaryKeywords.take(20).join(','),
    'iosLongDescription': _iosLongDescription(spec),
    'androidLongDescription': _androidLongDescription(spec),
    'screenshotStoryList': _numberedList(spec.storeSeeds.screenshotStory),
    'privacyUrl': privacyUrl,
    'termsUrl': termsUrl,
  };
}

String _pascal(String slug) {
  return slug
      .split('-')
      .map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1))
      .join();
}

String _clip(String s, int max) => s.length <= max ? s : s.substring(0, max);

String _dartString(String s) {
  final escaped = s
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n');
  return "'$escaped'";
}

String _dartListOfStrings(List<String> items) {
  if (items.isEmpty) return 'const []';
  final buffer = StringBuffer('const [\n');
  for (final item in items) {
    buffer.writeln('    ${_dartString(item)},');
  }
  buffer.write('  ]');
  return buffer.toString();
}

String _numberedList(List<String> items) {
  final b = StringBuffer();
  for (var i = 0; i < items.length; i++) {
    b.writeln('${i + 1}. ${items[i]}');
  }
  return b.toString();
}

String _iosLongDescription(Spec spec) {
  final b = StringBuffer()
    ..writeln(spec.job)
    ..writeln()
    ..writeln('For ${spec.who}.')
    ..writeln()
    ..writeln('What it does')
    ..writeln();
  for (final s in spec.screens) {
    b.writeln('• ${s.purpose}');
  }
  b
    ..writeln()
    ..writeln('Why people use it')
    ..writeln()
    ..writeln(spec.monetization.gatedVsFree)
    ..writeln()
    ..writeln('Subscription')
    ..writeln()
    ..writeln('Free trial: ${spec.monetization.freeTrial}. '
        'Weekly: ${spec.monetization.weeklyPrice}. '
        'Annual: ${spec.monetization.annualPrice}.')
    ..writeln('Auto-renews unless cancelled.')
    ..writeln('Manage in App Store settings.');
  return b.toString().trim();
}

String _androidLongDescription(Spec spec) => _iosLongDescription(spec);
