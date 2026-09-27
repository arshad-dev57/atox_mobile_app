class WithdrawalModel {
  final String id;
  final String userId;
  final int amount;
  final int fee;
  final int finalAmount;
  final Map<String, String> bankDetails;
  final String status; // pending, approved, rejected
  final String balanceType; // task, referral
  final DateTime createdAt;

  WithdrawalModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.fee,
    required this.finalAmount,
    required this.bankDetails,
    required this.status,
    required this.balanceType,
    required this.createdAt,
  });

  factory WithdrawalModel.fromMap(Map<String, dynamic> map) {
    return WithdrawalModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: map['amount'] as int,
      fee: map['fee'] as int,
      finalAmount: map['finalAmount'] as int,
      bankDetails: Map<String, String>.from(map['bankDetails'] as Map),
      status: map['status'] as String? ?? 'pending',
      balanceType: map['balanceType'] as String? ?? 'referral',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'fee': fee,
      'finalAmount': finalAmount,
      'bankDetails': bankDetails,
      'status': status,
      'balanceType': balanceType,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
