import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/purchase_model.dart';
import '../models/notification_model.dart';
import '../models/withdrawal_model.dart';
import '../models/recharge_model.dart';
import '../models/payment_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Stream<UserModel> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>));
  }

  // Purchase operations
  Future<List<PurchaseModel>> getUserPurchases(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('purchases')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => PurchaseModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  Stream<List<PurchaseModel>> getUserPurchasesStream(String userId) {
    return _firestore
        .collection('purchases')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PurchaseModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }

  // Notification operations
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }

  // Withdrawal operations
  Future<void> createWithdrawal(WithdrawalModel withdrawal) async {
    await _firestore.collection('withdrawals').add(withdrawal.toMap());
  }

  Future<List<WithdrawalModel>> getUserWithdrawals(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('withdrawals')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WithdrawalModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  // Recharge operations
  Future<void> createRecharge(RechargeModel recharge) async {
    await _firestore.collection('recharges').add(recharge.toMap());
  }

  // Payment operations
  Future<void> createPayment(PaymentModel payment) async {
    await _firestore.collection('payments').add(payment.toMap());
  }

  Future<List<PaymentModel>> getUserPayments(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PaymentModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  // Referral operations
  Future<List<UserModel>> getUserReferrals(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('referredBy', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap({...doc.data() as Map<String, dynamic>, 'uid': doc.id}))
        .toList();
  }

  // Ad progress operations
  Future<Map<String, dynamic>> getAdProgress(String userId, String productId, String date) async {
    DocumentSnapshot doc = await _firestore
        .collection('adProgress')
        .doc('${userId}_${productId}_${date}')
        .get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return {'adsWatched': 0, 'earned': 0};
  }

  Future<void> updateAdProgress(
    String userId,
    String productId,
    String date,
    int adsWatched,
    double earned,
  ) async {
    await _firestore.collection('adProgress').doc('${userId}_${productId}_${date}').set({
      'userId': userId,
      'productId': productId,
      'date': date,
      'adsWatched': adsWatched,
      'earned': earned,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}
