import 'package:flutter/material.dart';

class AppConstants {
  // Bank details
  static const String bankName = 'Opay';
  static const String accountNumber = '9098373121';
  static const String accountName = 'wisdom chima innocent';

  // Withdrawal settings
  static const int minimumWithdrawal = 2000;
  static const double withdrawalFee = 0.10; // 10%
  // Withdrawals are available DAILY (any day). A user may submit only ONE
  // withdrawal request per day.

  // Recharge settings
  static const int minimumRecharge = 100;

  // Watch and Earn (formerly "Free Mode") — for users with no active VIP plan.
  // productId/doc id kept as "freemode" to match the web platform's Firestore data.
  static const String watchAndEarnId = 'freemode';
  static const int watchAndEarnPerAd = 10; // ₦10 per completed ad

  // Watch and Earn ad settings (mirrors the web's static-video + forced timer mode)
  static const String watchAndEarnVideoAsset = 'assets/ads/ad-content.mp4';
  static const int adWatchSeconds = 15; // forced watch duration before claiming
  static const String adsterraSmartlinkUrl = 'https://otieu.com/4/30356717';

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

