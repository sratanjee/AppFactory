import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:scaffold/factory_config.dart';
import 'package:scaffold/generator.dart';
import 'package:scaffold/spec.dart';
import 'package:scaffold/validate.dart';

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addFlag('dry-run', negatable: false,
        help: 'Print the plan without writing anything.')
    ..addFlag('no-git', negatable: false,
        help: 'Skip creating the app/<slug> branch and initial commit.')
    ..addFlag('no-flutter-create', negatable: false,
        help: 'Skip the underlying `flutter create` step.')
    ..addFlag('force', negatable: false,
        help: 'Overwrite apps/<slug>/ if it already exists.')
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show this help.');

  final args = parser.parse(argv);
  if (args['help'] as bool || args.rest.isEmpty) {
    stdout
      ..writeln('Usage: dart run scaffold <spec-file>')
      ..writeln()
      ..writeln(parser.usage);
    exit(0);
  }

  final specPath = args.rest.first;
  final specFile = File(specPath);
  if (!await specFile.exists()) {
    stderr.writeln('Spec file not found: $specPath');
    exit(1);
  }

  final repoRoot = _findRepoRoot(Directory.current);
  if (repoRoot == null) {
    stderr.writeln(
      'Could not locate repo root (no CLAUDE.md + factory.config found).',
    );
    exit(1);
  }

  final config = await FactoryConfig.load(repoRoot);

  final Spec spec;
  try {
    spec = SpecParser(
      await specFile.readAsString(),
      bundlePrefix: config.require('BUNDLE_PREFIX'),
    ).parse();
  } on SpecParseException catch (e) {
    stderr.writeln('Spec parse failed: $e');
    exit(1);
  }

  // --force means the caller knows apps/<slug>/ exists and wants to
  // overwrite; skip the existing-slug guard so re-runs and post-
  // `flutter create` overlays both work cleanly.
  final force = args['force'] as bool;
  final existingSlugs =
      force ? const <String>{} : await _existingSlugs(repoRoot);
  final report = SpecValidator(
    bundlePrefix: config.require('BUNDLE_PREFIX'),
    existingSlugs: existingSlugs,
  ).validate(spec);

  if (!report.isClean) {
    stderr.writeln('Spec validation failed:');
    for (final issue in report.issues) {
      stderr.writeln('  - $issue');
    }
    final appDir = Directory(p.join(repoRoot, 'apps', spec.slug));
    await appDir.create(recursive: true);
    await File(p.join(appDir.path, 'QUESTIONS.md'))
        .writeAsString(report.toMarkdown());
    stderr
      ..writeln()
      ..writeln('Wrote apps/${spec.slug}/QUESTIONS.md. '
          'Fix the spec and re-run.');
    exit(2);
  }

  final options = GeneratorOptions(
    dryRun: args['dry-run'] as bool,
    runGit: !(args['no-git'] as bool),
    runFlutterCreate: !(args['no-flutter-create'] as bool),
    force: force,
  );

  await Generator(
    repoRoot: repoRoot,
    spec: spec,
    config: config,
    options: options,
  ).run();
}

String? _findRepoRoot(Directory start) {
  var dir = start;
  while (true) {
    final marker = File(p.join(dir.path, 'CLAUDE.md'));
    if (marker.existsSync() &&
        File(p.join(dir.path, 'factory.config')).existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
}

Future<Set<String>> _existingSlugs(String repoRoot) async {
  final appsDir = Directory(p.join(repoRoot, 'apps'));
  if (!await appsDir.exists()) return const <String>{};
  final slugs = <String>{};
  await for (final entry in appsDir.list()) {
    if (entry is Directory) {
      slugs.add(p.basename(entry.path));
    }
  }
  return slugs;
}
