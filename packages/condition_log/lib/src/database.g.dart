// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PetsTable extends Pets with TableInfo<$PetsTable, Pet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<int> birthDate = GeneratedColumn<int>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionLabelMeta = const VerificationMeta(
    'conditionLabel',
  );
  @override
  late final GeneratedColumn<String> conditionLabel = GeneratedColumn<String>(
    'condition_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    species,
    breed,
    weightKg,
    birthDate,
    photoPath,
    conditionLabel,
    configJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pet> instance, {
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
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('condition_label')) {
      context.handle(
        _conditionLabelMeta,
        conditionLabel.isAcceptableOrUnknown(
          data['condition_label']!,
          _conditionLabelMeta,
        ),
      );
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_date'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      conditionLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_label'],
      ),
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      ),
    );
  }

  @override
  $PetsTable createAlias(String alias) {
    return $PetsTable(attachedDatabase, alias);
  }
}

class Pet extends DataClass implements Insertable<Pet> {
  final int id;
  final String name;
  final String species;
  final String? breed;
  final double? weightKg;
  final int? birthDate;
  final String? photoPath;
  final String? conditionLabel;

  /// Free-form JSON so SKUs can add fields (Pet Diabetes: insulin/meter/unit;
  /// Kidney: irisStage, dailyPlan) without new columns.
  final String? configJson;
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.weightKg,
    this.birthDate,
    this.photoPath,
    this.conditionLabel,
    this.configJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['species'] = Variable<String>(species);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<int>(birthDate);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || conditionLabel != null) {
      map['condition_label'] = Variable<String>(conditionLabel);
    }
    if (!nullToAbsent || configJson != null) {
      map['config_json'] = Variable<String>(configJson);
    }
    return map;
  }

  PetsCompanion toCompanion(bool nullToAbsent) {
    return PetsCompanion(
      id: Value(id),
      name: Value(name),
      species: Value(species),
      breed: breed == null && nullToAbsent
          ? const Value.absent()
          : Value(breed),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      conditionLabel: conditionLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionLabel),
      configJson: configJson == null && nullToAbsent
          ? const Value.absent()
          : Value(configJson),
    );
  }

  factory Pet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pet(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String?>(json['breed']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      birthDate: serializer.fromJson<int?>(json['birthDate']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      conditionLabel: serializer.fromJson<String?>(json['conditionLabel']),
      configJson: serializer.fromJson<String?>(json['configJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String?>(breed),
      'weightKg': serializer.toJson<double?>(weightKg),
      'birthDate': serializer.toJson<int?>(birthDate),
      'photoPath': serializer.toJson<String?>(photoPath),
      'conditionLabel': serializer.toJson<String?>(conditionLabel),
      'configJson': serializer.toJson<String?>(configJson),
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    String? species,
    Value<String?> breed = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<int?> birthDate = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> conditionLabel = const Value.absent(),
    Value<String?> configJson = const Value.absent(),
  }) => Pet(
    id: id ?? this.id,
    name: name ?? this.name,
    species: species ?? this.species,
    breed: breed.present ? breed.value : this.breed,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    conditionLabel: conditionLabel.present
        ? conditionLabel.value
        : this.conditionLabel,
    configJson: configJson.present ? configJson.value : this.configJson,
  );
  Pet copyWithCompanion(PetsCompanion data) {
    return Pet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      conditionLabel: data.conditionLabel.present
          ? data.conditionLabel.value
          : this.conditionLabel,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('weightKg: $weightKg, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoPath: $photoPath, ')
          ..write('conditionLabel: $conditionLabel, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    species,
    breed,
    weightKg,
    birthDate,
    photoPath,
    conditionLabel,
    configJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pet &&
          other.id == this.id &&
          other.name == this.name &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.weightKg == this.weightKg &&
          other.birthDate == this.birthDate &&
          other.photoPath == this.photoPath &&
          other.conditionLabel == this.conditionLabel &&
          other.configJson == this.configJson);
}

class PetsCompanion extends UpdateCompanion<Pet> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> species;
  final Value<String?> breed;
  final Value<double?> weightKg;
  final Value<int?> birthDate;
  final Value<String?> photoPath;
  final Value<String?> conditionLabel;
  final Value<String?> configJson;
  const PetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.conditionLabel = const Value.absent(),
    this.configJson = const Value.absent(),
  });
  PetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String species,
    this.breed = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.conditionLabel = const Value.absent(),
    this.configJson = const Value.absent(),
  }) : name = Value(name),
       species = Value(species);
  static Insertable<Pet> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<double>? weightKg,
    Expression<int>? birthDate,
    Expression<String>? photoPath,
    Expression<String>? conditionLabel,
    Expression<String>? configJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (weightKg != null) 'weight_kg': weightKg,
      if (birthDate != null) 'birth_date': birthDate,
      if (photoPath != null) 'photo_path': photoPath,
      if (conditionLabel != null) 'condition_label': conditionLabel,
      if (configJson != null) 'config_json': configJson,
    });
  }

  PetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? species,
    Value<String?>? breed,
    Value<double?>? weightKg,
    Value<int?>? birthDate,
    Value<String?>? photoPath,
    Value<String?>? conditionLabel,
    Value<String?>? configJson,
  }) {
    return PetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      weightKg: weightKg ?? this.weightKg,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      conditionLabel: conditionLabel ?? this.conditionLabel,
      configJson: configJson ?? this.configJson,
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
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<int>(birthDate.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (conditionLabel.present) {
      map['condition_label'] = Variable<String>(conditionLabel.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('weightKg: $weightKg, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoPath: $photoPath, ')
          ..write('conditionLabel: $conditionLabel, ')
          ..write('configJson: $configJson')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtypeMeta = const VerificationMeta(
    'subtype',
  );
  @override
  late final GeneratedColumn<String> subtype = GeneratedColumn<String>(
    'subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clusterFlagMeta = const VerificationMeta(
    'clusterFlag',
  );
  @override
  late final GeneratedColumn<bool> clusterFlag = GeneratedColumn<bool>(
    'cluster_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cluster_flag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _triggersMeta = const VerificationMeta(
    'triggers',
  );
  @override
  late final GeneratedColumn<String> triggers = GeneratedColumn<String>(
    'triggers',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    kind,
    startedAt,
    durationSec,
    subtype,
    clusterFlag,
    triggers,
    note,
    metadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    if (data.containsKey('subtype')) {
      context.handle(
        _subtypeMeta,
        subtype.isAcceptableOrUnknown(data['subtype']!, _subtypeMeta),
      );
    }
    if (data.containsKey('cluster_flag')) {
      context.handle(
        _clusterFlagMeta,
        clusterFlag.isAcceptableOrUnknown(
          data['cluster_flag']!,
          _clusterFlagMeta,
        ),
      );
    }
    if (data.containsKey('triggers')) {
      context.handle(
        _triggersMeta,
        triggers.isAcceptableOrUnknown(data['triggers']!, _triggersMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      ),
      subtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype'],
      ),
      clusterFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cluster_flag'],
      )!,
      triggers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}triggers'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final int id;
  final int petId;
  final String kind;
  final int startedAt;
  final int? durationSec;
  final String? subtype;
  final bool clusterFlag;
  final String? triggers;
  final String? note;
  final String? metadataJson;
  const Event({
    required this.id,
    required this.petId,
    required this.kind,
    required this.startedAt,
    this.durationSec,
    this.subtype,
    required this.clusterFlag,
    this.triggers,
    this.note,
    this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['kind'] = Variable<String>(kind);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || durationSec != null) {
      map['duration_sec'] = Variable<int>(durationSec);
    }
    if (!nullToAbsent || subtype != null) {
      map['subtype'] = Variable<String>(subtype);
    }
    map['cluster_flag'] = Variable<bool>(clusterFlag);
    if (!nullToAbsent || triggers != null) {
      map['triggers'] = Variable<String>(triggers);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      petId: Value(petId),
      kind: Value(kind),
      startedAt: Value(startedAt),
      durationSec: durationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSec),
      subtype: subtype == null && nullToAbsent
          ? const Value.absent()
          : Value(subtype),
      clusterFlag: Value(clusterFlag),
      triggers: triggers == null && nullToAbsent
          ? const Value.absent()
          : Value(triggers),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      kind: serializer.fromJson<String>(json['kind']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      durationSec: serializer.fromJson<int?>(json['durationSec']),
      subtype: serializer.fromJson<String?>(json['subtype']),
      clusterFlag: serializer.fromJson<bool>(json['clusterFlag']),
      triggers: serializer.fromJson<String?>(json['triggers']),
      note: serializer.fromJson<String?>(json['note']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'kind': serializer.toJson<String>(kind),
      'startedAt': serializer.toJson<int>(startedAt),
      'durationSec': serializer.toJson<int?>(durationSec),
      'subtype': serializer.toJson<String?>(subtype),
      'clusterFlag': serializer.toJson<bool>(clusterFlag),
      'triggers': serializer.toJson<String?>(triggers),
      'note': serializer.toJson<String?>(note),
      'metadataJson': serializer.toJson<String?>(metadataJson),
    };
  }

  Event copyWith({
    int? id,
    int? petId,
    String? kind,
    int? startedAt,
    Value<int?> durationSec = const Value.absent(),
    Value<String?> subtype = const Value.absent(),
    bool? clusterFlag,
    Value<String?> triggers = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
  }) => Event(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    kind: kind ?? this.kind,
    startedAt: startedAt ?? this.startedAt,
    durationSec: durationSec.present ? durationSec.value : this.durationSec,
    subtype: subtype.present ? subtype.value : this.subtype,
    clusterFlag: clusterFlag ?? this.clusterFlag,
    triggers: triggers.present ? triggers.value : this.triggers,
    note: note.present ? note.value : this.note,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      kind: data.kind.present ? data.kind.value : this.kind,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      subtype: data.subtype.present ? data.subtype.value : this.subtype,
      clusterFlag: data.clusterFlag.present
          ? data.clusterFlag.value
          : this.clusterFlag,
      triggers: data.triggers.present ? data.triggers.value : this.triggers,
      note: data.note.present ? data.note.value : this.note,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('kind: $kind, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('subtype: $subtype, ')
          ..write('clusterFlag: $clusterFlag, ')
          ..write('triggers: $triggers, ')
          ..write('note: $note, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    petId,
    kind,
    startedAt,
    durationSec,
    subtype,
    clusterFlag,
    triggers,
    note,
    metadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.kind == this.kind &&
          other.startedAt == this.startedAt &&
          other.durationSec == this.durationSec &&
          other.subtype == this.subtype &&
          other.clusterFlag == this.clusterFlag &&
          other.triggers == this.triggers &&
          other.note == this.note &&
          other.metadataJson == this.metadataJson);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<int> id;
  final Value<int> petId;
  final Value<String> kind;
  final Value<int> startedAt;
  final Value<int?> durationSec;
  final Value<String?> subtype;
  final Value<bool> clusterFlag;
  final Value<String?> triggers;
  final Value<String?> note;
  final Value<String?> metadataJson;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.kind = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.subtype = const Value.absent(),
    this.clusterFlag = const Value.absent(),
    this.triggers = const Value.absent(),
    this.note = const Value.absent(),
    this.metadataJson = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required String kind,
    required int startedAt,
    this.durationSec = const Value.absent(),
    this.subtype = const Value.absent(),
    this.clusterFlag = const Value.absent(),
    this.triggers = const Value.absent(),
    this.note = const Value.absent(),
    this.metadataJson = const Value.absent(),
  }) : petId = Value(petId),
       kind = Value(kind),
       startedAt = Value(startedAt);
  static Insertable<Event> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<String>? kind,
    Expression<int>? startedAt,
    Expression<int>? durationSec,
    Expression<String>? subtype,
    Expression<bool>? clusterFlag,
    Expression<String>? triggers,
    Expression<String>? note,
    Expression<String>? metadataJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (kind != null) 'kind': kind,
      if (startedAt != null) 'started_at': startedAt,
      if (durationSec != null) 'duration_sec': durationSec,
      if (subtype != null) 'subtype': subtype,
      if (clusterFlag != null) 'cluster_flag': clusterFlag,
      if (triggers != null) 'triggers': triggers,
      if (note != null) 'note': note,
      if (metadataJson != null) 'metadata_json': metadataJson,
    });
  }

  EventsCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<String>? kind,
    Value<int>? startedAt,
    Value<int?>? durationSec,
    Value<String?>? subtype,
    Value<bool>? clusterFlag,
    Value<String?>? triggers,
    Value<String?>? note,
    Value<String?>? metadataJson,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      kind: kind ?? this.kind,
      startedAt: startedAt ?? this.startedAt,
      durationSec: durationSec ?? this.durationSec,
      subtype: subtype ?? this.subtype,
      clusterFlag: clusterFlag ?? this.clusterFlag,
      triggers: triggers ?? this.triggers,
      note: note ?? this.note,
      metadataJson: metadataJson ?? this.metadataJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (subtype.present) {
      map['subtype'] = Variable<String>(subtype.value);
    }
    if (clusterFlag.present) {
      map['cluster_flag'] = Variable<bool>(clusterFlag.value);
    }
    if (triggers.present) {
      map['triggers'] = Variable<String>(triggers.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('kind: $kind, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('subtype: $subtype, ')
          ..write('clusterFlag: $clusterFlag, ')
          ..write('triggers: $triggers, ')
          ..write('note: $note, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _strengthMgMeta = const VerificationMeta(
    'strengthMg',
  );
  @override
  late final GeneratedColumn<double> strengthMg = GeneratedColumn<double>(
    'strength_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doseTextMeta = const VerificationMeta(
    'doseText',
  );
  @override
  late final GeneratedColumn<String> doseText = GeneratedColumn<String>(
    'dose_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timesPerDayMeta = const VerificationMeta(
    'timesPerDay',
  );
  @override
  late final GeneratedColumn<int> timesPerDay = GeneratedColumn<int>(
    'times_per_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timesJsonMeta = const VerificationMeta(
    'timesJson',
  );
  @override
  late final GeneratedColumn<String> timesJson = GeneratedColumn<String>(
    'times_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    name,
    strengthMg,
    doseText,
    timesPerDay,
    timesJson,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('strength_mg')) {
      context.handle(
        _strengthMgMeta,
        strengthMg.isAcceptableOrUnknown(data['strength_mg']!, _strengthMgMeta),
      );
    }
    if (data.containsKey('dose_text')) {
      context.handle(
        _doseTextMeta,
        doseText.isAcceptableOrUnknown(data['dose_text']!, _doseTextMeta),
      );
    }
    if (data.containsKey('times_per_day')) {
      context.handle(
        _timesPerDayMeta,
        timesPerDay.isAcceptableOrUnknown(
          data['times_per_day']!,
          _timesPerDayMeta,
        ),
      );
    }
    if (data.containsKey('times_json')) {
      context.handle(
        _timesJsonMeta,
        timesJson.isAcceptableOrUnknown(data['times_json']!, _timesJsonMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      strengthMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}strength_mg'],
      ),
      doseText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_text'],
      ),
      timesPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_day'],
      ),
      timesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times_json'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final int petId;
  final String name;
  final double? strengthMg;
  final String? doseText;
  final int? timesPerDay;
  final String? timesJson;
  final bool active;
  const Medication({
    required this.id,
    required this.petId,
    required this.name,
    this.strengthMg,
    this.doseText,
    this.timesPerDay,
    this.timesJson,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || strengthMg != null) {
      map['strength_mg'] = Variable<double>(strengthMg);
    }
    if (!nullToAbsent || doseText != null) {
      map['dose_text'] = Variable<String>(doseText);
    }
    if (!nullToAbsent || timesPerDay != null) {
      map['times_per_day'] = Variable<int>(timesPerDay);
    }
    if (!nullToAbsent || timesJson != null) {
      map['times_json'] = Variable<String>(timesJson);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      petId: Value(petId),
      name: Value(name),
      strengthMg: strengthMg == null && nullToAbsent
          ? const Value.absent()
          : Value(strengthMg),
      doseText: doseText == null && nullToAbsent
          ? const Value.absent()
          : Value(doseText),
      timesPerDay: timesPerDay == null && nullToAbsent
          ? const Value.absent()
          : Value(timesPerDay),
      timesJson: timesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(timesJson),
      active: Value(active),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      name: serializer.fromJson<String>(json['name']),
      strengthMg: serializer.fromJson<double?>(json['strengthMg']),
      doseText: serializer.fromJson<String?>(json['doseText']),
      timesPerDay: serializer.fromJson<int?>(json['timesPerDay']),
      timesJson: serializer.fromJson<String?>(json['timesJson']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'name': serializer.toJson<String>(name),
      'strengthMg': serializer.toJson<double?>(strengthMg),
      'doseText': serializer.toJson<String?>(doseText),
      'timesPerDay': serializer.toJson<int?>(timesPerDay),
      'timesJson': serializer.toJson<String?>(timesJson),
      'active': serializer.toJson<bool>(active),
    };
  }

  Medication copyWith({
    int? id,
    int? petId,
    String? name,
    Value<double?> strengthMg = const Value.absent(),
    Value<String?> doseText = const Value.absent(),
    Value<int?> timesPerDay = const Value.absent(),
    Value<String?> timesJson = const Value.absent(),
    bool? active,
  }) => Medication(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    name: name ?? this.name,
    strengthMg: strengthMg.present ? strengthMg.value : this.strengthMg,
    doseText: doseText.present ? doseText.value : this.doseText,
    timesPerDay: timesPerDay.present ? timesPerDay.value : this.timesPerDay,
    timesJson: timesJson.present ? timesJson.value : this.timesJson,
    active: active ?? this.active,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      name: data.name.present ? data.name.value : this.name,
      strengthMg: data.strengthMg.present
          ? data.strengthMg.value
          : this.strengthMg,
      doseText: data.doseText.present ? data.doseText.value : this.doseText,
      timesPerDay: data.timesPerDay.present
          ? data.timesPerDay.value
          : this.timesPerDay,
      timesJson: data.timesJson.present ? data.timesJson.value : this.timesJson,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('name: $name, ')
          ..write('strengthMg: $strengthMg, ')
          ..write('doseText: $doseText, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('timesJson: $timesJson, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    petId,
    name,
    strengthMg,
    doseText,
    timesPerDay,
    timesJson,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.name == this.name &&
          other.strengthMg == this.strengthMg &&
          other.doseText == this.doseText &&
          other.timesPerDay == this.timesPerDay &&
          other.timesJson == this.timesJson &&
          other.active == this.active);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<int> petId;
  final Value<String> name;
  final Value<double?> strengthMg;
  final Value<String?> doseText;
  final Value<int?> timesPerDay;
  final Value<String?> timesJson;
  final Value<bool> active;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.name = const Value.absent(),
    this.strengthMg = const Value.absent(),
    this.doseText = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.timesJson = const Value.absent(),
    this.active = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required String name,
    this.strengthMg = const Value.absent(),
    this.doseText = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.timesJson = const Value.absent(),
    this.active = const Value.absent(),
  }) : petId = Value(petId),
       name = Value(name);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<String>? name,
    Expression<double>? strengthMg,
    Expression<String>? doseText,
    Expression<int>? timesPerDay,
    Expression<String>? timesJson,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (name != null) 'name': name,
      if (strengthMg != null) 'strength_mg': strengthMg,
      if (doseText != null) 'dose_text': doseText,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (timesJson != null) 'times_json': timesJson,
      if (active != null) 'active': active,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<String>? name,
    Value<double?>? strengthMg,
    Value<String?>? doseText,
    Value<int?>? timesPerDay,
    Value<String?>? timesJson,
    Value<bool>? active,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      strengthMg: strengthMg ?? this.strengthMg,
      doseText: doseText ?? this.doseText,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      timesJson: timesJson ?? this.timesJson,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (strengthMg.present) {
      map['strength_mg'] = Variable<double>(strengthMg.value);
    }
    if (doseText.present) {
      map['dose_text'] = Variable<String>(doseText.value);
    }
    if (timesPerDay.present) {
      map['times_per_day'] = Variable<int>(timesPerDay.value);
    }
    if (timesJson.present) {
      map['times_json'] = Variable<String>(timesJson.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('name: $name, ')
          ..write('strengthMg: $strengthMg, ')
          ..write('doseText: $doseText, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('timesJson: $timesJson, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $DosesTable extends Doses with TableInfo<$DosesTable, Dose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DosesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<int> takenAt = GeneratedColumn<int>(
    'taken_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    scheduledAt,
    takenAt,
    skipped,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dose> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dose(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taken_at'],
      ),
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
    );
  }

  @override
  $DosesTable createAlias(String alias) {
    return $DosesTable(attachedDatabase, alias);
  }
}

class Dose extends DataClass implements Insertable<Dose> {
  final int id;
  final int medicationId;
  final int scheduledAt;
  final int? takenAt;
  final bool skipped;
  const Dose({
    required this.id,
    required this.medicationId,
    required this.scheduledAt,
    this.takenAt,
    required this.skipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['scheduled_at'] = Variable<int>(scheduledAt);
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<int>(takenAt);
    }
    map['skipped'] = Variable<bool>(skipped);
    return map;
  }

  DosesCompanion toCompanion(bool nullToAbsent) {
    return DosesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      scheduledAt: Value(scheduledAt),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      skipped: Value(skipped),
    );
  }

  factory Dose.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dose(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      scheduledAt: serializer.fromJson<int>(json['scheduledAt']),
      takenAt: serializer.fromJson<int?>(json['takenAt']),
      skipped: serializer.fromJson<bool>(json['skipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'scheduledAt': serializer.toJson<int>(scheduledAt),
      'takenAt': serializer.toJson<int?>(takenAt),
      'skipped': serializer.toJson<bool>(skipped),
    };
  }

  Dose copyWith({
    int? id,
    int? medicationId,
    int? scheduledAt,
    Value<int?> takenAt = const Value.absent(),
    bool? skipped,
  }) => Dose(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    takenAt: takenAt.present ? takenAt.value : this.takenAt,
    skipped: skipped ?? this.skipped,
  );
  Dose copyWithCompanion(DosesCompanion data) {
    return Dose(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dose(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('takenAt: $takenAt, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, medicationId, scheduledAt, takenAt, skipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dose &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.scheduledAt == this.scheduledAt &&
          other.takenAt == this.takenAt &&
          other.skipped == this.skipped);
}

class DosesCompanion extends UpdateCompanion<Dose> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<int> scheduledAt;
  final Value<int?> takenAt;
  final Value<bool> skipped;
  const DosesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.skipped = const Value.absent(),
  });
  DosesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required int scheduledAt,
    this.takenAt = const Value.absent(),
    this.skipped = const Value.absent(),
  }) : medicationId = Value(medicationId),
       scheduledAt = Value(scheduledAt);
  static Insertable<Dose> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<int>? scheduledAt,
    Expression<int>? takenAt,
    Expression<bool>? skipped,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (takenAt != null) 'taken_at': takenAt,
      if (skipped != null) 'skipped': skipped,
    });
  }

  DosesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<int>? scheduledAt,
    Value<int?>? takenAt,
    Value<bool>? skipped,
  }) {
    return DosesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      takenAt: takenAt ?? this.takenAt,
      skipped: skipped ?? this.skipped,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<int>(takenAt.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DosesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('takenAt: $takenAt, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }
}

class $MeasurementsTable extends Measurements
    with TableInfo<$MeasurementsTable, Measurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<int> takenAt = GeneratedColumn<int>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panelIdMeta = const VerificationMeta(
    'panelId',
  );
  @override
  late final GeneratedColumn<int> panelId = GeneratedColumn<int>(
    'panel_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    kind,
    value,
    unit,
    takenAt,
    label,
    panelId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Measurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('panel_id')) {
      context.handle(
        _panelIdMeta,
        panelId.isAcceptableOrUnknown(data['panel_id']!, _panelIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Measurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Measurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taken_at'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      panelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}panel_id'],
      ),
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }
}

class Measurement extends DataClass implements Insertable<Measurement> {
  final int id;
  final int petId;
  final String kind;
  final double value;
  final String unit;
  final int takenAt;
  final String? label;
  final int? panelId;
  const Measurement({
    required this.id,
    required this.petId,
    required this.kind,
    required this.value,
    required this.unit,
    required this.takenAt,
    this.label,
    this.panelId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['kind'] = Variable<String>(kind);
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    map['taken_at'] = Variable<int>(takenAt);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || panelId != null) {
      map['panel_id'] = Variable<int>(panelId);
    }
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      id: Value(id),
      petId: Value(petId),
      kind: Value(kind),
      value: Value(value),
      unit: Value(unit),
      takenAt: Value(takenAt),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      panelId: panelId == null && nullToAbsent
          ? const Value.absent()
          : Value(panelId),
    );
  }

  factory Measurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Measurement(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      kind: serializer.fromJson<String>(json['kind']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      takenAt: serializer.fromJson<int>(json['takenAt']),
      label: serializer.fromJson<String?>(json['label']),
      panelId: serializer.fromJson<int?>(json['panelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'kind': serializer.toJson<String>(kind),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'takenAt': serializer.toJson<int>(takenAt),
      'label': serializer.toJson<String?>(label),
      'panelId': serializer.toJson<int?>(panelId),
    };
  }

  Measurement copyWith({
    int? id,
    int? petId,
    String? kind,
    double? value,
    String? unit,
    int? takenAt,
    Value<String?> label = const Value.absent(),
    Value<int?> panelId = const Value.absent(),
  }) => Measurement(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    kind: kind ?? this.kind,
    value: value ?? this.value,
    unit: unit ?? this.unit,
    takenAt: takenAt ?? this.takenAt,
    label: label.present ? label.value : this.label,
    panelId: panelId.present ? panelId.value : this.panelId,
  );
  Measurement copyWithCompanion(MeasurementsCompanion data) {
    return Measurement(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      label: data.label.present ? data.label.value : this.label,
      panelId: data.panelId.present ? data.panelId.value : this.panelId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Measurement(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('takenAt: $takenAt, ')
          ..write('label: $label, ')
          ..write('panelId: $panelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, petId, kind, value, unit, takenAt, label, panelId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.takenAt == this.takenAt &&
          other.label == this.label &&
          other.panelId == this.panelId);
}

class MeasurementsCompanion extends UpdateCompanion<Measurement> {
  final Value<int> id;
  final Value<int> petId;
  final Value<String> kind;
  final Value<double> value;
  final Value<String> unit;
  final Value<int> takenAt;
  final Value<String?> label;
  final Value<int?> panelId;
  const MeasurementsCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.label = const Value.absent(),
    this.panelId = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required String kind,
    required double value,
    required String unit,
    required int takenAt,
    this.label = const Value.absent(),
    this.panelId = const Value.absent(),
  }) : petId = Value(petId),
       kind = Value(kind),
       value = Value(value),
       unit = Value(unit),
       takenAt = Value(takenAt);
  static Insertable<Measurement> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<String>? kind,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<int>? takenAt,
    Expression<String>? label,
    Expression<int>? panelId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (takenAt != null) 'taken_at': takenAt,
      if (label != null) 'label': label,
      if (panelId != null) 'panel_id': panelId,
    });
  }

  MeasurementsCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<String>? kind,
    Value<double>? value,
    Value<String>? unit,
    Value<int>? takenAt,
    Value<String?>? label,
    Value<int?>? panelId,
  }) {
    return MeasurementsCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      takenAt: takenAt ?? this.takenAt,
      label: label ?? this.label,
      panelId: panelId ?? this.panelId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<int>(takenAt.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (panelId.present) {
      map['panel_id'] = Variable<int>(panelId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('takenAt: $takenAt, ')
          ..write('label: $label, ')
          ..write('panelId: $panelId')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, petId, at, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final int petId;
  final int at;
  final String body;
  const Note({
    required this.id,
    required this.petId,
    required this.at,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['at'] = Variable<int>(at);
    map['body'] = Variable<String>(body);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      petId: Value(petId),
      at: Value(at),
      body: Value(body),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      at: serializer.fromJson<int>(json['at']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'at': serializer.toJson<int>(at),
      'body': serializer.toJson<String>(body),
    };
  }

  Note copyWith({int? id, int? petId, int? at, String? body}) => Note(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    at: at ?? this.at,
    body: body ?? this.body,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      at: data.at.present ? data.at.value : this.at,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('at: $at, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, petId, at, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.at == this.at &&
          other.body == this.body);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<int> petId;
  final Value<int> at;
  final Value<String> body;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.at = const Value.absent(),
    this.body = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required int at,
    required String body,
  }) : petId = Value(petId),
       at = Value(at),
       body = Value(body);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<int>? at,
    Expression<String>? body,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (at != null) 'at': at,
      if (body != null) 'body': body,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<int>? at,
    Value<String>? body,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      at: at ?? this.at,
      body: body ?? this.body,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('at: $at, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }
}

class $ReportRunsTable extends ReportRuns
    with TableInfo<$ReportRunsTable, ReportRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportRunsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<int> petId = GeneratedColumn<int>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromAtMeta = const VerificationMeta('fromAt');
  @override
  late final GeneratedColumn<int> fromAt = GeneratedColumn<int>(
    'from_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toAtMeta = const VerificationMeta('toAt');
  @override
  late final GeneratedColumn<int> toAt = GeneratedColumn<int>(
    'to_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<int> generatedAt = GeneratedColumn<int>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    petId,
    fromAt,
    toAt,
    generatedAt,
    path,
    format,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReportRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('from_at')) {
      context.handle(
        _fromAtMeta,
        fromAt.isAcceptableOrUnknown(data['from_at']!, _fromAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fromAtMeta);
    }
    if (data.containsKey('to_at')) {
      context.handle(
        _toAtMeta,
        toAt.isAcceptableOrUnknown(data['to_at']!, _toAtMeta),
      );
    } else if (isInserting) {
      context.missing(_toAtMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pet_id'],
      )!,
      fromAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_at'],
      )!,
      toAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_at'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generated_at'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
    );
  }

  @override
  $ReportRunsTable createAlias(String alias) {
    return $ReportRunsTable(attachedDatabase, alias);
  }
}

class ReportRun extends DataClass implements Insertable<ReportRun> {
  final int id;
  final int petId;
  final int fromAt;
  final int toAt;
  final int generatedAt;
  final String path;
  final String format;
  const ReportRun({
    required this.id,
    required this.petId,
    required this.fromAt,
    required this.toAt,
    required this.generatedAt,
    required this.path,
    required this.format,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pet_id'] = Variable<int>(petId);
    map['from_at'] = Variable<int>(fromAt);
    map['to_at'] = Variable<int>(toAt);
    map['generated_at'] = Variable<int>(generatedAt);
    map['path'] = Variable<String>(path);
    map['format'] = Variable<String>(format);
    return map;
  }

  ReportRunsCompanion toCompanion(bool nullToAbsent) {
    return ReportRunsCompanion(
      id: Value(id),
      petId: Value(petId),
      fromAt: Value(fromAt),
      toAt: Value(toAt),
      generatedAt: Value(generatedAt),
      path: Value(path),
      format: Value(format),
    );
  }

  factory ReportRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportRun(
      id: serializer.fromJson<int>(json['id']),
      petId: serializer.fromJson<int>(json['petId']),
      fromAt: serializer.fromJson<int>(json['fromAt']),
      toAt: serializer.fromJson<int>(json['toAt']),
      generatedAt: serializer.fromJson<int>(json['generatedAt']),
      path: serializer.fromJson<String>(json['path']),
      format: serializer.fromJson<String>(json['format']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'petId': serializer.toJson<int>(petId),
      'fromAt': serializer.toJson<int>(fromAt),
      'toAt': serializer.toJson<int>(toAt),
      'generatedAt': serializer.toJson<int>(generatedAt),
      'path': serializer.toJson<String>(path),
      'format': serializer.toJson<String>(format),
    };
  }

  ReportRun copyWith({
    int? id,
    int? petId,
    int? fromAt,
    int? toAt,
    int? generatedAt,
    String? path,
    String? format,
  }) => ReportRun(
    id: id ?? this.id,
    petId: petId ?? this.petId,
    fromAt: fromAt ?? this.fromAt,
    toAt: toAt ?? this.toAt,
    generatedAt: generatedAt ?? this.generatedAt,
    path: path ?? this.path,
    format: format ?? this.format,
  );
  ReportRun copyWithCompanion(ReportRunsCompanion data) {
    return ReportRun(
      id: data.id.present ? data.id.value : this.id,
      petId: data.petId.present ? data.petId.value : this.petId,
      fromAt: data.fromAt.present ? data.fromAt.value : this.fromAt,
      toAt: data.toAt.present ? data.toAt.value : this.toAt,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      path: data.path.present ? data.path.value : this.path,
      format: data.format.present ? data.format.value : this.format,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportRun(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('fromAt: $fromAt, ')
          ..write('toAt: $toAt, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('path: $path, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, petId, fromAt, toAt, generatedAt, path, format);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportRun &&
          other.id == this.id &&
          other.petId == this.petId &&
          other.fromAt == this.fromAt &&
          other.toAt == this.toAt &&
          other.generatedAt == this.generatedAt &&
          other.path == this.path &&
          other.format == this.format);
}

class ReportRunsCompanion extends UpdateCompanion<ReportRun> {
  final Value<int> id;
  final Value<int> petId;
  final Value<int> fromAt;
  final Value<int> toAt;
  final Value<int> generatedAt;
  final Value<String> path;
  final Value<String> format;
  const ReportRunsCompanion({
    this.id = const Value.absent(),
    this.petId = const Value.absent(),
    this.fromAt = const Value.absent(),
    this.toAt = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.path = const Value.absent(),
    this.format = const Value.absent(),
  });
  ReportRunsCompanion.insert({
    this.id = const Value.absent(),
    required int petId,
    required int fromAt,
    required int toAt,
    required int generatedAt,
    required String path,
    required String format,
  }) : petId = Value(petId),
       fromAt = Value(fromAt),
       toAt = Value(toAt),
       generatedAt = Value(generatedAt),
       path = Value(path),
       format = Value(format);
  static Insertable<ReportRun> custom({
    Expression<int>? id,
    Expression<int>? petId,
    Expression<int>? fromAt,
    Expression<int>? toAt,
    Expression<int>? generatedAt,
    Expression<String>? path,
    Expression<String>? format,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (petId != null) 'pet_id': petId,
      if (fromAt != null) 'from_at': fromAt,
      if (toAt != null) 'to_at': toAt,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (path != null) 'path': path,
      if (format != null) 'format': format,
    });
  }

  ReportRunsCompanion copyWith({
    Value<int>? id,
    Value<int>? petId,
    Value<int>? fromAt,
    Value<int>? toAt,
    Value<int>? generatedAt,
    Value<String>? path,
    Value<String>? format,
  }) {
    return ReportRunsCompanion(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      fromAt: fromAt ?? this.fromAt,
      toAt: toAt ?? this.toAt,
      generatedAt: generatedAt ?? this.generatedAt,
      path: path ?? this.path,
      format: format ?? this.format,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<int>(petId.value);
    }
    if (fromAt.present) {
      map['from_at'] = Variable<int>(fromAt.value);
    }
    if (toAt.present) {
      map['to_at'] = Variable<int>(toAt.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<int>(generatedAt.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportRunsCompanion(')
          ..write('id: $id, ')
          ..write('petId: $petId, ')
          ..write('fromAt: $fromAt, ')
          ..write('toAt: $toAt, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('path: $path, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }
}

abstract class _$ConditionLogDatabase extends GeneratedDatabase {
  _$ConditionLogDatabase(QueryExecutor e) : super(e);
  $ConditionLogDatabaseManager get managers =>
      $ConditionLogDatabaseManager(this);
  late final $PetsTable pets = $PetsTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $DosesTable doses = $DosesTable(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $ReportRunsTable reportRuns = $ReportRunsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pets,
    events,
    medications,
    doses,
    measurements,
    notes,
    reportRuns,
  ];
}

typedef $$PetsTableCreateCompanionBuilder = PetsCompanion Function({
  Value<int> id,
  required String name,
  required String species,
  Value<String?> breed,
  Value<double?> weightKg,
  Value<int?> birthDate,
  Value<String?> photoPath,
  Value<String?> conditionLabel,
  Value<String?> configJson,
});
typedef $$PetsTableUpdateCompanionBuilder = PetsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> species,
  Value<String?> breed,
  Value<double?> weightKg,
  Value<int?> birthDate,
  Value<String?> photoPath,
  Value<String?> conditionLabel,
  Value<String?> configJson,
});

class $$PetsTableFilterComposer
    extends Composer<_$ConditionLogDatabase, $PetsTable> {
  $$PetsTableFilterComposer({
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

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionLabel => $composableBuilder(
    column: $table.conditionLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PetsTableOrderingComposer
    extends Composer<_$ConditionLogDatabase, $PetsTable> {
  $$PetsTableOrderingComposer({
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

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionLabel => $composableBuilder(
    column: $table.conditionLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetsTableAnnotationComposer
    extends Composer<_$ConditionLogDatabase, $PetsTable> {
  $$PetsTableAnnotationComposer({
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

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get conditionLabel => $composableBuilder(
    column: $table.conditionLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );
}

class $$PetsTableTableManager
    extends
        RootTableManager<
          _$ConditionLogDatabase,
          $PetsTable,
          Pet,
          $$PetsTableFilterComposer,
          $$PetsTableOrderingComposer,
          $$PetsTableAnnotationComposer,
          $$PetsTableCreateCompanionBuilder,
          $$PetsTableUpdateCompanionBuilder,
          (Pet, BaseReferences<_$ConditionLogDatabase, $PetsTable, Pet>),
          Pet,
          PrefetchHooks Function()
        > {
  $$PetsTableTableManager(_$ConditionLogDatabase db, $PetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> birthDate = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> conditionLabel = const Value.absent(),
                Value<String?> configJson = const Value.absent(),
              }) => PetsCompanion(
                id: id,
                name: name,
                species: species,
                breed: breed,
                weightKg: weightKg,
                birthDate: birthDate,
                photoPath: photoPath,
                conditionLabel: conditionLabel,
                configJson: configJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String species,
                Value<String?> breed = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> birthDate = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> conditionLabel = const Value.absent(),
                Value<String?> configJson = const Value.absent(),
              }) => PetsCompanion.insert(
                id: id,
                name: name,
                species: species,
                breed: breed,
                weightKg: weightKg,
                birthDate: birthDate,
                photoPath: photoPath,
                conditionLabel: conditionLabel,
                configJson: configJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PetsTable, Pet>(table),
                  BaseReferences<_$ConditionLogDatabase, $PetsTable, Pet>(
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

typedef $$PetsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConditionLogDatabase,
      $PetsTable,
      Pet,
      $$PetsTableFilterComposer,
      $$PetsTableOrderingComposer,
      $$PetsTableAnnotationComposer,
      $$PetsTableCreateCompanionBuilder,
      $$PetsTableUpdateCompanionBuilder,
      (Pet, BaseReferences<_$ConditionLogDatabase, $PetsTable, Pet>),
      Pet,
      PrefetchHooks Function()
    >;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  required int petId,
  required String kind,
  required int startedAt,
  Value<int?> durationSec,
  Value<String?> subtype,
  Value<bool> clusterFlag,
  Value<String?> triggers,
  Value<String?> note,
  Value<String?> metadataJson,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  Value<int> petId,
  Value<String> kind,
  Value<int> startedAt,
  Value<int?> durationSec,
  Value<String?> subtype,
  Value<bool> clusterFlag,
  Value<String?> triggers,
  Value<String?> note,
  Value<String?> metadataJson,
});

class $$EventsTableFilterComposer
    extends Composer<_$ConditionLogDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get clusterFlag => $composableBuilder(
    column: $table.clusterFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggers => $composableBuilder(
    column: $table.triggers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$ConditionLogDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtype => $composableBuilder(
    column: $table.subtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get clusterFlag => $composableBuilder(
    column: $table.clusterFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggers => $composableBuilder(
    column: $table.triggers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$ConditionLogDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subtype =>
      $composableBuilder(column: $table.subtype, builder: (column) => column);

  GeneratedColumn<bool> get clusterFlag => $composableBuilder(
    column: $table.clusterFlag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggers =>
      $composableBuilder(column: $table.triggers, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$ConditionLogDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, BaseReferences<_$ConditionLogDatabase, $EventsTable, Event>),
          Event,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$ConditionLogDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<bool> clusterFlag = const Value.absent(),
                Value<String?> triggers = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                petId: petId,
                kind: kind,
                startedAt: startedAt,
                durationSec: durationSec,
                subtype: subtype,
                clusterFlag: clusterFlag,
                triggers: triggers,
                note: note,
                metadataJson: metadataJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required String kind,
                required int startedAt,
                Value<int?> durationSec = const Value.absent(),
                Value<String?> subtype = const Value.absent(),
                Value<bool> clusterFlag = const Value.absent(),
                Value<String?> triggers = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                petId: petId,
                kind: kind,
                startedAt: startedAt,
                durationSec: durationSec,
                subtype: subtype,
                clusterFlag: clusterFlag,
                triggers: triggers,
                note: note,
                metadataJson: metadataJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventsTable, Event>(table),
                  BaseReferences<_$ConditionLogDatabase, $EventsTable, Event>(
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

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConditionLogDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, BaseReferences<_$ConditionLogDatabase, $EventsTable, Event>),
      Event,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required int petId,
      required String name,
      Value<double?> strengthMg,
      Value<String?> doseText,
      Value<int?> timesPerDay,
      Value<String?> timesJson,
      Value<bool> active,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<int> petId,
      Value<String> name,
      Value<double?> strengthMg,
      Value<String?> doseText,
      Value<int?> timesPerDay,
      Value<String?> timesJson,
      Value<bool> active,
    });

class $$MedicationsTableFilterComposer
    extends Composer<_$ConditionLogDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
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

  ColumnFilters<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strengthMg => $composableBuilder(
    column: $table.strengthMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseText => $composableBuilder(
    column: $table.doseText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timesJson => $composableBuilder(
    column: $table.timesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$ConditionLogDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
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

  ColumnOrderings<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strengthMg => $composableBuilder(
    column: $table.strengthMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseText => $composableBuilder(
    column: $table.doseText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timesJson => $composableBuilder(
    column: $table.timesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$ConditionLogDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get strengthMg => $composableBuilder(
    column: $table.strengthMg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseText =>
      $composableBuilder(column: $table.doseText, builder: (column) => column);

  GeneratedColumn<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timesJson =>
      $composableBuilder(column: $table.timesJson, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$ConditionLogDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (
            Medication,
            BaseReferences<
              _$ConditionLogDatabase,
              $MedicationsTable,
              Medication
            >,
          ),
          Medication,
          PrefetchHooks Function()
        > {
  $$MedicationsTableTableManager(
    _$ConditionLogDatabase db,
    $MedicationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> strengthMg = const Value.absent(),
                Value<String?> doseText = const Value.absent(),
                Value<int?> timesPerDay = const Value.absent(),
                Value<String?> timesJson = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                petId: petId,
                name: name,
                strengthMg: strengthMg,
                doseText: doseText,
                timesPerDay: timesPerDay,
                timesJson: timesJson,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required String name,
                Value<double?> strengthMg = const Value.absent(),
                Value<String?> doseText = const Value.absent(),
                Value<int?> timesPerDay = const Value.absent(),
                Value<String?> timesJson = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                petId: petId,
                name: name,
                strengthMg: strengthMg,
                doseText: doseText,
                timesPerDay: timesPerDay,
                timesJson: timesJson,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicationsTable, Medication>(table),
                  BaseReferences<
                    _$ConditionLogDatabase,
                    $MedicationsTable,
                    Medication
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConditionLogDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (
        Medication,
        BaseReferences<_$ConditionLogDatabase, $MedicationsTable, Medication>,
      ),
      Medication,
      PrefetchHooks Function()
    >;
typedef $$DosesTableCreateCompanionBuilder = DosesCompanion Function({
  Value<int> id,
  required int medicationId,
  required int scheduledAt,
  Value<int?> takenAt,
  Value<bool> skipped,
});
typedef $$DosesTableUpdateCompanionBuilder = DosesCompanion Function({
  Value<int> id,
  Value<int> medicationId,
  Value<int> scheduledAt,
  Value<int?> takenAt,
  Value<bool> skipped,
});

class $$DosesTableFilterComposer
    extends Composer<_$ConditionLogDatabase, $DosesTable> {
  $$DosesTableFilterComposer({
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

  ColumnFilters<int> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DosesTableOrderingComposer
    extends Composer<_$ConditionLogDatabase, $DosesTable> {
  $$DosesTableOrderingComposer({
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

  ColumnOrderings<int> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DosesTableAnnotationComposer
    extends Composer<_$ConditionLogDatabase, $DosesTable> {
  $$DosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);
}

class $$DosesTableTableManager
    extends
        RootTableManager<
          _$ConditionLogDatabase,
          $DosesTable,
          Dose,
          $$DosesTableFilterComposer,
          $$DosesTableOrderingComposer,
          $$DosesTableAnnotationComposer,
          $$DosesTableCreateCompanionBuilder,
          $$DosesTableUpdateCompanionBuilder,
          (Dose, BaseReferences<_$ConditionLogDatabase, $DosesTable, Dose>),
          Dose,
          PrefetchHooks Function()
        > {
  $$DosesTableTableManager(_$ConditionLogDatabase db, $DosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<int> scheduledAt = const Value.absent(),
                Value<int?> takenAt = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
              }) => DosesCompanion(
                id: id,
                medicationId: medicationId,
                scheduledAt: scheduledAt,
                takenAt: takenAt,
                skipped: skipped,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required int scheduledAt,
                Value<int?> takenAt = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
              }) => DosesCompanion.insert(
                id: id,
                medicationId: medicationId,
                scheduledAt: scheduledAt,
                takenAt: takenAt,
                skipped: skipped,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DosesTable, Dose>(table),
                  BaseReferences<_$ConditionLogDatabase, $DosesTable, Dose>(
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

typedef $$DosesTableProcessedTableManager =
    ProcessedTableManager<
      _$ConditionLogDatabase,
      $DosesTable,
      Dose,
      $$DosesTableFilterComposer,
      $$DosesTableOrderingComposer,
      $$DosesTableAnnotationComposer,
      $$DosesTableCreateCompanionBuilder,
      $$DosesTableUpdateCompanionBuilder,
      (Dose, BaseReferences<_$ConditionLogDatabase, $DosesTable, Dose>),
      Dose,
      PrefetchHooks Function()
    >;
typedef $$MeasurementsTableCreateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<int> id,
      required int petId,
      required String kind,
      required double value,
      required String unit,
      required int takenAt,
      Value<String?> label,
      Value<int?> panelId,
    });
typedef $$MeasurementsTableUpdateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<int> id,
      Value<int> petId,
      Value<String> kind,
      Value<double> value,
      Value<String> unit,
      Value<int> takenAt,
      Value<String?> label,
      Value<int?> panelId,
    });

class $$MeasurementsTableFilterComposer
    extends Composer<_$ConditionLogDatabase, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer({
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

  ColumnFilters<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get panelId => $composableBuilder(
    column: $table.panelId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeasurementsTableOrderingComposer
    extends Composer<_$ConditionLogDatabase, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer({
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

  ColumnOrderings<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get panelId => $composableBuilder(
    column: $table.panelId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementsTableAnnotationComposer
    extends Composer<_$ConditionLogDatabase, $MeasurementsTable> {
  $$MeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get panelId =>
      $composableBuilder(column: $table.panelId, builder: (column) => column);
}

class $$MeasurementsTableTableManager
    extends
        RootTableManager<
          _$ConditionLogDatabase,
          $MeasurementsTable,
          Measurement,
          $$MeasurementsTableFilterComposer,
          $$MeasurementsTableOrderingComposer,
          $$MeasurementsTableAnnotationComposer,
          $$MeasurementsTableCreateCompanionBuilder,
          $$MeasurementsTableUpdateCompanionBuilder,
          (
            Measurement,
            BaseReferences<
              _$ConditionLogDatabase,
              $MeasurementsTable,
              Measurement
            >,
          ),
          Measurement,
          PrefetchHooks Function()
        > {
  $$MeasurementsTableTableManager(
    _$ConditionLogDatabase db,
    $MeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> takenAt = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int?> panelId = const Value.absent(),
              }) => MeasurementsCompanion(
                id: id,
                petId: petId,
                kind: kind,
                value: value,
                unit: unit,
                takenAt: takenAt,
                label: label,
                panelId: panelId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required String kind,
                required double value,
                required String unit,
                required int takenAt,
                Value<String?> label = const Value.absent(),
                Value<int?> panelId = const Value.absent(),
              }) => MeasurementsCompanion.insert(
                id: id,
                petId: petId,
                kind: kind,
                value: value,
                unit: unit,
                takenAt: takenAt,
                label: label,
                panelId: panelId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementsTable, Measurement>(table),
                  BaseReferences<
                    _$ConditionLogDatabase,
                    $MeasurementsTable,
                    Measurement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConditionLogDatabase,
      $MeasurementsTable,
      Measurement,
      $$MeasurementsTableFilterComposer,
      $$MeasurementsTableOrderingComposer,
      $$MeasurementsTableAnnotationComposer,
      $$MeasurementsTableCreateCompanionBuilder,
      $$MeasurementsTableUpdateCompanionBuilder,
      (
        Measurement,
        BaseReferences<_$ConditionLogDatabase, $MeasurementsTable, Measurement>,
      ),
      Measurement,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  required int petId,
  required int at,
  required String body,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<int> petId,
  Value<int> at,
  Value<String> body,
});

class $$NotesTableFilterComposer
    extends Composer<_$ConditionLogDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$ConditionLogDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$ConditionLogDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$ConditionLogDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$ConditionLogDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$ConditionLogDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> petId = const Value.absent(),
            Value<int> at = const Value.absent(),
            Value<String> body = const Value.absent(),
          }) => NotesCompanion(id: id, petId: petId, at: at, body: body),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int petId,
            required int at,
            required String body,
          }) => NotesCompanion.insert(id: id, petId: petId, at: at, body: body),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, Note>(table),
                  BaseReferences<_$ConditionLogDatabase, $NotesTable, Note>(
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

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$ConditionLogDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$ConditionLogDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;
typedef $$ReportRunsTableCreateCompanionBuilder = ReportRunsCompanion Function({
  Value<int> id,
  required int petId,
  required int fromAt,
  required int toAt,
  required int generatedAt,
  required String path,
  required String format,
});
typedef $$ReportRunsTableUpdateCompanionBuilder = ReportRunsCompanion Function({
  Value<int> id,
  Value<int> petId,
  Value<int> fromAt,
  Value<int> toAt,
  Value<int> generatedAt,
  Value<String> path,
  Value<String> format,
});

class $$ReportRunsTableFilterComposer
    extends Composer<_$ConditionLogDatabase, $ReportRunsTable> {
  $$ReportRunsTableFilterComposer({
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

  ColumnFilters<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromAt => $composableBuilder(
    column: $table.fromAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toAt => $composableBuilder(
    column: $table.toAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReportRunsTableOrderingComposer
    extends Composer<_$ConditionLogDatabase, $ReportRunsTable> {
  $$ReportRunsTableOrderingComposer({
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

  ColumnOrderings<int> get petId => $composableBuilder(
    column: $table.petId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromAt => $composableBuilder(
    column: $table.fromAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toAt => $composableBuilder(
    column: $table.toAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReportRunsTableAnnotationComposer
    extends Composer<_$ConditionLogDatabase, $ReportRunsTable> {
  $$ReportRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get petId =>
      $composableBuilder(column: $table.petId, builder: (column) => column);

  GeneratedColumn<int> get fromAt =>
      $composableBuilder(column: $table.fromAt, builder: (column) => column);

  GeneratedColumn<int> get toAt =>
      $composableBuilder(column: $table.toAt, builder: (column) => column);

  GeneratedColumn<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);
}

class $$ReportRunsTableTableManager
    extends
        RootTableManager<
          _$ConditionLogDatabase,
          $ReportRunsTable,
          ReportRun,
          $$ReportRunsTableFilterComposer,
          $$ReportRunsTableOrderingComposer,
          $$ReportRunsTableAnnotationComposer,
          $$ReportRunsTableCreateCompanionBuilder,
          $$ReportRunsTableUpdateCompanionBuilder,
          (
            ReportRun,
            BaseReferences<_$ConditionLogDatabase, $ReportRunsTable, ReportRun>,
          ),
          ReportRun,
          PrefetchHooks Function()
        > {
  $$ReportRunsTableTableManager(
    _$ConditionLogDatabase db,
    $ReportRunsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> petId = const Value.absent(),
                Value<int> fromAt = const Value.absent(),
                Value<int> toAt = const Value.absent(),
                Value<int> generatedAt = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> format = const Value.absent(),
              }) => ReportRunsCompanion(
                id: id,
                petId: petId,
                fromAt: fromAt,
                toAt: toAt,
                generatedAt: generatedAt,
                path: path,
                format: format,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int petId,
                required int fromAt,
                required int toAt,
                required int generatedAt,
                required String path,
                required String format,
              }) => ReportRunsCompanion.insert(
                id: id,
                petId: petId,
                fromAt: fromAt,
                toAt: toAt,
                generatedAt: generatedAt,
                path: path,
                format: format,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReportRunsTable, ReportRun>(table),
                  BaseReferences<
                    _$ConditionLogDatabase,
                    $ReportRunsTable,
                    ReportRun
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReportRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConditionLogDatabase,
      $ReportRunsTable,
      ReportRun,
      $$ReportRunsTableFilterComposer,
      $$ReportRunsTableOrderingComposer,
      $$ReportRunsTableAnnotationComposer,
      $$ReportRunsTableCreateCompanionBuilder,
      $$ReportRunsTableUpdateCompanionBuilder,
      (
        ReportRun,
        BaseReferences<_$ConditionLogDatabase, $ReportRunsTable, ReportRun>,
      ),
      ReportRun,
      PrefetchHooks Function()
    >;

class $ConditionLogDatabaseManager {
  final _$ConditionLogDatabase _db;
  $ConditionLogDatabaseManager(this._db);
  $$PetsTableTableManager get pets => $$PetsTableTableManager(_db, _db.pets);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$DosesTableTableManager get doses =>
      $$DosesTableTableManager(_db, _db.doses);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$ReportRunsTableTableManager get reportRuns =>
      $$ReportRunsTableTableManager(_db, _db.reportRuns);
}
