import 'package:flutter_test/flutter_test.dart';
import 'package:qazan/core/utils/phone_util.dart';

void main() {
  group('PhoneUtil.normalize', () {
    test('adds the dial code and drops the national leading zero', () {
      expect(PhoneUtil.normalize('050 123 45 67', '+994'), '+994501234567');
      expect(PhoneUtil.normalize('(532) 123-45-67', '+90'), '+905321234567');
    });

    test('keeps a number already in international form', () {
      expect(PhoneUtil.normalize('+90 532 123 45 67', '+994'), '+905321234567');
      expect(PhoneUtil.normalize('00994501234567', '+90'), '+994501234567');
    });

    test('leaves an empty field empty', () {
      expect(PhoneUtil.normalize('   ', '+994'), '');
    });
  });

  group('PhoneUtil.isValid', () {
    test('accepts plausible numbers only', () {
      expect(PhoneUtil.isValid('050 123 45 67'), isTrue);
      expect(PhoneUtil.isValid('123'), isFalse);
      expect(PhoneUtil.isValid('abc1234567'), isFalse);
    });
  });
}
