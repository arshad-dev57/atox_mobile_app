class RechargeModel {
  final String id;
  final String userId;
  final int amount;
  final String screenshotUrl;
  final Map<String, String> bankDetails;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  RechargeModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.screenshotUrl,
    required this.bankDetails,
    required this.status,
    required this.createdAt,
  });

  factory RechargeModel.fromMap(Map<String, dynamic> map) {
    return RechargeModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: map['amount'] as int,
      screenshotUrl: map['screenshotUrl'] as String,
      bankDetails: Map<String, String>.from(map['bankDetails'] as Map),
      status: map['status'] as String? ?? 'pending',
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
      'screenshotUrl': screenshotUrl,
      'bankDetails': bankDetails,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
