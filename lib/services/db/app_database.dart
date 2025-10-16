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

class FitnessChallenges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get type => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  IntColumn get entryCoins => integer().withDefault(const Constant(0))();
  TextColumn get targetJson => text().nullable()();
}

class ZenBalances extends Table {
  IntColumn get userId => integer()();
  IntColumn get coins => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {userId};
}

class WalletTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  IntColumn get amountCoins => integer()(); // positive credit, negative debit
  TextColumn get type => text()(); // 'challenge_entry', 'challenge_reward', etc.
  TextColumn get description => text().nullable()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Users, FitnessGoals, FitnessChallenges, ZenBalances, WalletTransactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(fitnessGoals);
      }
      if (from < 3) {
        await m.createTable(fitnessChallenges);
        await m.createTable(zenBalances);
        await m.createTable(walletTransactions);
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

  // Wallet helpers
  Future<ZenBalance> _ensureBalanceRow(int userId) async {
    final existing = await (select(zenBalances)..where((b) => b.userId.equals(userId))).getSingleOrNull();
    if (existing != null) return existing;
    // Seed new users with 5000 Zen coins and record a seed transaction
    await into(zenBalances).insert(ZenBalancesCompanion(userId: Value(userId), coins: const Value(5000)));
    await into(walletTransactions).insert(WalletTransactionsCompanion.insert(
      userId: userId,
      amountCoins: 5000,
      type: 'seed',
      description: const Value('Initial Zen coins'),
    ));
    return ZenBalance(userId: userId, coins: 5000);
  }

  Future<int> getZenCoins(int userId) async {
    final b = await _ensureBalanceRow(userId);
    return b.coins;
    }

  Future<void> updateZenCoins(int userId, int delta, {required String type, String? description}) async {
    await transaction(() async {
      final current = await _ensureBalanceRow(userId);
      final newCoins = current.coins + delta;
      await (update(zenBalances)..where((b) => b.userId.equals(userId))).write(ZenBalancesCompanion(coins: Value(newCoins)));
      await into(walletTransactions).insert(WalletTransactionsCompanion.insert(
        userId: userId,
        amountCoins: delta,
        type: type,
        description: Value(description ?? ''),
      ));
    });
  }

  Future<int> createChallengeWithEntry({
    required int userId,
    required String title,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required int entryCoins,
    String? targetJson,
  }) async {
    return await transaction<int>(() async {
      final bal = await _ensureBalanceRow(userId);
      if (bal.coins < entryCoins) {
        throw Exception('Not enough Zen coins');
      }
      final challengeId = await into(fitnessChallenges).insert(FitnessChallengesCompanion.insert(
        userId: userId,
        title: title,
        description: description,
        type: type,
        startDate: startDate,
        endDate: endDate,
        entryCoins: Value(entryCoins),
        targetJson: Value(targetJson ?? ''),
      ));
      await updateZenCoins(userId, -entryCoins, type: 'challenge_entry', description: 'Entry for '+title);
      return challengeId;
    });
  }

  // Queries for challenges
  Future<List<FitnessChallenge>> getChallengesForUser(int userId) {
    return (select(fitnessChallenges)
          ..where((c) => c.userId.equals(userId))
          ..orderBy([(c) => OrderingTerm.desc(c.startDate)]))
        .get();
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


