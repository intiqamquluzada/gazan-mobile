import 'package:intl/intl.dart';

/// Lightweight wrappers around `intl` so feature code doesn't import it directly.
class AppFormat {
  const AppFormat._();

  static String date(DateTime value) => DateFormat('d MMM yyyy', 'az').format(value);
  static String dateTime(DateTime value) =>
      DateFormat('d MMM, HH:mm', 'az').format(value);
  static String time(DateTime value) => DateFormat('HH:mm').format(value);

  static String currency(num value, {String symbol = '₼'}) {
    final NumberFormat f = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: value.truncateToDouble() == value ? 0 : 2,
    );
    return f.format(value);
  }

  static String compact(num value) =>
      NumberFormat.compact(locale: 'en').format(value);
}
