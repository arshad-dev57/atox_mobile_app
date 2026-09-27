class PaymentModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final int amount;
  final String screenshotUrl;
  final Map<String, String> bankDetails;
  final String status; // pending, approved, rejected
  final DateTime submittedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.screenshotUrl,
    required this.bankDetails,
    required this.status,
    required this.submittedAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      amount: map['amount'] as int,
      screenshotUrl: map['screenshotUrl'] as String,
      bankDetails: Map<String, String>.from(map['bankDetails'] as Map),
      status: map['status'] as String? ?? 'pending',
      submittedAt: map['submittedAt'] is DateTime
          ? map['submittedAt'] as DateTime
          : DateTime.parse(map['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'amount': amount,
      'screenshotUrl': screenshotUrl,
      'bankDetails': bankDetails,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
