import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String currency = 'د.ع'}) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(amount)} $currency';
  }

  static String formatCompact(double amount, {String currency = 'د.ع'}) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}م $currency';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}ك $currency';
    }
    return format(amount, currency: currency);
  }
}
