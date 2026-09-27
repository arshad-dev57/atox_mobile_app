import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const String locale = 'en_NG';
  static const String currency = 'NGN';

  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '₦',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatWithDecimals(double amount) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '₦',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
