// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BusinessesTable extends Businesses
    with TableInfo<$BusinessesTable, Business> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payViaMeta = const VerificationMeta('payVia');
  @override
  late final GeneratedColumn<String> payVia = GeneratedColumn<String>(
    'pay_via',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _defaultDepositPctMeta = const VerificationMeta(
    'defaultDepositPct',
  );
  @override
  late final GeneratedColumn<int> defaultDepositPct = GeneratedColumn<int>(
    'default_deposit_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _termsTextMeta = const VerificationMeta(
    'termsText',
  );
  @override
  late final GeneratedColumn<String> termsText = GeneratedColumn<String>(
    'terms_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextJobNumberMeta = const VerificationMeta(
    'nextJobNumber',
  );
  @override
  late final GeneratedColumn<int> nextJobNumber = GeneratedColumn<int>(
    'next_job_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1001),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    logoPath,
    phone,
    email,
    address,
    payVia,
    defaultDepositPct,
    termsText,
    nextJobNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'businesses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Business> instance, {
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
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('pay_via')) {
      context.handle(
        _payViaMeta,
        payVia.isAcceptableOrUnknown(data['pay_via']!, _payViaMeta),
      );
    }
    if (data.containsKey('default_deposit_pct')) {
      context.handle(
        _defaultDepositPctMeta,
        defaultDepositPct.isAcceptableOrUnknown(
          data['default_deposit_pct']!,
          _defaultDepositPctMeta,
        ),
      );
    }
    if (data.containsKey('terms_text')) {
      context.handle(
        _termsTextMeta,
        termsText.isAcceptableOrUnknown(data['terms_text']!, _termsTextMeta),
      );
    }
    if (data.containsKey('next_job_number')) {
      context.handle(
        _nextJobNumberMeta,
        nextJobNumber.isAcceptableOrUnknown(
          data['next_job_number']!,
          _nextJobNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Business map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Business(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      payVia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pay_via'],
      )!,
      defaultDepositPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_deposit_pct'],
      )!,
      termsText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terms_text'],
      ),
      nextJobNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_job_number'],
      )!,
    );
  }

  @override
  $BusinessesTable createAlias(String alias) {
    return $BusinessesTable(attachedDatabase, alias);
  }
}

