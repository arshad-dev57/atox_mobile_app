class UserModel {
  final String? uid;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? myInvitationCode;
  final String? referredBy;
  final double balance;
  final double referralBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final int referralCount;
  final bool referralBonusPaid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String accountStatus;
  final bool isAdmin;

  UserModel({
    this.uid,
    this.email,
    this.fullName,
    this.phone,
    this.myInvitationCode,
    this.referredBy,
    this.balance = 0,
    this.referralBalance = 0,
    this.totalEarned = 0,
    this.totalWithdrawn = 0,
    this.referralCount = 0,
    this.referralBonusPaid = false,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.accountStatus = 'active',
    this.isAdmin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String?,
      email: map['email'] as String?,
      fullName: map['fullName'] as String?,
      phone: map['phone'] as String?,
      myInvitationCode: map['myInvitationCode'] as String?,
      referredBy: map['referredBy'] as String?,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      referralBalance: (map['referralBalance'] as num?)?.toDouble() ?? 0,
      totalEarned: (map['totalEarned'] as num?)?.toDouble() ?? 0,
      totalWithdrawn: (map['totalWithdrawn'] as num?)?.toDouble() ?? 0,
      referralCount: map['referralCount'] as int? ?? 0,
      referralBonusPaid: map['referralBonusPaid'] as bool? ?? false,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] as DateTime 
              : DateTime.parse(map['createdAt'] as String))
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is DateTime 
              ? map['updatedAt'] as DateTime 
              : DateTime.parse(map['updatedAt'] as String))
          : null,
      isActive: map['isActive'] as bool? ?? true,
      accountStatus: map['accountStatus'] as String? ?? 'active',
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'myInvitationCode': myInvitationCode,
      'referredBy': referredBy,
      'balance': balance,
      'referralBalance': referralBalance,
      'totalEarned': totalEarned,
      'totalWithdrawn': totalWithdrawn,
      'referralCount': referralCount,
      'referralBonusPaid': referralBonusPaid,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'accountStatus': accountStatus,
      'isAdmin': isAdmin,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    String? myInvitationCode,
    String? referredBy,
    double? balance,
    double? referralBalance,
    double? totalEarned,
    double? totalWithdrawn,
    int? referralCount,
    bool? referralBonusPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? accountStatus,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      myInvitationCode: myInvitationCode ?? this.myInvitationCode,
      referredBy: referredBy ?? this.referredBy,
      balance: balance ?? this.balance,
      referralBalance: referralBalance ?? this.referralBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      referralCount: referralCount ?? this.referralCount,
      referralBonusPaid: referralBonusPaid ?? this.referralBonusPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      accountStatus: accountStatus ?? this.accountStatus,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
