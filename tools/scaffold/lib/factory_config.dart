import 'dart:io';

/// Loads `factory.config` at the repo root as a `KEY=VALUE` env map.
/// Values in `factory.config.local` (gitignored) override anything in
/// `factory.config`, so secrets can stay out of the repo.
///
/// The file is shell-format; we accept unquoted / single-quoted /
/// double-quoted values and strip surrounding quotes.
class FactoryConfig {
  FactoryConfig(this.values);

  final Map<String, String> values;

  static Future<FactoryConfig> load(String repoRoot) async {
    final map = <String, String>{};
    for (final name in ['factory.config', 'factory.config.local']) {
      final file = File('$repoRoot/$name');
      if (!await file.exists()) {
        if (name == 'factory.config') {
          throw StateError('factory.config not found at ${file.path}');
        }
        continue;
      }
      for (final line in await file.readAsLines()) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final eq = trimmed.indexOf('=');
        if (eq <= 0) continue;
        final key = trimmed.substring(0, eq).trim();
        var value = trimmed.substring(eq + 1).trim();
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }
        map[key] = value;
      }
    }
    return FactoryConfig(map);
  }

  String get(String key, {String fallback = ''}) => values[key] ?? fallback;
  String require(String key) {
    final v = values[key];
    if (v == null || v.isEmpty) {
      throw StateError('factory.config is missing $key');
    }
    return v;
  }
}
