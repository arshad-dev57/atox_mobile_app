import 'package:flutter/material.dart';

class AppConstants {
  // Bank details
  static const String bankName = 'Opay';
  static const String accountNumber = '9098373121';
  static const String accountName = 'wisdom chima innocent';

  // Withdrawal settings
  static const int minimumWithdrawal = 5000;
  static const double withdrawalFee = 0.10; // 10%
  static const int withdrawalDayOfWeek = 5; // Friday (0 = Sunday, 6 = Saturday)
  static const int withdrawalStartHour = 8; // 8 AM
  static const int withdrawalEndHour = 20; // 8 PM

  // Recharge settings
  static const int minimumRecharge = 100;

  // Free mode
  static const String freeModeId = 'free-mode';
  static const int freeModeEarningPerAd = 10;

  // WhatsApp support
  static const String whatsappNumber = '+2349072485676';
  static const String whatsappChannel = 'https://whatsapp.com/channel/0029VbCNd1kK0IBnzHsutm1a';

  // Commission rates
  static const double level1Commission = 0.10; // 10%
  static const double level2Commission = 0.03; // 3%
}

class AppColors {
  static const primary = Color(0xFF10B981); // Emerald 500
  static const primaryDark = Color(0xFF059669); // Emerald 600
  static const primaryLight = Color(0xFF34D399); // Emerald 400
  static const secondary = Color(0xFF3B82F6); // Blue 500
  static const accent = Color(0xFFF59E0B); // Amber 500
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE5E7EB);
}

