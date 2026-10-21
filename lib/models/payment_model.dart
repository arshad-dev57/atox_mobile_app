import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Helper function to convert Timestamp, DateTime, or String to DateTime
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return PaymentModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      amount: map['amount'] as int,
      screenshotUrl: map['screenshotUrl'] as String,
      bankDetails: Map<String, String>.from(map['bankDetails'] as Map),
      status: map['status'] as String? ?? 'pending',
      submittedAt: parseDateTime(map['submittedAt']),
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
