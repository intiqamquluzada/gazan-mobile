/// Canonical phone handling: the server stores `+` followed by digits.
class PhoneUtil {
  const PhoneUtil._();

  /// Combines what the user typed with the selected dial code.
  /// "050 123 45 67" + "+994" → "+994501234567".
  /// A number already written in international form keeps its own code.
  static String normalize(String input, String dialCode) {
    final String raw = input.trim();
    if (raw.isEmpty) return '';
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.startsWith('+')) return '+$digits';
    if (digits.startsWith('00')) return '+${digits.substring(2)}';
    final String local = digits.replaceFirst(RegExp(r'^0+'), '');
    final String dial = dialCode.replaceAll(RegExp(r'[^0-9]'), '');
    return '+$dial$local';
  }

  /// True for a plausible national or international number.
  static bool isValid(String input) {
    final String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return RegExp(r'^[+0-9 ()-]+$').hasMatch(input.trim()) &&
        digits.length >= 7 &&
        digits.length <= 15;
  }
}
