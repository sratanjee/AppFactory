/// Spec parsing. The factory's SPEC_TEMPLATE.md is a fixed-shape Markdown
/// document — every field lives at a known section and row. This parser
/// walks it with a state machine, no generic Markdown dep.
library;

class SpecParseException implements Exception {
  SpecParseException(this.message, {this.line});
  final String message;
  final int? line;

  @override
  String toString() =>
      line == null ? 'SpecParseException: $message'
                   : 'SpecParseException (line $line): $message';
}

class Spec {
  Spec({
    required this.appName,
    required this.iosSubtitle,
    required this.androidShortDescription,
    required this.slug,
    required this.bundleIdRaw,
    required this.storeCategory,
    required this.developerAccount,
    required this.factoryCategory,
    required this.job,
    required this.who,
    required this.where,
    required this.whyPay,
    required this.screens,
    required this.dataModelRaw,
    required this.backendMode,
    required this.syncMode,
    required this.nativeSurfaces,
    required this.monetization,
    required this.onboardingSteps,
    required this.designNotes,
    required this.storeSeeds,
    required this.outOfScope,
    required this.doneChecks,
  });

  // §1
  final String appName;
  final String iosSubtitle;
  final String androidShortDescription;
  final String slug;
  final String bundleIdRaw; // as written in the spec
  final String storeCategory;
  final String developerAccount;
  final String factoryCategory;

  // §2
  final String job;
  final String who;
  final String where;
  final String whyPay;

  // §3
  final List<ScreenSpec> screens;

  // §4
  final String dataModelRaw;
  final String backendMode;
  final String syncMode;

  // §5
  final NativeSurfacesSpec nativeSurfaces;

  // §6
  final MonetizationSpec monetization;

  // §7
  final List<String> onboardingSteps;

  // §8
  final DesignNotesSpec designNotes;

  // §9
  final StoreSeedsSpec storeSeeds;

  // §10
  final List<String> doneChecks;

  // §11
  final List<String> outOfScope;

  String get slugUnderscored => slug.replaceAll('-', '_');
  String get bundleId => bundleIdRaw;
}

class ScreenSpec {
  ScreenSpec({
    required this.index,
    required this.name,
    required this.purpose,
    required this.keyInteraction,
  });

  final int index;
  final String name;
  final String purpose;
  final String keyInteraction;
}

class NativeSurfacesSpec {
  NativeSurfacesSpec({
    required this.homeWidget,
    required this.lockScreenOrGlance,
    required this.liveActivityOrOngoing,
    required this.watchOrWearTile,
    required this.camera,
    required this.notifications,
    required this.shareExtension,
    required this.appIntents,
  });

  final bool homeWidget;
  final bool lockScreenOrGlance;
  final bool liveActivityOrOngoing;
  final bool watchOrWearTile;
  final bool camera;
  final bool notifications;
  final bool shareExtension;
  final bool appIntents;
}

class MonetizationSpec {
  MonetizationSpec({
    required this.paywallPlacement,
    required this.freeTrial,
    required this.weeklyPrice,
    required this.annualPrice,
    required this.lifetimePrice,
    required this.revenueCatEntitlement,
    required this.gatedVsFree,
    required this.benefits,
  });

  final String paywallPlacement;
  final String freeTrial;
  final String weeklyPrice;
  final String annualPrice;
  final String lifetimePrice;
  final String revenueCatEntitlement;
  final String gatedVsFree;
  final List<String> benefits;
}

class DesignNotesSpec {
  DesignNotesSpec({
    required this.accentHex,
    required this.iconConcept,
    required this.toneOfCopy,
    required this.differsFromSiblings,
  });

  final String accentHex;
  final String iconConcept;
  final String toneOfCopy;
  final String differsFromSiblings;
}

class StoreSeedsSpec {
  StoreSeedsSpec({
    required this.primaryKeyword,
    required this.secondaryKeywords,
    required this.screenshotStory,
  });

  final String primaryKeyword;
  final List<String> secondaryKeywords;
  final List<String> screenshotStory;
}

class SpecParser {
  SpecParser(this._content, {this.bundlePrefix = 'com.appfactory'});

  final String _content;
  final String bundlePrefix;
  late final List<String> _lines = _content.split('\n');

