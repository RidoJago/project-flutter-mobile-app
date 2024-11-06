import 'package:intl/intl.dart';

class Utils {
  static String toDateTime(DateTime dateTime) {
    final date = DateFormat.yMMMd().format(dateTime);
    final time = DateFormat.jm().format(dateTime);

    return '$date at $time';
  }

  static String toDate(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime);
  }

  static String toTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }
}
