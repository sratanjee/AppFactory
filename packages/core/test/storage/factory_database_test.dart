import 'package:drift/drift.dart';
import 'package:factory_core/factory_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('openInMemory returns a QueryExecutor', () {
    expect(FactoryDatabase.openInMemory(), isA<QueryExecutor>());
  });

  test('open returns a QueryExecutor', () {
    expect(
      FactoryDatabase.open(appSlug: 'test', dbName: 'app'),
      isA<QueryExecutor>(),
    );
  });
}
