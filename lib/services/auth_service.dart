import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? invitationCode,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String? referredBy;
    if (invitationCode != null && invitationCode.isNotEmpty) {
      // Lookup referral code to get referrer ID
      var querySnapshot = await _firestore
          .collection('users')
          .where('myInvitationCode', isEqualTo: invitationCode.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        referredBy = querySnapshot.docs.first.id;
        if (referredBy == credential.user!.uid) {
          referredBy = null; // Can't refer yourself
        }
      }
    }

    String myInvitationCode = 'ATOX-${credential.user!.uid.substring(0, 6).toUpperCase()}';

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'fullName': fullName,
      'phone': '+234$phone',
      'phoneRaw': phone,
      'email': email,
      'invitationCode': invitationCode?.toUpperCase(),
      'myInvitationCode': myInvitationCode,
      'referredBy': referredBy,
      'referralBonusPaid': false,
      'balance': 0,
      'referralBalance': 0,
      'totalEarned': 0,
      'totalWithdrawn': 0,
      'referralCount': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
      'accountStatus': 'active',
      'isAdmin': false,
    });

    return credential;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> isAdmin() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.get('isAdmin') ?? false;
    }
    return false;
  }
}
