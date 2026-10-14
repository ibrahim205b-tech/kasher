import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd', 'ar').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a', 'ar').format(dateTime);
  }
}