class Business extends DataClass implements Insertable<Business> {
  final int id;
  final String name;
  final String? logoPath;
  final String? phone;
  final String? email;
  final String? address;
  final String payVia;
  final int defaultDepositPct;
  final String? termsText;
  final int nextJobNumber;
  const Business({
    required this.id,
    required this.name,
    this.logoPath,
    this.phone,
    this.email,
    this.address,
    required this.payVia,
    required this.defaultDepositPct,
    this.termsText,
    required this.nextJobNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['pay_via'] = Variable<String>(payVia);
    map['default_deposit_pct'] = Variable<int>(defaultDepositPct);
    if (!nullToAbsent || termsText != null) {
      map['terms_text'] = Variable<String>(termsText);
    }
    map['next_job_number'] = Variable<int>(nextJobNumber);
    return map;
  }

  BusinessesCompanion toCompanion(bool nullToAbsent) {
    return BusinessesCompanion(
      id: Value(id),
      name: Value(name),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      payVia: Value(payVia),
      defaultDepositPct: Value(defaultDepositPct),
      termsText: termsText == null && nullToAbsent
          ? const Value.absent()
          : Value(termsText),
      nextJobNumber: Value(nextJobNumber),
    );
  }

  factory Business.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Business(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      payVia: serializer.fromJson<String>(json['payVia']),
      defaultDepositPct: serializer.fromJson<int>(json['defaultDepositPct']),
      termsText: serializer.fromJson<String?>(json['termsText']),
      nextJobNumber: serializer.fromJson<int>(json['nextJobNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'logoPath': serializer.toJson<String?>(logoPath),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'payVia': serializer.toJson<String>(payVia),
      'defaultDepositPct': serializer.toJson<int>(defaultDepositPct),
      'termsText': serializer.toJson<String?>(termsText),
      'nextJobNumber': serializer.toJson<int>(nextJobNumber),
    };
  }

  Business copyWith({
    int? id,
    String? name,
    Value<String?> logoPath = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    String? payVia,
    int? defaultDepositPct,
    Value<String?> termsText = const Value.absent(),
    int? nextJobNumber,
  }) => Business(
    id: id ?? this.id,
    name: name ?? this.name,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    payVia: payVia ?? this.payVia,
    defaultDepositPct: defaultDepositPct ?? this.defaultDepositPct,
    termsText: termsText.present ? termsText.value : this.termsText,
    nextJobNumber: nextJobNumber ?? this.nextJobNumber,
  );
  Business copyWithCompanion(BusinessesCompanion data) {
    return Business(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      payVia: data.payVia.present ? data.payVia.value : this.payVia,
      defaultDepositPct: data.defaultDepositPct.present
          ? data.defaultDepositPct.value
          : this.defaultDepositPct,
      termsText: data.termsText.present ? data.termsText.value : this.termsText,
      nextJobNumber: data.nextJobNumber.present
          ? data.nextJobNumber.value
          : this.nextJobNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Business(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('payVia: $payVia, ')
          ..write('defaultDepositPct: $defaultDepositPct, ')
          ..write('termsText: $termsText, ')
          ..write('nextJobNumber: $nextJobNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    logoPath,
    phone,
    email,
    address,
    payVia,
    defaultDepositPct,
    termsText,
    nextJobNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Business &&
          other.id == this.id &&
          other.name == this.name &&
          other.logoPath == this.logoPath &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.payVia == this.payVia &&
          other.defaultDepositPct == this.defaultDepositPct &&
          other.termsText == this.termsText &&
          other.nextJobNumber == this.nextJobNumber);
}

class BusinessesCompanion extends UpdateCompanion<Business> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> logoPath;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String> payVia;
  final Value<int> defaultDepositPct;
  final Value<String?> termsText;
  final Value<int> nextJobNumber;
  const BusinessesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.payVia = const Value.absent(),
    this.defaultDepositPct = const Value.absent(),
    this.termsText = const Value.absent(),
    this.nextJobNumber = const Value.absent(),
  });
  BusinessesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.logoPath = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.payVia = const Value.absent(),
    this.defaultDepositPct = const Value.absent(),
    this.termsText = const Value.absent(),
    this.nextJobNumber = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Business> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? logoPath,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? payVia,
    Expression<int>? defaultDepositPct,
    Expression<String>? termsText,
    Expression<int>? nextJobNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logoPath != null) 'logo_path': logoPath,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (payVia != null) 'pay_via': payVia,
      if (defaultDepositPct != null) 'default_deposit_pct': defaultDepositPct,
      if (termsText != null) 'terms_text': termsText,
      if (nextJobNumber != null) 'next_job_number': nextJobNumber,
    });
  }

  BusinessesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? logoPath,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<String>? payVia,
    Value<int>? defaultDepositPct,
    Value<String?>? termsText,
    Value<int>? nextJobNumber,
  }) {
    return BusinessesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      payVia: payVia ?? this.payVia,
      defaultDepositPct: defaultDepositPct ?? this.defaultDepositPct,
      termsText: termsText ?? this.termsText,
      nextJobNumber: nextJobNumber ?? this.nextJobNumber,
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
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (payVia.present) {
      map['pay_via'] = Variable<String>(payVia.value);
    }
    if (defaultDepositPct.present) {
      map['default_deposit_pct'] = Variable<int>(defaultDepositPct.value);
    }
    if (termsText.present) {
      map['terms_text'] = Variable<String>(termsText.value);
    }
    if (nextJobNumber.present) {
      map['next_job_number'] = Variable<int>(nextJobNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('payVia: $payVia, ')
          ..write('defaultDepositPct: $defaultDepositPct, ')
          ..write('termsText: $termsText, ')
          ..write('nextJobNumber: $nextJobNumber')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, email, address];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
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
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
    };
  }

  Customer copyWith({
    int? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, email, address);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
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
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }
}

