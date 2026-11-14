import 'package:intl/intl.dart';

/// Lightweight wrappers around `intl` so feature code doesn't import it
/// directly. [locale] follows the language the user picked (az / tr / ru / en)
/// — the app serves Azerbaijan and Türkiye, so dates must not be stuck in one.
class AppFormat {
  const AppFormat._();

  static String locale = 'az';

  static String date(DateTime value) =>
      DateFormat('d MMM yyyy', locale).format(value);
  static String dateTime(DateTime value) =>
      DateFormat('d MMM, HH:mm', locale).format(value);
  static String time(DateTime value) => DateFormat('HH:mm').format(value);

  /// Prefer `Money.format(value, venueCurrency)` for venue prices.
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
