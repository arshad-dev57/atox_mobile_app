import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Helper function to convert Timestamp, DateTime, or String to DateTime
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return WithdrawalModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: map['amount'] as int,
      fee: map['fee'] as int,
      finalAmount: map['finalAmount'] as int,
      bankDetails: Map<String, String>.from(map['bankDetails'] as Map),
      status: map['status'] as String? ?? 'pending',
      balanceType: map['balanceType'] as String? ?? 'referral',
      createdAt: parseDateTime(map['createdAt']),
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