class $ServicesTable extends Services with TableInfo<$ServicesTable, Service> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    unit,
    unitPriceCents,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'services';
  @override
  VerificationContext validateIntegrity(
    Insertable<Service> instance, {
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
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Service map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Service(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ServicesTable createAlias(String alias) {
    return $ServicesTable(attachedDatabase, alias);
  }
}

class Service extends DataClass implements Insertable<Service> {
  final int id;
  final String name;
  final String unit;
  final int unitPriceCents;
  final int sortOrder;
  const Service({
    required this.id,
    required this.name,
    required this.unit,
    required this.unitPriceCents,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ServicesCompanion toCompanion(bool nullToAbsent) {
    return ServicesCompanion(
      id: Value(id),
      name: Value(name),
      unit: Value(unit),
      unitPriceCents: Value(unitPriceCents),
      sortOrder: Value(sortOrder),
    );
  }

  factory Service.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Service(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Service copyWith({
    int? id,
    String? name,
    String? unit,
    int? unitPriceCents,
    int? sortOrder,
  }) => Service(
    id: id ?? this.id,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Service copyWithCompanion(ServicesCompanion data) {
    return Service(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Service(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, unit, unitPriceCents, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Service &&
          other.id == this.id &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.unitPriceCents == this.unitPriceCents &&
          other.sortOrder == this.sortOrder);
}

class ServicesCompanion extends UpdateCompanion<Service> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> unit;
  final Value<int> unitPriceCents;
  final Value<int> sortOrder;
  const ServicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ServicesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String unit,
    required int unitPriceCents,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       unit = Value(unit),
       unitPriceCents = Value(unitPriceCents);
  static Insertable<Service> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<int>? unitPriceCents,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ServicesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? unit,
    Value<int>? unitPriceCents,
    Value<int>? sortOrder,
  }) {
    return ServicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $JobsTable extends Jobs with TableInfo<$JobsTable, Job> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<int> sentAt = GeneratedColumn<int>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<int> acceptedAt = GeneratedColumn<int>(
    'accepted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<int> paidAt = GeneratedColumn<int>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depositPctMeta = const VerificationMeta(
    'depositPct',
  );
  @override
  late final GeneratedColumn<int> depositPct = GeneratedColumn<int>(
    'deposit_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stripeLinkUrlMeta = const VerificationMeta(
    'stripeLinkUrl',
  );
  @override
  late final GeneratedColumn<String> stripeLinkUrl = GeneratedColumn<String>(
    'stripe_link_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    status,
    number,
    createdAt,
    sentAt,
    acceptedAt,
    paidAt,
    depositPct,
    notes,
    stripeLinkUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Job> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    if (data.containsKey('deposit_pct')) {
      context.handle(
        _depositPctMeta,
        depositPct.isAcceptableOrUnknown(data['deposit_pct']!, _depositPctMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('stripe_link_url')) {
      context.handle(
        _stripeLinkUrlMeta,
        stripeLinkUrl.isAcceptableOrUnknown(
          data['stripe_link_url']!,
          _stripeLinkUrlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Job map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Job(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_at'],
      ),
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accepted_at'],
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_at'],
      ),
      depositPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deposit_pct'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      stripeLinkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stripe_link_url'],
      ),
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }
}

class Job extends DataClass implements Insertable<Job> {
  final int id;
  final int? customerId;
  final String status;
  final int number;
  final int createdAt;
  final int? sentAt;
  final int? acceptedAt;
  final int? paidAt;
  final int depositPct;
  final String? notes;
  final String? stripeLinkUrl;
  const Job({
    required this.id,
    this.customerId,
    required this.status,
    required this.number,
    required this.createdAt,
    this.sentAt,
    this.acceptedAt,
    this.paidAt,
    required this.depositPct,
    this.notes,
    this.stripeLinkUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<int>(customerId);
    }
    map['status'] = Variable<String>(status);
    map['number'] = Variable<int>(number);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<int>(sentAt);
    }
    if (!nullToAbsent || acceptedAt != null) {
      map['accepted_at'] = Variable<int>(acceptedAt);
    }
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<int>(paidAt);
    }
    map['deposit_pct'] = Variable<int>(depositPct);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || stripeLinkUrl != null) {
      map['stripe_link_url'] = Variable<String>(stripeLinkUrl);
    }
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      status: Value(status),
      number: Value(number),
      createdAt: Value(createdAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      acceptedAt: acceptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedAt),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      depositPct: Value(depositPct),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      stripeLinkUrl: stripeLinkUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(stripeLinkUrl),
    );
  }

  factory Job.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Job(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int?>(json['customerId']),
      status: serializer.fromJson<String>(json['status']),
      number: serializer.fromJson<int>(json['number']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      sentAt: serializer.fromJson<int?>(json['sentAt']),
      acceptedAt: serializer.fromJson<int?>(json['acceptedAt']),
      paidAt: serializer.fromJson<int?>(json['paidAt']),
      depositPct: serializer.fromJson<int>(json['depositPct']),
      notes: serializer.fromJson<String?>(json['notes']),
      stripeLinkUrl: serializer.fromJson<String?>(json['stripeLinkUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int?>(customerId),
      'status': serializer.toJson<String>(status),
      'number': serializer.toJson<int>(number),
      'createdAt': serializer.toJson<int>(createdAt),
      'sentAt': serializer.toJson<int?>(sentAt),
      'acceptedAt': serializer.toJson<int?>(acceptedAt),
      'paidAt': serializer.toJson<int?>(paidAt),
      'depositPct': serializer.toJson<int>(depositPct),
      'notes': serializer.toJson<String?>(notes),
      'stripeLinkUrl': serializer.toJson<String?>(stripeLinkUrl),
    };
  }

  Job copyWith({
    int? id,
    Value<int?> customerId = const Value.absent(),
    String? status,
    int? number,
    int? createdAt,
    Value<int?> sentAt = const Value.absent(),
    Value<int?> acceptedAt = const Value.absent(),
    Value<int?> paidAt = const Value.absent(),
    int? depositPct,
    Value<String?> notes = const Value.absent(),
    Value<String?> stripeLinkUrl = const Value.absent(),
  }) => Job(
    id: id ?? this.id,
    customerId: customerId.present ? customerId.value : this.customerId,
    status: status ?? this.status,
    number: number ?? this.number,
    createdAt: createdAt ?? this.createdAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    acceptedAt: acceptedAt.present ? acceptedAt.value : this.acceptedAt,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    depositPct: depositPct ?? this.depositPct,
    notes: notes.present ? notes.value : this.notes,
    stripeLinkUrl: stripeLinkUrl.present
        ? stripeLinkUrl.value
        : this.stripeLinkUrl,
  );
  Job copyWithCompanion(JobsCompanion data) {
    return Job(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      status: data.status.present ? data.status.value : this.status,
      number: data.number.present ? data.number.value : this.number,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      acceptedAt: data.acceptedAt.present
          ? data.acceptedAt.value
          : this.acceptedAt,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      depositPct: data.depositPct.present
          ? data.depositPct.value
          : this.depositPct,
      notes: data.notes.present ? data.notes.value : this.notes,
      stripeLinkUrl: data.stripeLinkUrl.present
          ? data.stripeLinkUrl.value
          : this.stripeLinkUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Job(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('number: $number, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('depositPct: $depositPct, ')
          ..write('notes: $notes, ')
          ..write('stripeLinkUrl: $stripeLinkUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    status,
    number,
    createdAt,
    sentAt,
    acceptedAt,
    paidAt,
    depositPct,
    notes,
    stripeLinkUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.status == this.status &&
          other.number == this.number &&
          other.createdAt == this.createdAt &&
          other.sentAt == this.sentAt &&
          other.acceptedAt == this.acceptedAt &&
          other.paidAt == this.paidAt &&
          other.depositPct == this.depositPct &&
          other.notes == this.notes &&
          other.stripeLinkUrl == this.stripeLinkUrl);
}

class JobsCompanion extends UpdateCompanion<Job> {
  final Value<int> id;
  final Value<int?> customerId;
  final Value<String> status;
  final Value<int> number;
  final Value<int> createdAt;
  final Value<int?> sentAt;
  final Value<int?> acceptedAt;
  final Value<int?> paidAt;
  final Value<int> depositPct;
  final Value<String?> notes;
  final Value<String?> stripeLinkUrl;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.number = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.depositPct = const Value.absent(),
    this.notes = const Value.absent(),
    this.stripeLinkUrl = const Value.absent(),
  });
  JobsCompanion.insert({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    required String status,
    required int number,
    required int createdAt,
    this.sentAt = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.depositPct = const Value.absent(),
    this.notes = const Value.absent(),
    this.stripeLinkUrl = const Value.absent(),
  }) : status = Value(status),
       number = Value(number),
       createdAt = Value(createdAt);
  static Insertable<Job> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<String>? status,
    Expression<int>? number,
    Expression<int>? createdAt,
    Expression<int>? sentAt,
    Expression<int>? acceptedAt,
    Expression<int>? paidAt,
    Expression<int>? depositPct,
    Expression<String>? notes,
    Expression<String>? stripeLinkUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
      if (number != null) 'number': number,
      if (createdAt != null) 'created_at': createdAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (paidAt != null) 'paid_at': paidAt,
      if (depositPct != null) 'deposit_pct': depositPct,
      if (notes != null) 'notes': notes,
      if (stripeLinkUrl != null) 'stripe_link_url': stripeLinkUrl,
    });
  }

  JobsCompanion copyWith({
    Value<int>? id,
    Value<int?>? customerId,
    Value<String>? status,
    Value<int>? number,
    Value<int>? createdAt,
    Value<int?>? sentAt,
    Value<int?>? acceptedAt,
    Value<int?>? paidAt,
    Value<int>? depositPct,
    Value<String?>? notes,
    Value<String?>? stripeLinkUrl,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      number: number ?? this.number,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      paidAt: paidAt ?? this.paidAt,
      depositPct: depositPct ?? this.depositPct,
      notes: notes ?? this.notes,
      stripeLinkUrl: stripeLinkUrl ?? this.stripeLinkUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<int>(sentAt.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<int>(acceptedAt.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<int>(paidAt.value);
    }
    if (depositPct.present) {
      map['deposit_pct'] = Variable<int>(depositPct.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (stripeLinkUrl.present) {
      map['stripe_link_url'] = Variable<String>(stripeLinkUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('number: $number, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('depositPct: $depositPct, ')
          ..write('notes: $notes, ')
          ..write('stripeLinkUrl: $stripeLinkUrl')
          ..write(')'))
        .toString();
  }
}

class $LineItemsTable extends LineItems
    with TableInfo<$LineItemsTable, LineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceIdMeta = const VerificationMeta(
    'serviceId',
  );
  @override
  late final GeneratedColumn<int> serviceId = GeneratedColumn<int>(
    'service_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    serviceId,
    description,
    qty,
    unitPriceCents,
    totalCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('service_id')) {
      context.handle(
        _serviceIdMeta,
        serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      )!,
      serviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qty'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
    );
  }

  @override
  $LineItemsTable createAlias(String alias) {
    return $LineItemsTable(attachedDatabase, alias);
  }
}

class LineItem extends DataClass implements Insertable<LineItem> {
  final int id;
  final int jobId;
  final int? serviceId;
  final String description;
  final double qty;
  final int unitPriceCents;
  final int totalCents;
  const LineItem({
    required this.id,
    required this.jobId,
    this.serviceId,
    required this.description,
    required this.qty,
    required this.unitPriceCents,
    required this.totalCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<int>(jobId);
    if (!nullToAbsent || serviceId != null) {
      map['service_id'] = Variable<int>(serviceId);
    }
    map['description'] = Variable<String>(description);
    map['qty'] = Variable<double>(qty);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['total_cents'] = Variable<int>(totalCents);
    return map;
  }

  LineItemsCompanion toCompanion(bool nullToAbsent) {
    return LineItemsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      serviceId: serviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceId),
      description: Value(description),
      qty: Value(qty),
      unitPriceCents: Value(unitPriceCents),
      totalCents: Value(totalCents),
    );
  }

  factory LineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineItem(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<int>(json['jobId']),
      serviceId: serializer.fromJson<int?>(json['serviceId']),
      description: serializer.fromJson<String>(json['description']),
      qty: serializer.fromJson<double>(json['qty']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<int>(jobId),
      'serviceId': serializer.toJson<int?>(serviceId),
      'description': serializer.toJson<String>(description),
      'qty': serializer.toJson<double>(qty),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'totalCents': serializer.toJson<int>(totalCents),
    };
  }

  LineItem copyWith({
    int? id,
    int? jobId,
    Value<int?> serviceId = const Value.absent(),
    String? description,
    double? qty,
    int? unitPriceCents,
    int? totalCents,
  }) => LineItem(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    serviceId: serviceId.present ? serviceId.value : this.serviceId,
    description: description ?? this.description,
    qty: qty ?? this.qty,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    totalCents: totalCents ?? this.totalCents,
  );
  LineItem copyWithCompanion(LineItemsCompanion data) {
    return LineItem(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      description: data.description.present
          ? data.description.value
          : this.description,
      qty: data.qty.present ? data.qty.value : this.qty,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineItem(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('serviceId: $serviceId, ')
          ..write('description: $description, ')
          ..write('qty: $qty, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalCents: $totalCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    serviceId,
    description,
    qty,
    unitPriceCents,
    totalCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineItem &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.serviceId == this.serviceId &&
          other.description == this.description &&
          other.qty == this.qty &&
          other.unitPriceCents == this.unitPriceCents &&
          other.totalCents == this.totalCents);
}

class LineItemsCompanion extends UpdateCompanion<LineItem> {
  final Value<int> id;
  final Value<int> jobId;
  final Value<int?> serviceId;
  final Value<String> description;
  final Value<double> qty;
  final Value<int> unitPriceCents;
  final Value<int> totalCents;
  const LineItemsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.description = const Value.absent(),
    this.qty = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.totalCents = const Value.absent(),
  });
  LineItemsCompanion.insert({
    this.id = const Value.absent(),
    required int jobId,
    this.serviceId = const Value.absent(),
    required String description,
    required double qty,
    required int unitPriceCents,
    required int totalCents,
  }) : jobId = Value(jobId),
       description = Value(description),
       qty = Value(qty),
       unitPriceCents = Value(unitPriceCents),
       totalCents = Value(totalCents);
  static Insertable<LineItem> custom({
    Expression<int>? id,
    Expression<int>? jobId,
    Expression<int>? serviceId,
    Expression<String>? description,
    Expression<double>? qty,
    Expression<int>? unitPriceCents,
    Expression<int>? totalCents,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (serviceId != null) 'service_id': serviceId,
      if (description != null) 'description': description,
      if (qty != null) 'qty': qty,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (totalCents != null) 'total_cents': totalCents,
    });
  }

  LineItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? jobId,
    Value<int?>? serviceId,
    Value<String>? description,
    Value<double>? qty,
    Value<int>? unitPriceCents,
    Value<int>? totalCents,
  }) {
    return LineItemsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      serviceId: serviceId ?? this.serviceId,
      description: description ?? this.description,
      qty: qty ?? this.qty,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      totalCents: totalCents ?? this.totalCents,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<int>(serviceId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineItemsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('serviceId: $serviceId, ')
          ..write('description: $description, ')
          ..write('qty: $qty, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalCents: $totalCents')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<int> jobId = GeneratedColumn<int>(
    'job_id',
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    path,
    kind,
    takenAt,
    caption,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}job_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taken_at'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final int id;
  final int jobId;
  final String path;
  final String kind;
  final int takenAt;
  final String? caption;
  const Photo({
    required this.id,
    required this.jobId,
    required this.path,
    required this.kind,
    required this.takenAt,
    this.caption,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<int>(jobId);
    map['path'] = Variable<String>(path);
    map['kind'] = Variable<String>(kind);
    map['taken_at'] = Variable<int>(takenAt);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      jobId: Value(jobId),
      path: Value(path),
      kind: Value(kind),
      takenAt: Value(takenAt),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<int>(json['jobId']),
      path: serializer.fromJson<String>(json['path']),
      kind: serializer.fromJson<String>(json['kind']),
      takenAt: serializer.fromJson<int>(json['takenAt']),
      caption: serializer.fromJson<String?>(json['caption']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<int>(jobId),
      'path': serializer.toJson<String>(path),
      'kind': serializer.toJson<String>(kind),
      'takenAt': serializer.toJson<int>(takenAt),
      'caption': serializer.toJson<String?>(caption),
    };
  }

  Photo copyWith({
    int? id,
    int? jobId,
    String? path,
    String? kind,
    int? takenAt,
    Value<String?> caption = const Value.absent(),
  }) => Photo(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    path: path ?? this.path,
    kind: kind ?? this.kind,
    takenAt: takenAt ?? this.takenAt,
    caption: caption.present ? caption.value : this.caption,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      path: data.path.present ? data.path.value : this.path,
      kind: data.kind.present ? data.kind.value : this.kind,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      caption: data.caption.present ? data.caption.value : this.caption,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('path: $path, ')
          ..write('kind: $kind, ')
          ..write('takenAt: $takenAt, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jobId, path, kind, takenAt, caption);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.path == this.path &&
          other.kind == this.kind &&
          other.takenAt == this.takenAt &&
          other.caption == this.caption);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<int> id;
  final Value<int> jobId;
  final Value<String> path;
  final Value<String> kind;
  final Value<int> takenAt;
  final Value<String?> caption;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.path = const Value.absent(),
    this.kind = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.caption = const Value.absent(),
  });
  PhotosCompanion.insert({
    this.id = const Value.absent(),
    required int jobId,
    required String path,
    required String kind,
    required int takenAt,
    this.caption = const Value.absent(),
  }) : jobId = Value(jobId),
       path = Value(path),
       kind = Value(kind),
       takenAt = Value(takenAt);
  static Insertable<Photo> custom({
    Expression<int>? id,
    Expression<int>? jobId,
    Expression<String>? path,
    Expression<String>? kind,
    Expression<int>? takenAt,
    Expression<String>? caption,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (path != null) 'path': path,
      if (kind != null) 'kind': kind,
      if (takenAt != null) 'taken_at': takenAt,
      if (caption != null) 'caption': caption,
    });
  }

  PhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? jobId,
    Value<String>? path,
    Value<String>? kind,
    Value<int>? takenAt,
    Value<String?>? caption,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      path: path ?? this.path,
      kind: kind ?? this.kind,
      takenAt: takenAt ?? this.takenAt,
      caption: caption ?? this.caption,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<int>(jobId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<int>(takenAt.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('path: $path, ')
          ..write('kind: $kind, ')
          ..write('takenAt: $takenAt, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BusinessesTable businesses = $BusinessesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $ServicesTable services = $ServicesTable(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $LineItemsTable lineItems = $LineItemsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    businesses,
    customers,
    services,
    jobs,
    lineItems,
    photos,
  ];
}

typedef $$BusinessesTableCreateCompanionBuilder = BusinessesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> logoPath,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String> payVia,
  Value<int> defaultDepositPct,
  Value<String?> termsText,
  Value<int> nextJobNumber,
});
typedef $$BusinessesTableUpdateCompanionBuilder = BusinessesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> logoPath,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String> payVia,
  Value<int> defaultDepositPct,
  Value<String?> termsText,
  Value<int> nextJobNumber,
});

class $$BusinessesTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableFilterComposer({
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

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payVia => $composableBuilder(
    column: $table.payVia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultDepositPct => $composableBuilder(
    column: $table.defaultDepositPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get termsText => $composableBuilder(
    column: $table.termsText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextJobNumber => $composableBuilder(
    column: $table.nextJobNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BusinessesTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableOrderingComposer({
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

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payVia => $composableBuilder(
    column: $table.payVia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultDepositPct => $composableBuilder(
    column: $table.defaultDepositPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termsText => $composableBuilder(
    column: $table.termsText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextJobNumber => $composableBuilder(
    column: $table.nextJobNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BusinessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableAnnotationComposer({
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

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get payVia =>
      $composableBuilder(column: $table.payVia, builder: (column) => column);

  GeneratedColumn<int> get defaultDepositPct => $composableBuilder(
    column: $table.defaultDepositPct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get termsText =>
      $composableBuilder(column: $table.termsText, builder: (column) => column);

  GeneratedColumn<int> get nextJobNumber => $composableBuilder(
    column: $table.nextJobNumber,
    builder: (column) => column,
  );
}

class $$BusinessesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessesTable,
          Business,
          $$BusinessesTableFilterComposer,
          $$BusinessesTableOrderingComposer,
          $$BusinessesTableAnnotationComposer,
          $$BusinessesTableCreateCompanionBuilder,
          $$BusinessesTableUpdateCompanionBuilder,
          (Business, BaseReferences<_$AppDatabase, $BusinessesTable, Business>),
          Business,
          PrefetchHooks Function()
        > {
  $$BusinessesTableTableManager(_$AppDatabase db, $BusinessesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> payVia = const Value.absent(),
                Value<int> defaultDepositPct = const Value.absent(),
                Value<String?> termsText = const Value.absent(),
                Value<int> nextJobNumber = const Value.absent(),
              }) => BusinessesCompanion(
                id: id,
                name: name,
                logoPath: logoPath,
                phone: phone,
                email: email,
                address: address,
                payVia: payVia,
                defaultDepositPct: defaultDepositPct,
                termsText: termsText,
                nextJobNumber: nextJobNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> logoPath = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> payVia = const Value.absent(),
                Value<int> defaultDepositPct = const Value.absent(),
                Value<String?> termsText = const Value.absent(),
                Value<int> nextJobNumber = const Value.absent(),
              }) => BusinessesCompanion.insert(
                id: id,
                name: name,
                logoPath: logoPath,
                phone: phone,
                email: email,
                address: address,
                payVia: payVia,
                defaultDepositPct: defaultDepositPct,
                termsText: termsText,
                nextJobNumber: nextJobNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BusinessesTable, Business>(table),
                  BaseReferences<_$AppDatabase, $BusinessesTable, Business>(
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

typedef $$BusinessesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessesTable,
      Business,
      $$BusinessesTableFilterComposer,
      $$BusinessesTableOrderingComposer,
      $$BusinessesTableAnnotationComposer,
      $$BusinessesTableCreateCompanionBuilder,
      $$BusinessesTableUpdateCompanionBuilder,
      (Business, BaseReferences<_$AppDatabase, $BusinessesTable, Business>),
      Business,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                address: address,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                address: address,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, Customer>(table),
                  BaseReferences<_$AppDatabase, $CustomersTable, Customer>(
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

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$ServicesTableCreateCompanionBuilder = ServicesCompanion Function({
  Value<int> id,
  required String name,
  required String unit,
  required int unitPriceCents,
  Value<int> sortOrder,
});
typedef $$ServicesTableUpdateCompanionBuilder = ServicesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> unit,
  Value<int> unitPriceCents,
  Value<int> sortOrder,
});

class $$ServicesTableFilterComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableFilterComposer({
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

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServicesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableOrderingComposer({
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

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableAnnotationComposer({
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

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ServicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServicesTable,
          Service,
          $$ServicesTableFilterComposer,
          $$ServicesTableOrderingComposer,
          $$ServicesTableAnnotationComposer,
          $$ServicesTableCreateCompanionBuilder,
          $$ServicesTableUpdateCompanionBuilder,
          (Service, BaseReferences<_$AppDatabase, $ServicesTable, Service>),
          Service,
          PrefetchHooks Function()
        > {
  $$ServicesTableTableManager(_$AppDatabase db, $ServicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ServicesCompanion(
                id: id,
                name: name,
                unit: unit,
                unitPriceCents: unitPriceCents,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String unit,
                required int unitPriceCents,
                Value<int> sortOrder = const Value.absent(),
              }) => ServicesCompanion.insert(
                id: id,
                name: name,
                unit: unit,
                unitPriceCents: unitPriceCents,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServicesTable, Service>(table),
                  BaseReferences<_$AppDatabase, $ServicesTable, Service>(
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

typedef $$ServicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServicesTable,
      Service,
      $$ServicesTableFilterComposer,
      $$ServicesTableOrderingComposer,
      $$ServicesTableAnnotationComposer,
      $$ServicesTableCreateCompanionBuilder,
      $$ServicesTableUpdateCompanionBuilder,
      (Service, BaseReferences<_$AppDatabase, $ServicesTable, Service>),
      Service,
      PrefetchHooks Function()
    >;
typedef $$JobsTableCreateCompanionBuilder = JobsCompanion Function({
  Value<int> id,
  Value<int?> customerId,
  required String status,
  required int number,
  required int createdAt,
  Value<int?> sentAt,
  Value<int?> acceptedAt,
  Value<int?> paidAt,
  Value<int> depositPct,
  Value<String?> notes,
  Value<String?> stripeLinkUrl,
});
typedef $$JobsTableUpdateCompanionBuilder = JobsCompanion Function({
  Value<int> id,
  Value<int?> customerId,
  Value<String> status,
  Value<int> number,
  Value<int> createdAt,
  Value<int?> sentAt,
  Value<int?> acceptedAt,
  Value<int?> paidAt,
  Value<int> depositPct,
  Value<String?> notes,
  Value<String?> stripeLinkUrl,
});

class $$JobsTableFilterComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
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

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depositPct => $composableBuilder(
    column: $table.depositPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stripeLinkUrl => $composableBuilder(
    column: $table.stripeLinkUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JobsTableOrderingComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
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

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depositPct => $composableBuilder(
    column: $table.depositPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stripeLinkUrl => $composableBuilder(
    column: $table.stripeLinkUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<int> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<int> get depositPct => $composableBuilder(
    column: $table.depositPct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get stripeLinkUrl => $composableBuilder(
    column: $table.stripeLinkUrl,
    builder: (column) => column,
  );
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTable,
          Job,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (Job, BaseReferences<_$AppDatabase, $JobsTable, Job>),
          Job,
          PrefetchHooks Function()
        > {
  $$JobsTableTableManager(_$AppDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> sentAt = const Value.absent(),
                Value<int?> acceptedAt = const Value.absent(),
                Value<int?> paidAt = const Value.absent(),
                Value<int> depositPct = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> stripeLinkUrl = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                customerId: customerId,
                status: status,
                number: number,
                createdAt: createdAt,
                sentAt: sentAt,
                acceptedAt: acceptedAt,
                paidAt: paidAt,
                depositPct: depositPct,
                notes: notes,
                stripeLinkUrl: stripeLinkUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> customerId = const Value.absent(),
                required String status,
                required int number,
                required int createdAt,
                Value<int?> sentAt = const Value.absent(),
                Value<int?> acceptedAt = const Value.absent(),
                Value<int?> paidAt = const Value.absent(),
                Value<int> depositPct = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> stripeLinkUrl = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                customerId: customerId,
                status: status,
                number: number,
                createdAt: createdAt,
                sentAt: sentAt,
                acceptedAt: acceptedAt,
                paidAt: paidAt,
                depositPct: depositPct,
                notes: notes,
                stripeLinkUrl: stripeLinkUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JobsTable, Job>(table),
                  BaseReferences<_$AppDatabase, $JobsTable, Job>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTable,
      Job,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (Job, BaseReferences<_$AppDatabase, $JobsTable, Job>),
      Job,
      PrefetchHooks Function()
    >;
typedef $$LineItemsTableCreateCompanionBuilder = LineItemsCompanion Function({
  Value<int> id,
  required int jobId,
  Value<int?> serviceId,
  required String description,
  required double qty,
  required int unitPriceCents,
  required int totalCents,
});
typedef $$LineItemsTableUpdateCompanionBuilder = LineItemsCompanion Function({
  Value<int> id,
  Value<int> jobId,
  Value<int?> serviceId,
  Value<String> description,
  Value<double> qty,
  Value<int> unitPriceCents,
  Value<int> totalCents,
});

class $$LineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LineItemsTable> {
  $$LineItemsTableFilterComposer({
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

  ColumnFilters<int> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serviceId => $composableBuilder(
    column: $table.serviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LineItemsTable> {
  $$LineItemsTableOrderingComposer({
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

  ColumnOrderings<int> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serviceId => $composableBuilder(
    column: $table.serviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineItemsTable> {
  $$LineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<int> get serviceId =>
      $composableBuilder(column: $table.serviceId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );
}

class $$LineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineItemsTable,
          LineItem,
          $$LineItemsTableFilterComposer,
          $$LineItemsTableOrderingComposer,
          $$LineItemsTableAnnotationComposer,
          $$LineItemsTableCreateCompanionBuilder,
          $$LineItemsTableUpdateCompanionBuilder,
          (LineItem, BaseReferences<_$AppDatabase, $LineItemsTable, LineItem>),
          LineItem,
          PrefetchHooks Function()
        > {
  $$LineItemsTableTableManager(_$AppDatabase db, $LineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jobId = const Value.absent(),
                Value<int?> serviceId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> qty = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
              }) => LineItemsCompanion(
                id: id,
                jobId: jobId,
                serviceId: serviceId,
                description: description,
                qty: qty,
                unitPriceCents: unitPriceCents,
                totalCents: totalCents,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jobId,
                Value<int?> serviceId = const Value.absent(),
                required String description,
                required double qty,
                required int unitPriceCents,
                required int totalCents,
              }) => LineItemsCompanion.insert(
                id: id,
                jobId: jobId,
                serviceId: serviceId,
                description: description,
                qty: qty,
                unitPriceCents: unitPriceCents,
                totalCents: totalCents,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineItemsTable, LineItem>(table),
                  BaseReferences<_$AppDatabase, $LineItemsTable, LineItem>(
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

typedef $$LineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineItemsTable,
      LineItem,
      $$LineItemsTableFilterComposer,
      $$LineItemsTableOrderingComposer,
      $$LineItemsTableAnnotationComposer,
      $$LineItemsTableCreateCompanionBuilder,
      $$LineItemsTableUpdateCompanionBuilder,
      (LineItem, BaseReferences<_$AppDatabase, $LineItemsTable, LineItem>),
      LineItem,
      PrefetchHooks Function()
    >;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  Value<int> id,
  required int jobId,
  required String path,
  required String kind,
  required int takenAt,
  Value<String?> caption,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<int> id,
  Value<int> jobId,
  Value<String> path,
  Value<String> kind,
  Value<int> takenAt,
  Value<String?> caption,
});

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
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

  ColumnFilters<int> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
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

  ColumnOrderings<int> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
          Photo,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jobId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> takenAt = const Value.absent(),
                Value<String?> caption = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                jobId: jobId,
                path: path,
                kind: kind,
                takenAt: takenAt,
                caption: caption,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jobId,
                required String path,
                required String kind,
                required int takenAt,
                Value<String?> caption = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                jobId: jobId,
                path: path,
                kind: kind,
                takenAt: takenAt,
                caption: caption,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, Photo>(table),
                  BaseReferences<_$AppDatabase, $PhotosTable, Photo>(
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

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
      Photo,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db, _db.businesses);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$ServicesTableTableManager get services =>
      $$ServicesTableTableManager(_db, _db.services);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$LineItemsTableTableManager get lineItems =>
      $$LineItemsTableTableManager(_db, _db.lineItems);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
}