  Spec parse() {
    final sections = _splitSections();
    if (!sections.containsKey(1)) {
      throw SpecParseException('Missing §1 (Identity)');
    }

    final identity = _parseIdentityTable(sections[1]!);
    final theJob = _parseJob(sections[2] ?? const []);
    final screens = _parseScreens(sections[3] ?? const []);
    final dataModel = _parseDataModel(sections[4] ?? const []);
    final natives = _parseNatives(sections[5] ?? const []);
    final money = _parseMonetization(sections[6] ?? const []);
    final onboarding = _parseOnboarding(sections[7] ?? const []);
    final design = _parseDesignNotes(sections[8] ?? const []);
    final store = _parseStoreSeeds(sections[9] ?? const []);
    final done = _parseCheckboxList(sections[10] ?? const []);
    final outOfScope = _parseBulletList(sections[11] ?? const []);

    return Spec(
      appName: _requireField(identity, 'App name'),
      iosSubtitle: identity['Subtitle'] ?? '',
      androidShortDescription: identity['Subtitle'] ?? '',
      slug: _requireField(identity, 'Slug'),
      // SPEC_TEMPLATE.md renders the bundle ID as `com.studio.slug` with
      // backticks (Markdown code style); strip them. Human-authored specs
      // frequently substitute `[YOUR STUDIO]` for the studio segment —
      // auto-substitute BUNDLE_PREFIX so the queue can run through
      // without hand-editing every spec.
      bundleIdRaw: _substituteStudio(
        _stripBackticks(_requireField(identity, 'Bundle ID')),
      ),
      storeCategory: identity['Category'] ?? '',
      developerAccount: identity['Developer account'] ?? '',
      factoryCategory: identity['Factory category'] ?? '',
      job: theJob['job'] ?? '',
      who: theJob['who'] ?? '',
      where: theJob['where'] ?? '',
      whyPay: theJob['whyPay'] ?? '',
      screens: screens,
      dataModelRaw: dataModel['raw'] ?? '',
      backendMode: dataModel['backend'] ?? 'no',
      syncMode: dataModel['sync'] ?? 'none',
      nativeSurfaces: natives,
      monetization: MonetizationSpec(
        paywallPlacement: money.paywallPlacement,
        freeTrial: money.freeTrial,
        weeklyPrice: money.weeklyPrice,
        annualPrice: money.annualPrice,
        lifetimePrice: money.lifetimePrice,
        // Also code-formatted with backticks in the template.
        revenueCatEntitlement: _stripBackticks(money.revenueCatEntitlement),
        gatedVsFree: money.gatedVsFree,
        benefits: money.benefits,
      ),
      onboardingSteps: onboarding,
      designNotes: design,
      storeSeeds: store,
      outOfScope: outOfScope,
      doneChecks: done,
    );
  }

  /// Splits the doc by top-level `## <N>.` headings. Returns section
  /// number → the lines of that section (excluding the header itself).
  Map<int, List<String>> _splitSections() {
    final sections = <int, List<String>>{};
    int? current;
    for (final raw in _lines) {
      final match = RegExp(r'^## (\d+)\.').firstMatch(raw);
      if (match != null) {
        current = int.tryParse(match.group(1)!);
        if (current != null) sections[current] = [];
      } else if (current != null) {
        sections[current]!.add(raw);
      }
    }
    return sections;
  }

  Map<String, String> _parseIdentityTable(List<String> lines) {
    // Rows look like: `| App name (this is the primary ASO keyword) | Habits |`
    final result = <String, String>{};
    for (final row in lines) {
      final trimmed = row.trim();
      if (!trimmed.startsWith('|') || trimmed.startsWith('|---')) continue;
      final parts = trimmed.split('|').map((s) => s.trim()).toList();
      if (parts.length < 3) continue;
      final rawKey = parts[1];
      final value = parts[2];
      if (value.isEmpty || rawKey.isEmpty) continue;
      if (rawKey == 'Field' && value == 'Value') continue;
      final key = _normaliseIdentityKey(rawKey);
      result[key] = value;
    }
    return result;
  }

  String _normaliseIdentityKey(String raw) {
    if (raw.startsWith('App name')) return 'App name';
    if (raw.startsWith('Subtitle')) return 'Subtitle';
    if (raw.startsWith('Slug')) return 'Slug';
    if (raw.startsWith('Bundle ID')) return 'Bundle ID';
    if (raw.startsWith('Category')) return 'Category';
    if (raw.startsWith('Developer account')) return 'Developer account';
    if (raw.startsWith('Factory category')) return 'Factory category';
    return raw;
  }

