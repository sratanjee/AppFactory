import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:scaffold/factory_config.dart';
import 'package:scaffold/spec.dart';
import 'package:scaffold/templates.dart';
import 'package:scaffold/templates_data.dart';

class GeneratorOptions {
  const GeneratorOptions({
    this.dryRun = false,
    this.runGit = true,
    this.runFlutterCreate = true,
    this.force = false,
  });

  final bool dryRun;
  final bool runGit;
  final bool runFlutterCreate;
  final bool force;
}

class Generator {
  Generator({
    required this.repoRoot,
    required this.spec,
    required this.config,
    required this.options,
  });

  final String repoRoot;
  final Spec spec;
  final FactoryConfig config;
  final GeneratorOptions options;

  String get _appDir => p.join(repoRoot, 'apps', spec.slug);

  Future<void> run() async {
    final ctx = buildContext(
      spec: spec,
      bundlePrefix: config.require('BUNDLE_PREFIX'),
      flutterVersion: config.require('FLUTTER_VERSION'),
      privacyUrlBase: config.get('PRIVACY_URL_BASE'),
    );

    if (options.dryRun) {
      stdout.writeln('[dry-run] would scaffold ${spec.slug} at $_appDir');
      _dumpPlan(ctx);
      return;
    }

    _log('scaffolding ${spec.slug} at $_appDir');

    if (await Directory(_appDir).exists() && !options.force) {
      throw StateError(
        'apps/${spec.slug}/ already exists. Pass --force to overwrite.',
      );
    }

    if (options.runFlutterCreate) {
      await _runFlutterCreate();
    } else {
      _log('skipping flutter create (--no-flutter-create)');
      await Directory(_appDir).create(recursive: true);
    }

    await _writeGeneratedFiles(ctx);
    await _writeStoreStubs(ctx);
    await _writeReviewMd(ctx);
    await _createQaDir();

    if (options.runGit) {
      await _gitCommit();
    } else {
      _log('skipping git branch + commit (--no-git)');
    }

    stdout.writeln('done: apps/${spec.slug}/ scaffolded');
  }

  Future<void> _runFlutterCreate() async {
    _log('running flutter create');
    final result = await Process.run(
      'fvm',
      [
        'flutter',
        'create',
        '--template=app',
        '--platforms=ios,android',
        '--org',
        config.require('BUNDLE_PREFIX'),
        '--project-name',
        spec.slugUnderscored,
        _appDir,
      ],
      workingDirectory: repoRoot,
    );
    if (result.exitCode != 0) {
      stderr.writeln(result.stderr);
      throw StateError('flutter create failed');
    }
  }

  Future<void> _writeGeneratedFiles(Map<String, String> ctx) async {
    await _writeFile('pubspec.yaml', render(pubspecTemplate, ctx));
    await _writeFile('analysis_options.yaml',
        render(analysisOptionsTemplate, ctx));
    await _writeFile('lib/main.dart', render(mainDartTemplate, ctx));
    await _writeFile('lib/app.dart', render(appDartTemplate, ctx));
    await _writeFile('lib/app_config.dart', render(appConfigDartTemplate, ctx));
    await _writeFile('lib/router.dart', render(routerDartTemplate, ctx));
    await _writeFile('lib/screens/home_screen.dart', render(homeScreenTemplate, ctx));
    await _writeFile('.shorebird/shorebird.yaml', render(shorebirdYamlTemplate, ctx));

    // flutter create leaves behind a stub widget_test.dart that references
    // its own MyApp scaffold. Replace it with a mount-only smoke test.
    final stubTest = File(p.join(_appDir, 'test/widget_test.dart'));
    if (await stubTest.exists()) {
      await stubTest.delete();
    }
    await _writeFile('test/smoke_test.dart', render(smokeTestTemplate, ctx));
  }

  Future<void> _writeStoreStubs(Map<String, String> ctx) async {
    // iOS
    await _writeFile('store/ios/en-US/name.txt', render(iosNameTemplate, ctx));
    await _writeFile('store/ios/en-US/subtitle.txt', render(iosSubtitleTemplate, ctx));
    await _writeFile('store/ios/en-US/keywords.txt', render(iosKeywordsTemplate, ctx));
    await _writeFile('store/ios/en-US/promotional_text.txt', render(iosPromoTemplate, ctx));
    await _writeFile('store/ios/en-US/description.txt', render(iosDescriptionTemplate, ctx));
    // Android
    await _writeFile('store/android/en-US/name.txt', render(androidNameTemplate, ctx));
    await _writeFile(
      'store/android/en-US/short_description.txt',
      render(androidShortDescriptionTemplate, ctx),
    );
    await _writeFile(
      'store/android/en-US/description.txt',
      render(androidDescriptionTemplate, ctx),
    );
  }

  Future<void> _writeReviewMd(Map<String, String> ctx) async {
    await _writeFile('REVIEW.md', render(reviewMdTemplate, ctx));
  }

  Future<void> _createQaDir() async {
    await Directory(p.join(_appDir, 'qa')).create(recursive: true);
  }

  Future<void> _gitCommit() async {
    _log('creating branch app/${spec.slug}');
    await _run('git', ['-C', repoRoot, 'checkout', '-b', 'app/${spec.slug}']);
    await _run('git', ['-C', repoRoot, 'add', 'apps/${spec.slug}']);
    await _run(
      'git',
      [
        '-C',
        repoRoot,
        'commit',
        '-m',
        '${spec.slug}: scaffold',
      ],
    );
  }

  Future<void> _writeFile(String relPath, String content) async {
    final file = File(p.join(_appDir, relPath));
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<void> _run(String bin, List<String> args) async {
    final result = await Process.run(bin, args);
    if (result.exitCode != 0) {
      stderr.writeln(result.stderr);
      throw StateError('$bin ${args.join(' ')} failed');
    }
  }

  void _log(String message) => stdout.writeln('scaffold: $message');

  void _dumpPlan(Map<String, String> ctx) {
    stdout
      ..writeln('  slug:        ${spec.slug}')
      ..writeln('  bundleId:    ${spec.bundleIdRaw}')
      ..writeln('  appClass:    ${ctx["appClassName"]}App')
      ..writeln('  accentColor: #${ctx["accentHex"]!.substring(2)}')
      ..writeln('  screens:     ${spec.screens.length}')
      ..writeln('  paywall:     ${spec.monetization.paywallPlacement}')
      ..writeln('  benefits:    ${spec.monetization.benefits.length}')
      ..writeln('  native:      home=${spec.nativeSurfaces.homeWidget} '
          'lock=${spec.nativeSurfaces.lockScreenOrGlance} '
          'live=${spec.nativeSurfaces.liveActivityOrOngoing}');
  }
}
