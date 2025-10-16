// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
    'mobile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    mobile,
    username,
    password,
    age,
    heightCm,
    weightKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('mobile')) {
      context.handle(
        _mobileMeta,
        mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {email},
    {username},
  ];
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      mobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String email;
  final String? mobile;
  final String username;
  final String password;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  const User({
    required this.id,
    required this.email,
    this.mobile,
    required this.username,
    required this.password,
    this.age,
    this.heightCm,
    this.weightKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || mobile != null) {
      map['mobile'] = Variable<String>(mobile);
    }
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      mobile: mobile == null && nullToAbsent
          ? const Value.absent()
          : Value(mobile),
      username: Value(username),
      password: Value(password),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      mobile: serializer.fromJson<String?>(json['mobile']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      age: serializer.fromJson<int?>(json['age']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'mobile': serializer.toJson<String?>(mobile),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'age': serializer.toJson<int?>(age),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
    };
  }

  User copyWith({
    int? id,
    String? email,
    Value<String?> mobile = const Value.absent(),
    String? username,
    String? password,
    Value<int?> age = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    mobile: mobile.present ? mobile.value : this.mobile,
    username: username ?? this.username,
    password: password ?? this.password,
    age: age.present ? age.value : this.age,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      age: data.age.present ? data.age.value : this.age,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('mobile: $mobile, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('age: $age, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    mobile,
    username,
    password,
    age,
    heightCm,
    weightKg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.mobile == this.mobile &&
          other.username == this.username &&
          other.password == this.password &&
          other.age == this.age &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> email;
  final Value<String?> mobile;
  final Value<String> username;
  final Value<String> password;
  final Value<int?> age;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.mobile = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.age = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    this.mobile = const Value.absent(),
    required String username,
    required String password,
    this.age = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
  }) : email = Value(email),
       username = Value(username),
       password = Value(password);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? mobile,
    Expression<String>? username,
    Expression<String>? password,
    Expression<int>? age,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (mobile != null) 'mobile': mobile,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (age != null) 'age': age,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String?>? mobile,
    Value<String>? username,
    Value<String>? password,
    Value<int?>? age,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      username: username ?? this.username,
      password: password ?? this.password,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('mobile: $mobile, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('age: $age, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }
}

class $FitnessGoalsTable extends FitnessGoals
    with TableInfo<$FitnessGoalsTable, FitnessGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FitnessGoalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyCaloriesMeta = const VerificationMeta(
    'dailyCalories',
  );
  @override
  late final GeneratedColumn<int> dailyCalories = GeneratedColumn<int>(
    'daily_calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dailyMinutesMeta = const VerificationMeta(
    'dailyMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyMinutes = GeneratedColumn<int>(
    'daily_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dailyStepsMeta = const VerificationMeta(
    'dailySteps',
  );
  @override
  late final GeneratedColumn<int> dailySteps = GeneratedColumn<int>(
    'daily_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    dailyCalories,
    dailyMinutes,
    dailySteps,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fitness_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<FitnessGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('daily_calories')) {
      context.handle(
        _dailyCaloriesMeta,
        dailyCalories.isAcceptableOrUnknown(
          data['daily_calories']!,
          _dailyCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('daily_minutes')) {
      context.handle(
        _dailyMinutesMeta,
        dailyMinutes.isAcceptableOrUnknown(
          data['daily_minutes']!,
          _dailyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('daily_steps')) {
      context.handle(
        _dailyStepsMeta,
        dailySteps.isAcceptableOrUnknown(data['daily_steps']!, _dailyStepsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FitnessGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FitnessGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      dailyCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_calories'],
      )!,
      dailyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_minutes'],
      )!,
      dailySteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_steps'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $FitnessGoalsTable createAlias(String alias) {
    return $FitnessGoalsTable(attachedDatabase, alias);
  }
}

class FitnessGoal extends DataClass implements Insertable<FitnessGoal> {
  final int id;
  final int userId;
  final int dailyCalories;
  final int dailyMinutes;
  final int dailySteps;
  final String? notes;
  const FitnessGoal({
    required this.id,
    required this.userId,
    required this.dailyCalories,
    required this.dailyMinutes,
    required this.dailySteps,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['daily_calories'] = Variable<int>(dailyCalories);
    map['daily_minutes'] = Variable<int>(dailyMinutes);
    map['daily_steps'] = Variable<int>(dailySteps);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  FitnessGoalsCompanion toCompanion(bool nullToAbsent) {
    return FitnessGoalsCompanion(
      id: Value(id),
      userId: Value(userId),
      dailyCalories: Value(dailyCalories),
      dailyMinutes: Value(dailyMinutes),
      dailySteps: Value(dailySteps),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory FitnessGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FitnessGoal(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      dailyCalories: serializer.fromJson<int>(json['dailyCalories']),
      dailyMinutes: serializer.fromJson<int>(json['dailyMinutes']),
      dailySteps: serializer.fromJson<int>(json['dailySteps']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'dailyCalories': serializer.toJson<int>(dailyCalories),
      'dailyMinutes': serializer.toJson<int>(dailyMinutes),
      'dailySteps': serializer.toJson<int>(dailySteps),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  FitnessGoal copyWith({
    int? id,
    int? userId,
    int? dailyCalories,
    int? dailyMinutes,
    int? dailySteps,
    Value<String?> notes = const Value.absent(),
  }) => FitnessGoal(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    dailyCalories: dailyCalories ?? this.dailyCalories,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    dailySteps: dailySteps ?? this.dailySteps,
    notes: notes.present ? notes.value : this.notes,
  );
  FitnessGoal copyWithCompanion(FitnessGoalsCompanion data) {
    return FitnessGoal(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      dailyCalories: data.dailyCalories.present
          ? data.dailyCalories.value
          : this.dailyCalories,
      dailyMinutes: data.dailyMinutes.present
          ? data.dailyMinutes.value
          : this.dailyMinutes,
      dailySteps: data.dailySteps.present
          ? data.dailySteps.value
          : this.dailySteps,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FitnessGoal(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dailyCalories: $dailyCalories, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('dailySteps: $dailySteps, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, dailyCalories, dailyMinutes, dailySteps, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FitnessGoal &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.dailyCalories == this.dailyCalories &&
          other.dailyMinutes == this.dailyMinutes &&
          other.dailySteps == this.dailySteps &&
          other.notes == this.notes);
}

class FitnessGoalsCompanion extends UpdateCompanion<FitnessGoal> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> dailyCalories;
  final Value<int> dailyMinutes;
  final Value<int> dailySteps;
  final Value<String?> notes;
  const FitnessGoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.dailyCalories = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    this.dailySteps = const Value.absent(),
    this.notes = const Value.absent(),
  });
  FitnessGoalsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.dailyCalories = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    this.dailySteps = const Value.absent(),
    this.notes = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<FitnessGoal> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? dailyCalories,
    Expression<int>? dailyMinutes,
    Expression<int>? dailySteps,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (dailyCalories != null) 'daily_calories': dailyCalories,
      if (dailyMinutes != null) 'daily_minutes': dailyMinutes,
      if (dailySteps != null) 'daily_steps': dailySteps,
      if (notes != null) 'notes': notes,
    });
  }

  FitnessGoalsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? dailyCalories,
    Value<int>? dailyMinutes,
    Value<int>? dailySteps,
    Value<String?>? notes,
  }) {
    return FitnessGoalsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      dailySteps: dailySteps ?? this.dailySteps,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (dailyCalories.present) {
      map['daily_calories'] = Variable<int>(dailyCalories.value);
    }
    if (dailyMinutes.present) {
      map['daily_minutes'] = Variable<int>(dailyMinutes.value);
    }
    if (dailySteps.present) {
      map['daily_steps'] = Variable<int>(dailySteps.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FitnessGoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('dailyCalories: $dailyCalories, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('dailySteps: $dailySteps, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $FitnessChallengesTable extends FitnessChallenges
    with TableInfo<$FitnessChallengesTable, FitnessChallenge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FitnessChallengesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryCoinsMeta = const VerificationMeta(
    'entryCoins',
  );
  @override
  late final GeneratedColumn<int> entryCoins = GeneratedColumn<int>(
    'entry_coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetJsonMeta = const VerificationMeta(
    'targetJson',
  );
  @override
  late final GeneratedColumn<String> targetJson = GeneratedColumn<String>(
    'target_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    description,
    type,
    startDate,
    endDate,
    entryCoins,
    targetJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fitness_challenges';
  @override
  VerificationContext validateIntegrity(
    Insertable<FitnessChallenge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('entry_coins')) {
      context.handle(
        _entryCoinsMeta,
        entryCoins.isAcceptableOrUnknown(data['entry_coins']!, _entryCoinsMeta),
      );
    }
    if (data.containsKey('target_json')) {
      context.handle(
        _targetJsonMeta,
        targetJson.isAcceptableOrUnknown(data['target_json']!, _targetJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FitnessChallenge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FitnessChallenge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      entryCoins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_coins'],
      )!,
      targetJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_json'],
      ),
    );
  }

  @override
  $FitnessChallengesTable createAlias(String alias) {
    return $FitnessChallengesTable(attachedDatabase, alias);
  }
}

class FitnessChallenge extends DataClass
    implements Insertable<FitnessChallenge> {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final int entryCoins;
  final String? targetJson;
  const FitnessChallenge({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.entryCoins,
    this.targetJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['type'] = Variable<String>(type);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['entry_coins'] = Variable<int>(entryCoins);
    if (!nullToAbsent || targetJson != null) {
      map['target_json'] = Variable<String>(targetJson);
    }
    return map;
  }

  FitnessChallengesCompanion toCompanion(bool nullToAbsent) {
    return FitnessChallengesCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: Value(description),
      type: Value(type),
      startDate: Value(startDate),
      endDate: Value(endDate),
      entryCoins: Value(entryCoins),
      targetJson: targetJson == null && nullToAbsent
          ? const Value.absent()
          : Value(targetJson),
    );
  }

  factory FitnessChallenge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FitnessChallenge(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      entryCoins: serializer.fromJson<int>(json['entryCoins']),
      targetJson: serializer.fromJson<String?>(json['targetJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<String>(type),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'entryCoins': serializer.toJson<int>(entryCoins),
      'targetJson': serializer.toJson<String?>(targetJson),
    };
  }

  FitnessChallenge copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? entryCoins,
    Value<String?> targetJson = const Value.absent(),
  }) => FitnessChallenge(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    type: type ?? this.type,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    entryCoins: entryCoins ?? this.entryCoins,
    targetJson: targetJson.present ? targetJson.value : this.targetJson,
  );
  FitnessChallenge copyWithCompanion(FitnessChallengesCompanion data) {
    return FitnessChallenge(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      entryCoins: data.entryCoins.present
          ? data.entryCoins.value
          : this.entryCoins,
      targetJson: data.targetJson.present
          ? data.targetJson.value
          : this.targetJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FitnessChallenge(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('entryCoins: $entryCoins, ')
          ..write('targetJson: $targetJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    description,
    type,
    startDate,
    endDate,
    entryCoins,
    targetJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FitnessChallenge &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.entryCoins == this.entryCoins &&
          other.targetJson == this.targetJson);
}

class FitnessChallengesCompanion extends UpdateCompanion<FitnessChallenge> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> title;
  final Value<String> description;
  final Value<String> type;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int> entryCoins;
  final Value<String?> targetJson;
  const FitnessChallengesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.entryCoins = const Value.absent(),
    this.targetJson = const Value.absent(),
  });
  FitnessChallengesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String title,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    this.entryCoins = const Value.absent(),
    this.targetJson = const Value.absent(),
  }) : userId = Value(userId),
       title = Value(title),
       description = Value(description),
       type = Value(type),
       startDate = Value(startDate),
       endDate = Value(endDate);
  static Insertable<FitnessChallenge> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? entryCoins,
    Expression<String>? targetJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (entryCoins != null) 'entry_coins': entryCoins,
      if (targetJson != null) 'target_json': targetJson,
    });
  }

  FitnessChallengesCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? title,
    Value<String>? description,
    Value<String>? type,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<int>? entryCoins,
    Value<String?>? targetJson,
  }) {
    return FitnessChallengesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      entryCoins: entryCoins ?? this.entryCoins,
      targetJson: targetJson ?? this.targetJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (entryCoins.present) {
      map['entry_coins'] = Variable<int>(entryCoins.value);
    }
    if (targetJson.present) {
      map['target_json'] = Variable<String>(targetJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FitnessChallengesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('entryCoins: $entryCoins, ')
          ..write('targetJson: $targetJson')
          ..write(')'))
        .toString();
  }
}

class $ZenBalancesTable extends ZenBalances
    with TableInfo<$ZenBalancesTable, ZenBalance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZenBalancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
    'coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [userId, coins];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zen_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZenBalance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('coins')) {
      context.handle(
        _coinsMeta,
        coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ZenBalance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZenBalance(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      coins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins'],
      )!,
    );
  }

  @override
  $ZenBalancesTable createAlias(String alias) {
    return $ZenBalancesTable(attachedDatabase, alias);
  }
}

class ZenBalance extends DataClass implements Insertable<ZenBalance> {
  final int userId;
  final int coins;
  const ZenBalance({required this.userId, required this.coins});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['coins'] = Variable<int>(coins);
    return map;
  }

  ZenBalancesCompanion toCompanion(bool nullToAbsent) {
    return ZenBalancesCompanion(userId: Value(userId), coins: Value(coins));
  }

  factory ZenBalance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZenBalance(
      userId: serializer.fromJson<int>(json['userId']),
      coins: serializer.fromJson<int>(json['coins']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'coins': serializer.toJson<int>(coins),
    };
  }

  ZenBalance copyWith({int? userId, int? coins}) =>
      ZenBalance(userId: userId ?? this.userId, coins: coins ?? this.coins);
  ZenBalance copyWithCompanion(ZenBalancesCompanion data) {
    return ZenBalance(
      userId: data.userId.present ? data.userId.value : this.userId,
      coins: data.coins.present ? data.coins.value : this.coins,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZenBalance(')
          ..write('userId: $userId, ')
          ..write('coins: $coins')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, coins);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZenBalance &&
          other.userId == this.userId &&
          other.coins == this.coins);
}

class ZenBalancesCompanion extends UpdateCompanion<ZenBalance> {
  final Value<int> userId;
  final Value<int> coins;
  const ZenBalancesCompanion({
    this.userId = const Value.absent(),
    this.coins = const Value.absent(),
  });
  ZenBalancesCompanion.insert({
    this.userId = const Value.absent(),
    this.coins = const Value.absent(),
  });
  static Insertable<ZenBalance> custom({
    Expression<int>? userId,
    Expression<int>? coins,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (coins != null) 'coins': coins,
    });
  }

  ZenBalancesCompanion copyWith({Value<int>? userId, Value<int>? coins}) {
    return ZenBalancesCompanion(
      userId: userId ?? this.userId,
      coins: coins ?? this.coins,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZenBalancesCompanion(')
          ..write('userId: $userId, ')
          ..write('coins: $coins')
          ..write(')'))
        .toString();
  }
}

class $WalletTransactionsTable extends WalletTransactions
    with TableInfo<$WalletTransactionsTable, WalletTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletTransactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCoinsMeta = const VerificationMeta(
    'amountCoins',
  );
  @override
  late final GeneratedColumn<int> amountCoins = GeneratedColumn<int>(
    'amount_coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    amountCoins,
    type,
    description,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount_coins')) {
      context.handle(
        _amountCoinsMeta,
        amountCoins.isAcceptableOrUnknown(
          data['amount_coins']!,
          _amountCoinsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCoinsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      amountCoins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_coins'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $WalletTransactionsTable createAlias(String alias) {
    return $WalletTransactionsTable(attachedDatabase, alias);
  }
}

class WalletTransaction extends DataClass
    implements Insertable<WalletTransaction> {
  final int id;
  final int userId;
  final int amountCoins;
  final String type;
  final String? description;
  final DateTime timestamp;
  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.amountCoins,
    required this.type,
    this.description,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['amount_coins'] = Variable<int>(amountCoins);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  WalletTransactionsCompanion toCompanion(bool nullToAbsent) {
    return WalletTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      amountCoins: Value(amountCoins),
      type: Value(type),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      timestamp: Value(timestamp),
    );
  }

  factory WalletTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletTransaction(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      amountCoins: serializer.fromJson<int>(json['amountCoins']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String?>(json['description']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'amountCoins': serializer.toJson<int>(amountCoins),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String?>(description),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  WalletTransaction copyWith({
    int? id,
    int? userId,
    int? amountCoins,
    String? type,
    Value<String?> description = const Value.absent(),
    DateTime? timestamp,
  }) => WalletTransaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amountCoins: amountCoins ?? this.amountCoins,
    type: type ?? this.type,
    description: description.present ? description.value : this.description,
    timestamp: timestamp ?? this.timestamp,
  );
  WalletTransaction copyWithCompanion(WalletTransactionsCompanion data) {
    return WalletTransaction(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amountCoins: data.amountCoins.present
          ? data.amountCoins.value
          : this.amountCoins,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletTransaction(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amountCoins: $amountCoins, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, amountCoins, type, description, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletTransaction &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amountCoins == this.amountCoins &&
          other.type == this.type &&
          other.description == this.description &&
          other.timestamp == this.timestamp);
}

class WalletTransactionsCompanion extends UpdateCompanion<WalletTransaction> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> amountCoins;
  final Value<String> type;
  final Value<String?> description;
  final Value<DateTime> timestamp;
  const WalletTransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amountCoins = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  WalletTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int amountCoins,
    required String type,
    this.description = const Value.absent(),
    this.timestamp = const Value.absent(),
  }) : userId = Value(userId),
       amountCoins = Value(amountCoins),
       type = Value(type);
  static Insertable<WalletTransaction> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? amountCoins,
    Expression<String>? type,
    Expression<String>? description,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amountCoins != null) 'amount_coins': amountCoins,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  WalletTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<int>? amountCoins,
    Value<String>? type,
    Value<String?>? description,
    Value<DateTime>? timestamp,
  }) {
    return WalletTransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amountCoins: amountCoins ?? this.amountCoins,
      type: type ?? this.type,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (amountCoins.present) {
      map['amount_coins'] = Variable<int>(amountCoins.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amountCoins: $amountCoins, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $FitnessGoalsTable fitnessGoals = $FitnessGoalsTable(this);
  late final $FitnessChallengesTable fitnessChallenges =
      $FitnessChallengesTable(this);
  late final $ZenBalancesTable zenBalances = $ZenBalancesTable(this);
  late final $WalletTransactionsTable walletTransactions =
      $WalletTransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    fitnessGoals,
    fitnessChallenges,
    zenBalances,
    walletTransactions,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String email,
      Value<String?> mobile,
      required String username,
      required String password,
      Value<int?> age,
      Value<double?> heightCm,
      Value<double?> weightKg,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String?> mobile,
      Value<String> username,
      Value<String> password,
      Value<int?> age,
      Value<double?> heightCm,
      Value<double?> weightKg,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                mobile: mobile,
                username: username,
                password: password,
                age: age,
                heightCm: heightCm,
                weightKg: weightKg,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                Value<String?> mobile = const Value.absent(),
                required String username,
                required String password,
                Value<int?> age = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                mobile: mobile,
                username: username,
                password: password,
                age: age,
                heightCm: heightCm,
                weightKg: weightKg,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$FitnessGoalsTableCreateCompanionBuilder =
    FitnessGoalsCompanion Function({
      Value<int> id,
      required int userId,
      Value<int> dailyCalories,
      Value<int> dailyMinutes,
      Value<int> dailySteps,
      Value<String?> notes,
    });
typedef $$FitnessGoalsTableUpdateCompanionBuilder =
    FitnessGoalsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> dailyCalories,
      Value<int> dailyMinutes,
      Value<int> dailySteps,
      Value<String?> notes,
    });

class $$FitnessGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $FitnessGoalsTable> {
  $$FitnessGoalsTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyCalories => $composableBuilder(
    column: $table.dailyCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailySteps => $composableBuilder(
    column: $table.dailySteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FitnessGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $FitnessGoalsTable> {
  $$FitnessGoalsTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyCalories => $composableBuilder(
    column: $table.dailyCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailySteps => $composableBuilder(
    column: $table.dailySteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FitnessGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FitnessGoalsTable> {
  $$FitnessGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get dailyCalories => $composableBuilder(
    column: $table.dailyCalories,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailySteps => $composableBuilder(
    column: $table.dailySteps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$FitnessGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FitnessGoalsTable,
          FitnessGoal,
          $$FitnessGoalsTableFilterComposer,
          $$FitnessGoalsTableOrderingComposer,
          $$FitnessGoalsTableAnnotationComposer,
          $$FitnessGoalsTableCreateCompanionBuilder,
          $$FitnessGoalsTableUpdateCompanionBuilder,
          (
            FitnessGoal,
            BaseReferences<_$AppDatabase, $FitnessGoalsTable, FitnessGoal>,
          ),
          FitnessGoal,
          PrefetchHooks Function()
        > {
  $$FitnessGoalsTableTableManager(_$AppDatabase db, $FitnessGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FitnessGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FitnessGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FitnessGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> dailyCalories = const Value.absent(),
                Value<int> dailyMinutes = const Value.absent(),
                Value<int> dailySteps = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => FitnessGoalsCompanion(
                id: id,
                userId: userId,
                dailyCalories: dailyCalories,
                dailyMinutes: dailyMinutes,
                dailySteps: dailySteps,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                Value<int> dailyCalories = const Value.absent(),
                Value<int> dailyMinutes = const Value.absent(),
                Value<int> dailySteps = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => FitnessGoalsCompanion.insert(
                id: id,
                userId: userId,
                dailyCalories: dailyCalories,
                dailyMinutes: dailyMinutes,
                dailySteps: dailySteps,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FitnessGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FitnessGoalsTable,
      FitnessGoal,
      $$FitnessGoalsTableFilterComposer,
      $$FitnessGoalsTableOrderingComposer,
      $$FitnessGoalsTableAnnotationComposer,
      $$FitnessGoalsTableCreateCompanionBuilder,
      $$FitnessGoalsTableUpdateCompanionBuilder,
      (
        FitnessGoal,
        BaseReferences<_$AppDatabase, $FitnessGoalsTable, FitnessGoal>,
      ),
      FitnessGoal,
      PrefetchHooks Function()
    >;
typedef $$FitnessChallengesTableCreateCompanionBuilder =
    FitnessChallengesCompanion Function({
      Value<int> id,
      required int userId,
      required String title,
      required String description,
      required String type,
      required DateTime startDate,
      required DateTime endDate,
      Value<int> entryCoins,
      Value<String?> targetJson,
    });
typedef $$FitnessChallengesTableUpdateCompanionBuilder =
    FitnessChallengesCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> title,
      Value<String> description,
      Value<String> type,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<int> entryCoins,
      Value<String?> targetJson,
    });

class $$FitnessChallengesTableFilterComposer
    extends Composer<_$AppDatabase, $FitnessChallengesTable> {
  $$FitnessChallengesTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryCoins => $composableBuilder(
    column: $table.entryCoins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetJson => $composableBuilder(
    column: $table.targetJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FitnessChallengesTableOrderingComposer
    extends Composer<_$AppDatabase, $FitnessChallengesTable> {
  $$FitnessChallengesTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryCoins => $composableBuilder(
    column: $table.entryCoins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetJson => $composableBuilder(
    column: $table.targetJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FitnessChallengesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FitnessChallengesTable> {
  $$FitnessChallengesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get entryCoins => $composableBuilder(
    column: $table.entryCoins,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetJson => $composableBuilder(
    column: $table.targetJson,
    builder: (column) => column,
  );
}

class $$FitnessChallengesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FitnessChallengesTable,
          FitnessChallenge,
          $$FitnessChallengesTableFilterComposer,
          $$FitnessChallengesTableOrderingComposer,
          $$FitnessChallengesTableAnnotationComposer,
          $$FitnessChallengesTableCreateCompanionBuilder,
          $$FitnessChallengesTableUpdateCompanionBuilder,
          (
            FitnessChallenge,
            BaseReferences<
              _$AppDatabase,
              $FitnessChallengesTable,
              FitnessChallenge
            >,
          ),
          FitnessChallenge,
          PrefetchHooks Function()
        > {
  $$FitnessChallengesTableTableManager(
    _$AppDatabase db,
    $FitnessChallengesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FitnessChallengesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FitnessChallengesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FitnessChallengesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<int> entryCoins = const Value.absent(),
                Value<String?> targetJson = const Value.absent(),
              }) => FitnessChallengesCompanion(
                id: id,
                userId: userId,
                title: title,
                description: description,
                type: type,
                startDate: startDate,
                endDate: endDate,
                entryCoins: entryCoins,
                targetJson: targetJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String title,
                required String description,
                required String type,
                required DateTime startDate,
                required DateTime endDate,
                Value<int> entryCoins = const Value.absent(),
                Value<String?> targetJson = const Value.absent(),
              }) => FitnessChallengesCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                description: description,
                type: type,
                startDate: startDate,
                endDate: endDate,
                entryCoins: entryCoins,
                targetJson: targetJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FitnessChallengesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FitnessChallengesTable,
      FitnessChallenge,
      $$FitnessChallengesTableFilterComposer,
      $$FitnessChallengesTableOrderingComposer,
      $$FitnessChallengesTableAnnotationComposer,
      $$FitnessChallengesTableCreateCompanionBuilder,
      $$FitnessChallengesTableUpdateCompanionBuilder,
      (
        FitnessChallenge,
        BaseReferences<
          _$AppDatabase,
          $FitnessChallengesTable,
          FitnessChallenge
        >,
      ),
      FitnessChallenge,
      PrefetchHooks Function()
    >;
typedef $$ZenBalancesTableCreateCompanionBuilder =
    ZenBalancesCompanion Function({Value<int> userId, Value<int> coins});
typedef $$ZenBalancesTableUpdateCompanionBuilder =
    ZenBalancesCompanion Function({Value<int> userId, Value<int> coins});

class $$ZenBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $ZenBalancesTable> {
  $$ZenBalancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ZenBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $ZenBalancesTable> {
  $$ZenBalancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZenBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZenBalancesTable> {
  $$ZenBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);
}

class $$ZenBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZenBalancesTable,
          ZenBalance,
          $$ZenBalancesTableFilterComposer,
          $$ZenBalancesTableOrderingComposer,
          $$ZenBalancesTableAnnotationComposer,
          $$ZenBalancesTableCreateCompanionBuilder,
          $$ZenBalancesTableUpdateCompanionBuilder,
          (
            ZenBalance,
            BaseReferences<_$AppDatabase, $ZenBalancesTable, ZenBalance>,
          ),
          ZenBalance,
          PrefetchHooks Function()
        > {
  $$ZenBalancesTableTableManager(_$AppDatabase db, $ZenBalancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZenBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZenBalancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZenBalancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<int> coins = const Value.absent(),
              }) => ZenBalancesCompanion(userId: userId, coins: coins),
          createCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<int> coins = const Value.absent(),
              }) => ZenBalancesCompanion.insert(userId: userId, coins: coins),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ZenBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZenBalancesTable,
      ZenBalance,
      $$ZenBalancesTableFilterComposer,
      $$ZenBalancesTableOrderingComposer,
      $$ZenBalancesTableAnnotationComposer,
      $$ZenBalancesTableCreateCompanionBuilder,
      $$ZenBalancesTableUpdateCompanionBuilder,
      (
        ZenBalance,
        BaseReferences<_$AppDatabase, $ZenBalancesTable, ZenBalance>,
      ),
      ZenBalance,
      PrefetchHooks Function()
    >;
typedef $$WalletTransactionsTableCreateCompanionBuilder =
    WalletTransactionsCompanion Function({
      Value<int> id,
      required int userId,
      required int amountCoins,
      required String type,
      Value<String?> description,
      Value<DateTime> timestamp,
    });
typedef $$WalletTransactionsTableUpdateCompanionBuilder =
    WalletTransactionsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<int> amountCoins,
      Value<String> type,
      Value<String?> description,
      Value<DateTime> timestamp,
    });

class $$WalletTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletTransactionsTable> {
  $$WalletTransactionsTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCoins => $composableBuilder(
    column: $table.amountCoins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletTransactionsTable> {
  $$WalletTransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCoins => $composableBuilder(
    column: $table.amountCoins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletTransactionsTable> {
  $$WalletTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get amountCoins => $composableBuilder(
    column: $table.amountCoins,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$WalletTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletTransactionsTable,
          WalletTransaction,
          $$WalletTransactionsTableFilterComposer,
          $$WalletTransactionsTableOrderingComposer,
          $$WalletTransactionsTableAnnotationComposer,
          $$WalletTransactionsTableCreateCompanionBuilder,
          $$WalletTransactionsTableUpdateCompanionBuilder,
          (
            WalletTransaction,
            BaseReferences<
              _$AppDatabase,
              $WalletTransactionsTable,
              WalletTransaction
            >,
          ),
          WalletTransaction,
          PrefetchHooks Function()
        > {
  $$WalletTransactionsTableTableManager(
    _$AppDatabase db,
    $WalletTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<int> amountCoins = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => WalletTransactionsCompanion(
                id: id,
                userId: userId,
                amountCoins: amountCoins,
                type: type,
                description: description,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required int amountCoins,
                required String type,
                Value<String?> description = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => WalletTransactionsCompanion.insert(
                id: id,
                userId: userId,
                amountCoins: amountCoins,
                type: type,
                description: description,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletTransactionsTable,
      WalletTransaction,
      $$WalletTransactionsTableFilterComposer,
      $$WalletTransactionsTableOrderingComposer,
      $$WalletTransactionsTableAnnotationComposer,
      $$WalletTransactionsTableCreateCompanionBuilder,
      $$WalletTransactionsTableUpdateCompanionBuilder,
      (
        WalletTransaction,
        BaseReferences<
          _$AppDatabase,
          $WalletTransactionsTable,
          WalletTransaction
        >,
      ),
      WalletTransaction,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$FitnessGoalsTableTableManager get fitnessGoals =>
      $$FitnessGoalsTableTableManager(_db, _db.fitnessGoals);
  $$FitnessChallengesTableTableManager get fitnessChallenges =>
      $$FitnessChallengesTableTableManager(_db, _db.fitnessChallenges);
  $$ZenBalancesTableTableManager get zenBalances =>
      $$ZenBalancesTableTableManager(_db, _db.zenBalances);
  $$WalletTransactionsTableTableManager get walletTransactions =>
      $$WalletTransactionsTableTableManager(_db, _db.walletTransactions);
}