  Map<String, String> _parseJob(List<String> lines) {
    final result = <String, String>{};
    final buffer = StringBuffer();
    for (final line in lines) {
      final t = line.trim();
      if (t.startsWith('> ')) {
        buffer.writeln(t.substring(2));
      } else if (t.startsWith('**Who pays:**')) {
        result['who'] = t.substring('**Who pays:**'.length).trim();
      } else if (t.startsWith('**Where they gather:**')) {
        result['where'] = t.substring('**Where they gather:**'.length).trim();
      } else if (t.startsWith("**Why they'd pay instead of using a free thing:**")) {
        result['whyPay'] =
            t.substring("**Why they'd pay instead of using a free thing:**".length).trim();
      }
    }
    result['job'] = buffer.toString().trim();
    return result;
  }

  List<ScreenSpec> _parseScreens(List<String> lines) {
    final screens = <ScreenSpec>[];
    for (final row in lines) {
      final t = row.trim();
      if (!t.startsWith('|') || t.startsWith('|---') || t.startsWith('| #')) continue;
      final parts = t.split('|').map((s) => s.trim()).toList();
      if (parts.length < 5) continue;
      final idx = int.tryParse(parts[1]);
      if (idx == null) continue;
      final name = parts[2];
      final purpose = parts[3];
      final interaction = parts[4];
      if (name.isEmpty && purpose.isEmpty && interaction.isEmpty) continue;
      screens.add(ScreenSpec(
        index: idx,
        name: name,
        purpose: purpose,
        keyInteraction: interaction,
      ));
    }
    return screens;
  }

  Map<String, String> _parseDataModel(List<String> lines) {
    final result = <String, String>{'raw': '', 'backend': '', 'sync': ''};
    final buffer = StringBuffer();
    var inCode = false;
    for (final line in lines) {
      final t = line.trim();
      if (t.startsWith('```')) {
        inCode = !inCode;
        continue;
      }
      if (inCode) {
        buffer.writeln(line);
        continue;
      }
      if (t.startsWith('**Backend needed?**')) {
        result['backend'] = _extractValue(t, '**Backend needed?**');
      } else if (t.startsWith('**Sync?**')) {
        result['sync'] = _extractValue(t, '**Sync?**');
      }
    }
    result['raw'] = buffer.toString().trim();
    return result;
  }

  String _extractValue(String line, String prefix) {
    final value = line.substring(prefix.length).trim();
    // Values look like "no · ai-proxy · usage-cap · subscription-webhook-only";
    // the spec author picks one and leaves the rest, or writes the picked
    // one explicitly. Accept whatever comes back.
    return value;
  }

  NativeSurfacesSpec _parseNatives(List<String> lines) {
    bool has(String key) {
      for (final line in lines) {
        final t = line.trim();
        if (t.contains(key) && t.startsWith('- [x]')) return true;
      }
      return false;
    }

    return NativeSurfacesSpec(
      homeWidget: has('Home screen widget'),
      lockScreenOrGlance: has('Lock screen widget'),
      liveActivityOrOngoing: has('Live Activity'),
      watchOrWearTile: has('Watch complication'),
      camera: has('Camera'),
      notifications: has('Notifications'),
      shareExtension: has('Share extension'),
      appIntents: has('App Intents'),
    );
  }

  MonetizationSpec _parseMonetization(List<String> lines) {
    final table = <String, String>{};
    final benefits = <String>[];
    for (final row in lines) {
      final t = row.trim();
      if (t.startsWith('|') && !t.startsWith('|---') && !t.startsWith('| Field')) {
        final parts = t.split('|').map((s) => s.trim()).toList();
        if (parts.length >= 3 && parts[1].isNotEmpty && parts[2].isNotEmpty) {
          table[parts[1]] = parts[2];
        }
      } else if (RegExp(r'^[1-3]\.\s').hasMatch(t)) {
        final text = t.substring(t.indexOf(' ') + 1).trim();
        if (text.isNotEmpty) benefits.add(text);
      }
    }
    return MonetizationSpec(
      paywallPlacement: table['Paywall placement'] ?? '',
      freeTrial: table['Free trial'] ?? 'none',
      weeklyPrice: table['Weekly price'] ?? '',
      annualPrice: table['Annual price'] ?? '',
      // Human-authored specs sometimes drop the "(optional)" suffix, so
      // accept either form.
      lifetimePrice: table['Lifetime price (optional)'] ??
          table['Lifetime price'] ??
          '',
      revenueCatEntitlement: table['RevenueCat entitlement'] ?? 'pro',
      gatedVsFree: table['What is gated vs. free'] ?? '',
      benefits: benefits,
    );
  }

  List<String> _parseOnboarding(List<String> lines) {
    final steps = <String>[];
    for (final line in lines) {
      final t = line.trim();
      final match = RegExp(r'^[1-9]\.\s+(.+)$').firstMatch(t);
      if (match != null) {
        final body = match.group(1)!.trim();
        if (body.isNotEmpty) steps.add(body);
      }
    }
    return steps;
  }

