import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _userData;
  UserModel? get userData => _userData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _loadedUserId;
  StreamSubscription<UserModel>? _userSub;

  Future<void> loadUserData(String userId) async {
    // Avoid creating a new subscription on every rebuild for the same user.
    if (_loadedUserId == userId && _userSub != null) {
      debugPrint("👤 [UserProvider] Already loaded for $userId — skipping");
      return;
    }

    debugPrint("👤 [UserProvider] Loading user data for: $userId");

    await _userSub?.cancel();
    _userSub = null;
    _loadedUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _userSub = _databaseService.getUserStream(userId).listen(
      (user) {
        debugPrint(
          "✅ [UserProvider] Stream data: uid=${user.uid}, "
          "email=${user.email}, balance=${user.balance}, "
          "referralBalance=${user.referralBalance}, "
          "totalEarned=${user.totalEarned}",
        );
        _userData = user;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error, stack) {
        // 🔴 YEH SABSE ZAROORI HAI — silent fail ki wajah yahi thi
        debugPrint("❌ [UserProvider] STREAM ERROR: $error");
        debugPrint("❌ [UserProvider] STACK: $stack");
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Clears data + cancels the stream (used on logout).
  Future<void> clear() async {
    debugPrint("👤 [UserProvider] Clearing user data");
    await _userSub?.cancel();
    _userSub = null;
    _loadedUserId = null;
    _userData = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> updateBalance(String userId, double newBalance) async {
    await _databaseService.updateUserData(userId, {'balance': newBalance});
  }

  Future<void> updateReferralBalance(String userId, double newBalance) async {
    await _databaseService.updateUserData(userId, {'referralBalance': newBalance});
  }

  Future<void> incrementTotalEarned(String userId, double amount) async {
    await _databaseService.incrementUserData(
      userId,
      totalEarnedDelta: amount,
      balanceDelta: amount,
    );
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}