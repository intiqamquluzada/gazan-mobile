/// Currency helpers for the two markets the app serves.
///
/// Prices belong to a venue, not to the app: an Azerbaijani café prices in
/// manat, a Turkish one in lira. Everything that renders a price takes the
/// venue's ISO code and formats with [Money.format].
class Money {
  const Money._();

  static const String azn = 'AZN';
  static const String tryy = 'TRY';

  /// Symbol for an ISO code; falls back to the code itself.
  static String symbol(String? currency) {
    switch ((currency ?? azn).toUpperCase()) {
      case 'TRY':
        return '₺';
      case 'AZN':
        return '₼';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency ?? '₼';
    }
  }

  /// "5 ₼" for whole amounts, "5.50 ₺" otherwise.
  static String format(num value, String? currency) {
    final String v = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$v ${symbol(currency)}';
  }

  /// Default currency for a country (used when a venue is created).
  static String forCountry(String? country) =>
      (country ?? 'AZ').toUpperCase() == 'TR' ? tryy : azn;
}
