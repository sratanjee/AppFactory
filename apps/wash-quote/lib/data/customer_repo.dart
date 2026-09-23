import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wash_quote/data/app_database.dart';

class CustomerRepo {
  CustomerRepo(this._db);

  final AppDatabase _db;

  Future<int> add({
    required String name,
    String? phone,
    String? email,
    String? address,
  }) {
    return _db.into(_db.customers).insert(
          CustomersCompanion.insert(
            name: name,
            phone: Value(phone),
            email: Value(email),
            address: Value(address),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    await (_db.update(_db.customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(
        name: Value(name),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.customers)..where((t) => t.id.equals(id))).go();
  }

  Future<Customer?> byId(int id) =>
      (_db.select(_db.customers)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<List<Customer>> watchAll() {
    return (_db.select(_db.customers)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }
}

final customerRepoProvider = Provider<CustomerRepo>((ref) {
  return CustomerRepo(ref.watch(appDatabaseProvider));
});

final customersProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(customerRepoProvider).watchAll();
});
