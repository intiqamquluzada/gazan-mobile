// Email code step of password sign-up. Same contract as strings.dart: a
// missing translation falls back to the Azerbaijani text in the getter.
import 'strings.dart';

extension EmailOtpStrings on S {
  String _o(String key, String az) => _emailOtp[lang]?[key] ?? az;

  String get emailCodeTitle => _o('emailCodeTitle', 'E-poçtunu təsdiqlə');
  String get emailCodeSub =>
      _o('emailCodeSub', '6 rəqəmli kodu bu ünvana göndərdik:');
  String get emailCodeVerify => _o('emailCodeVerify', 'Təsdiqlə');
  String get emailCodeResend => _o('emailCodeResend', 'Kodu yenidən göndər');
  String emailCodeResendIn(int seconds) =>
      _o('emailCodeResendIn', 'Yenidən göndər: {s} san')
          .replaceAll('{s}', '$seconds');
  String get emailCodeResent => _o('emailCodeResent', 'Yeni kod göndərildi');
  String get emailCodeChange => _o('emailCodeChange', 'E-poçtu dəyiş');
  String get emailCodeSpam =>
      _o('emailCodeSpam', 'Məktub gəlmədi? Spam qovluğunu yoxla.');
  String get emailCodeIncomplete =>
      _o('emailCodeIncomplete', '6 rəqəmli kodu daxil et');
  String get emailCodeVerified => _o('emailCodeVerified', 'E-poçt təsdiqləndi');
}

const Map<String, Map<String, String>> _emailOtp =
    <String, Map<String, String>>{
  'en': <String, String>{
    'emailCodeTitle': 'Verify your email',
    'emailCodeSub': 'We sent a 6-digit code to',
    'emailCodeVerify': 'Verify',
    'emailCodeResend': 'Resend code',
    'emailCodeResendIn': 'Resend in {s}s',
    'emailCodeResent': 'A new code is on its way',
    'emailCodeChange': 'Change email',
    'emailCodeSpam': 'No email? Check your spam folder.',
    'emailCodeIncomplete': 'Enter the 6-digit code',
    'emailCodeVerified': 'Email verified',
  },
  'ru': <String, String>{
    'emailCodeTitle': 'Подтвердите почту',
    'emailCodeSub': 'Мы отправили 6-значный код на',
    'emailCodeVerify': 'Подтвердить',
    'emailCodeResend': 'Отправить код снова',
    'emailCodeResendIn': 'Повторно через {s} с',
    'emailCodeResent': 'Новый код отправлен',
    'emailCodeChange': 'Изменить почту',
    'emailCodeSpam': 'Нет письма? Проверьте папку «Спам».',
    'emailCodeIncomplete': 'Введите 6-значный код',
    'emailCodeVerified': 'Почта подтверждена',
  },
  'tr': <String, String>{
    'emailCodeTitle': 'E-postanı doğrula',
    'emailCodeSub': '6 haneli kodu şu adrese gönderdik:',
    'emailCodeVerify': 'Doğrula',
    'emailCodeResend': 'Kodu tekrar gönder',
    'emailCodeResendIn': '{s} sn sonra tekrar gönder',
    'emailCodeResent': 'Yeni kod gönderildi',
    'emailCodeChange': 'E-postayı değiştir',
    'emailCodeSpam': 'E-posta gelmedi mi? Spam klasörünü kontrol et.',
    'emailCodeIncomplete': '6 haneli kodu gir',
    'emailCodeVerified': 'E-posta doğrulandı',
  },
};
