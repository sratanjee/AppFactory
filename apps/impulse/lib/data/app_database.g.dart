// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMinorMeta = const VerificationMeta(
    'priceMinor',
  );
  @override
  late final GeneratedColumn<int> priceMinor = GeneratedColumn<int>(
    'price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decideAtMeta = const VerificationMeta(
    'decideAt',
  );
  @override
  late final GeneratedColumn<int> decideAt = GeneratedColumn<int>(
    'decide_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionMeta = const VerificationMeta(
    'decision',
  );
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
    'decision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<int> decidedAt = GeneratedColumn<int>(
    'decided_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    priceMinor,
    currency,
    createdAt,
    decideAt,
    decision,
    decidedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price_minor')) {
      context.handle(
        _priceMinorMeta,
        priceMinor.isAcceptableOrUnknown(data['price_minor']!, _priceMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('decide_at')) {
      context.handle(
        _decideAtMeta,
        decideAt.isAcceptableOrUnknown(data['decide_at']!, _decideAtMeta),
      );
    } else if (isInserting) {
      context.missing(_decideAtMeta);
    }
    if (data.containsKey('decision')) {
      context.handle(
        _decisionMeta,
        decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta),
      );
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      priceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      decideAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decide_at'],
      )!,
      decision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision'],
      ),
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decided_at'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int id;
  final String name;
  final int priceMinor;
  final String currency;
  final int createdAt;
  final int decideAt;
  final String? decision;
  final int? decidedAt;
  const Item({
    required this.id,
    required this.name,
    required this.priceMinor,
    required this.currency,
    required this.createdAt,
    required this.decideAt,
    this.decision,
    this.decidedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['price_minor'] = Variable<int>(priceMinor);
    map['currency'] = Variable<String>(currency);
    map['created_at'] = Variable<int>(createdAt);
    map['decide_at'] = Variable<int>(decideAt);
    if (!nullToAbsent || decision != null) {
      map['decision'] = Variable<String>(decision);
    }
    if (!nullToAbsent || decidedAt != null) {
      map['decided_at'] = Variable<int>(decidedAt);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      priceMinor: Value(priceMinor),
      currency: Value(currency),
      createdAt: Value(createdAt),
      decideAt: Value(decideAt),
      decision: decision == null && nullToAbsent
          ? const Value.absent()
          : Value(decision),
      decidedAt: decidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(decidedAt),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      priceMinor: serializer.fromJson<int>(json['priceMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      decideAt: serializer.fromJson<int>(json['decideAt']),
      decision: serializer.fromJson<String?>(json['decision']),
      decidedAt: serializer.fromJson<int?>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'priceMinor': serializer.toJson<int>(priceMinor),
      'currency': serializer.toJson<String>(currency),
      'createdAt': serializer.toJson<int>(createdAt),
      'decideAt': serializer.toJson<int>(decideAt),
      'decision': serializer.toJson<String?>(decision),
      'decidedAt': serializer.toJson<int?>(decidedAt),
    };
  }

  Item copyWith({
    int? id,
    String? name,
    int? priceMinor,
    String? currency,
    int? createdAt,
    int? decideAt,
    Value<String?> decision = const Value.absent(),
    Value<int?> decidedAt = const Value.absent(),
  }) => Item(
    id: id ?? this.id,
    name: name ?? this.name,
    priceMinor: priceMinor ?? this.priceMinor,
    currency: currency ?? this.currency,
    createdAt: createdAt ?? this.createdAt,
    decideAt: decideAt ?? this.decideAt,
    decision: decision.present ? decision.value : this.decision,
    decidedAt: decidedAt.present ? decidedAt.value : this.decidedAt,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      priceMinor: data.priceMinor.present
          ? data.priceMinor.value
          : this.priceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      decideAt: data.decideAt.present ? data.decideAt.value : this.decideAt,
      decision: data.decision.present ? data.decision.value : this.decision,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('decideAt: $decideAt, ')
          ..write('decision: $decision, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    priceMinor,
    currency,
    createdAt,
    decideAt,
    decision,
    decidedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.name == this.name &&
          other.priceMinor == this.priceMinor &&
          other.currency == this.currency &&
          other.createdAt == this.createdAt &&
          other.decideAt == this.decideAt &&
          other.decision == this.decision &&
          other.decidedAt == this.decidedAt);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> priceMinor;
  final Value<String> currency;
  final Value<int> createdAt;
  final Value<int> decideAt;
  final Value<String?> decision;
  final Value<int?> decidedAt;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.priceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.decideAt = const Value.absent(),
    this.decision = const Value.absent(),
    this.decidedAt = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int priceMinor,
    required String currency,
    required int createdAt,
    required int decideAt,
    this.decision = const Value.absent(),
    this.decidedAt = const Value.absent(),
  }) : name = Value(name),
       priceMinor = Value(priceMinor),
       currency = Value(currency),
       createdAt = Value(createdAt),
       decideAt = Value(decideAt);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? priceMinor,
    Expression<String>? currency,
    Expression<int>? createdAt,
    Expression<int>? decideAt,
    Expression<String>? decision,
    Expression<int>? decidedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (priceMinor != null) 'price_minor': priceMinor,
      if (currency != null) 'currency': currency,
      if (createdAt != null) 'created_at': createdAt,
      if (decideAt != null) 'decide_at': decideAt,
      if (decision != null) 'decision': decision,
      if (decidedAt != null) 'decided_at': decidedAt,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? priceMinor,
    Value<String>? currency,
    Value<int>? createdAt,
    Value<int>? decideAt,
    Value<String?>? decision,
    Value<int?>? decidedAt,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      priceMinor: priceMinor ?? this.priceMinor,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      decideAt: decideAt ?? this.decideAt,
      decision: decision ?? this.decision,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priceMinor.present) {
      map['price_minor'] = Variable<int>(priceMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (decideAt.present) {
      map['decide_at'] = Variable<int>(decideAt.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<int>(decidedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('priceMinor: $priceMinor, ')
          ..write('currency: $currency, ')
          ..write('createdAt: $createdAt, ')
          ..write('decideAt: $decideAt, ')
          ..write('decision: $decision, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [items];
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  Value<int> id,
  required String name,
  required int priceMinor,
  required String currency,
  required int createdAt,
  required int decideAt,
  Value<String?> decision,
  Value<int?> decidedAt,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> priceMinor,
  Value<String> currency,
  Value<int> createdAt,
  Value<int> decideAt,
  Value<String?> decision,
  Value<int?> decidedAt,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decideAt => $composableBuilder(
    column: $table.decideAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decideAt => $composableBuilder(
    column: $table.decideAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get priceMinor => $composableBuilder(
    column: $table.priceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get decideAt =>
      $composableBuilder(column: $table.decideAt, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<int> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> priceMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> decideAt = const Value.absent(),
                Value<String?> decision = const Value.absent(),
                Value<int?> decidedAt = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                priceMinor: priceMinor,
                currency: currency,
                createdAt: createdAt,
                decideAt: decideAt,
                decision: decision,
                decidedAt: decidedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int priceMinor,
                required String currency,
                required int createdAt,
                required int decideAt,
                Value<String?> decision = const Value.absent(),
                Value<int?> decidedAt = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                priceMinor: priceMinor,
                currency: currency,
                createdAt: createdAt,
                decideAt: decideAt,
                decision: decision,
                decidedAt: decidedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, Item>(table),
                  BaseReferences<_$AppDatabase, $ItemsTable, Item>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
}
