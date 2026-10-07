class PurchaseModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final int amount;
  final DateTime purchasedAt;
  final DateTime? expiresAt;
  final String status;
  final int? ads;
  final int? dailyIncome;

  PurchaseModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.purchasedAt,
    this.expiresAt,
    this.status = 'active',
    this.ads,
    this.dailyIncome,
  });

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      amount: map['amount'] as int,
      purchasedAt: map['purchasedAt'] is DateTime
          ? map['purchasedAt'] as DateTime
          : DateTime.parse(map['purchasedAt'] as String),
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] is DateTime
                ? map['expiresAt'] as DateTime
                : DateTime.parse(map['expiresAt'] as String))
          : null,
      status: map['status'] as String? ?? 'active',
      ads: map['ads'] as int?,
      dailyIncome: map['dailyIncome'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'amount': amount,
      'purchasedAt': purchasedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
      'ads': ads,
      'dailyIncome': dailyIncome,
    };
  }

  bool isActive() {
    if (status != 'active') return false;
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }
}
