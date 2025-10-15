import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;

import '../services/db/app_database.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._db);

  final AppDatabase _db;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User> signup({
    required String email,
    String? mobile,
    required String username,
    required String password,
  }) async {
    final userId = await _db.createUser(UsersCompanion(
      email: drift.Value(email),
      mobile: mobile != null ? drift.Value(mobile) : const drift.Value.absent(),
      username: drift.Value(username),
      password: drift.Value(password), // TODO: hash later
    ));
    final created = await _db.findUserById(userId);
    _currentUser = created;
    notifyListeners();
    return created!;
  }

  Future<bool> saveAdditionalInfo({
    required int userId,
    int? age,
    double? heightCm,
    double? weightKg,
  }) async {
    final ok = await _db.updateAdditionalInfo(
      userId: userId,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
    );
    if (ok) {
      _currentUser = await _db.findUserById(userId);
      notifyListeners();
    }
    return ok;
  }

  Future<User?> login({required String identifier, required String password}) async {
    final found = await _db.findUserByEmailOrUsername(identifier);
    if (found != null && found.password == password) {
      _currentUser = found;
      notifyListeners();
      return found;
    }
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}


