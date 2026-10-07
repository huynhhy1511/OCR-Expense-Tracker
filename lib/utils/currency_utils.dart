import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatVND(int amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(amount);
  }
}
