import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _userData;
  UserModel? get userData => _userData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUserData(String userId) async {
    _isLoading = true;
    notifyListeners();

    _databaseService.getUserStream(userId).listen((user) {
      _userData = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateBalance(String userId, double newBalance) async {
    await _databaseService.updateUserData(userId, {'balance': newBalance});
  }

  Future<void> updateReferralBalance(String userId, double newBalance) async {
    await _databaseService.updateUserData(userId, {'referralBalance': newBalance});
  }

  Future<void> incrementTotalEarned(String userId, double amount) async {
    if (_userData != null) {
      await _databaseService.updateUserData(
        userId,
        {
          'totalEarned': _userData!.totalEarned + amount,
          'balance': _userData!.balance + amount,
        },
      );
    }
  }
}
