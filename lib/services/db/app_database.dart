import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().withLength(min: 3, max: 255)();
  TextColumn get mobile => text().nullable()();
  TextColumn get username => text().withLength(min: 3, max: 100)();
  TextColumn get password => text()(); // NOTE: Plain for now; hash later
  IntColumn get age => integer().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {email},
    {username},
  ];
}

class FitnessGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  IntColumn get dailyCalories => integer().withDefault(const Constant(0))();
  IntColumn get dailyMinutes => integer().withDefault(const Constant(0))();
  IntColumn get dailySteps => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE(user_id)'];
}

@DriftDatabase(tables: [Users, FitnessGoals])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(fitnessGoals);
      }
    },
  );

  // Users DAO-like helpers
  Future<int> createUser(UsersCompanion user) => into(users).insert(user);

  Future<User?> findUserByEmailOrUsername(String identifier) async {
    return (select(users)
          ..where((u) => u.email.equals(identifier) | u.username.equals(identifier))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<User?> findUserById(int id) => (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<bool> updateAdditionalInfo({required int userId, int? age, double? heightCm, double? weightKg}) async {
    final companion = UsersCompanion(
      age: age != null ? Value(age) : const Value.absent(),
      heightCm: heightCm != null ? Value(heightCm) : const Value.absent(),
      weightKg: weightKg != null ? Value(weightKg) : const Value.absent(),
    );
    final updated = await (update(users)..where((u) => u.id.equals(userId))).write(companion);
    return updated > 0;
  }

  Future<List<User>> getAllUsers() => select(users).get();

  // Goals helpers
  Future<FitnessGoal?> getGoalsForUser(int userId) {
    return (select(fitnessGoals)..where((g) => g.userId.equals(userId))).getSingleOrNull();
  }

  Future<int> upsertGoals({
    required int userId,
    required int dailyCalories,
    required int dailyMinutes,
    required int dailySteps,
    String? notes,
  }) async {
    final existing = await getGoalsForUser(userId);
    if (existing == null) {
      return into(fitnessGoals).insert(FitnessGoalsCompanion.insert(
        userId: userId,
        dailyCalories: Value(dailyCalories),
        dailyMinutes: Value(dailyMinutes),
        dailySteps: Value(dailySteps),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ));
    } else {
      return (update(fitnessGoals)..where((g) => g.userId.equals(userId))).write(FitnessGoalsCompanion(
        dailyCalories: Value(dailyCalories),
        dailyMinutes: Value(dailyMinutes),
        dailySteps: Value(dailySteps),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'fitness_app.sqlite'));
    // Print once so users can locate the DB in dev
    // ignore: avoid_print
    print('SQLite DB path: ${dbFile.path}');
    return NativeDatabase.createInBackground(dbFile);
  });
}


