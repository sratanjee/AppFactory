import 'dart:io';

import 'package:condition_log/condition_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('condition_log_backup');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('exportSqliteFor returns a file even when source missing', () async {
    final backup = Backup(appSlug: 'seizure-log', dbName: 'condition_log');
    final file = await backup.exportSqliteFor(1);
    expect(file.existsSync(), isTrue);
    expect(file.path, contains('pet1'));
  });

  test('LocalBackupDriver copies file into backups/', () async {
    final source = File('${tempDir.path}/source.sqlite');
    source.writeAsStringSync('DBBYTES');
    const driver = LocalBackupDriver();
    final dst = await driver.pushToCloud(source);
    expect(dst.existsSync(), isTrue);
    expect(dst.path, contains('backups'));
    expect(dst.readAsStringSync(), 'DBBYTES');
  });

  test('exportAndPush calls the injected driver', () async {
    var invocations = 0;
    final backup = Backup(
      appSlug: 'seizure-log',
      dbName: 'condition_log',
      driver: _CountingDriver(onCall: () => invocations++),
    );
    await backup.exportAndPush(petId: 1);
    expect(invocations, 1);
  });
}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);
  final String root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;
}

class _CountingDriver implements BackupCloudDriver {
  _CountingDriver({required this.onCall});
  final void Function() onCall;

  @override
  Future<File> pushToCloud(File file) async {
    onCall();
    return file;
  }
}