  DesignNotesSpec _parseDesignNotes(List<String> lines) {
    String? accent;
    String? icon;
    String? tone;
    String? diff;
    for (final line in lines) {
      final t = line.trim();
      if (t.startsWith('- Accent color')) {
        // Line often reads "- Accent color (one hex): `#0a6ea8`
        // (from artboard data-props; alternates ...)".
        // Extract the first #RRGGBB or #RRGGBBAA occurrence.
        final match = RegExp(r'#([0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?)')
            .firstMatch(_afterColon(t));
        accent = match?.group(0);
      } else if (t.startsWith('- Icon concept')) {
        icon = _afterColon(t);
      } else if (t.startsWith('- Tone of copy')) {
        tone = _afterColon(t);
      } else if (t.startsWith('- Anything that must feel different')) {
        diff = _afterColon(t);
      }
    }
    return DesignNotesSpec(
      accentHex: accent ?? '',
      iconConcept: icon ?? '',
      toneOfCopy: tone ?? '',
      differsFromSiblings: diff ?? '',
    );
  }

  String _afterColon(String line) {
    final i = line.indexOf(':');
    if (i < 0) return '';
    return line.substring(i + 1).trim();
  }

  StoreSeedsSpec _parseStoreSeeds(List<String> lines) {
    String primary = '';
    final secondary = <String>[];
    final screenshots = <String>[];
    var inScreenshots = false;
    for (final line in lines) {
      final t = line.trim();
      if (t.startsWith('- Primary keyword')) {
        primary = _afterColon(t);
      } else if (t.startsWith('- Secondary keywords')) {
        final v = _afterColon(t);
        if (v.isNotEmpty) {
          for (final part in v.split(',')) {
            final s = part.trim();
            if (s.isNotEmpty) secondary.add(s);
          }
        }
      } else if (t.startsWith('- Screenshot story')) {
        // Two supported shapes:
        //   - Screenshot story:
        //     1. Now — …
        //     2. Schedule — …
        //   - Screenshot story: 1 Now (…), 2 Schedule (…), …
        // Inline form keeps a compact spec; multiline form handles
        // longer captions.
        final inline = _afterColon(t);
        if (inline.isNotEmpty) {
          for (final part in inline.split(RegExp(r',\s*(?=\d+[\.\s])'))) {
            final captionMatch =
                RegExp(r'^\d+[\.\s]+(.+)$').firstMatch(part.trim());
            if (captionMatch != null) {
              screenshots.add(captionMatch.group(1)!.trim());
            }
          }
        } else {
          inScreenshots = true;
        }
      } else if (inScreenshots) {
        final match = RegExp(r'^\d+\.\s+(.+)$').firstMatch(t);
        if (match != null) {
          screenshots.add(match.group(1)!.trim());
        } else if (t.isEmpty || t.startsWith('##') || t.startsWith('- ')) {
          inScreenshots = false;
        }
      }
    }
    return StoreSeedsSpec(
      primaryKeyword: primary,
      secondaryKeywords: secondary,
      screenshotStory: screenshots,
    );
  }

  List<String> _parseCheckboxList(List<String> lines) {
    final items = <String>[];
    for (final line in lines) {
      final t = line.trim();
      final match = RegExp(r'^- \[[ x]\]\s+(.+)$').firstMatch(t);
      if (match != null) items.add(match.group(1)!.trim());
    }
    return items;
  }

  List<String> _parseBulletList(List<String> lines) {
    final items = <String>[];
    for (final line in lines) {
      final t = line.trim();
      final match = RegExp(r'^-\s+(.+)$').firstMatch(t);
      if (match != null && !match.group(1)!.startsWith('[')) {
        items.add(match.group(1)!.trim());
      }
    }
    return items;
  }

  String _requireField(Map<String, String> map, String key) {
    final v = map[key];
    if (v == null || v.isEmpty) {
      throw SpecParseException('Missing required §1 field "$key"');
    }
    return v;
  }

  String _stripBackticks(String s) =>
      s.replaceAll('`', '').trim();

  /// Replace `com.[YOUR STUDIO]...` (or lowercase variants) with the
  /// configured bundle prefix. Also strips any trailing commentary
  /// after the last valid bundle-ID token.
  String _substituteStudio(String s) {
    var out = s;
    final placeholder = RegExp(
      r'com\.\[?your ?studio\]?',
      caseSensitive: false,
    );
    out = out.replaceAll(placeholder, bundlePrefix);
    return out.trim();
  }
}
