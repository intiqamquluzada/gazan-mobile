// Placeholder (hint) texts for form fields. Every input in the app shows
// one, so an empty field always tells the user what to type.
// Same contract as strings.dart: a missing translation falls back to the
// Azerbaijani text in the getter.
import 'strings.dart';

extension HintStrings on S {
  String _h(String key, String az) => _hints[lang]?[key] ?? az;

  String get hintFirstName => _h('hintFirstName', 'məs. Əli');
  String get hintLastName => _h('hintLastName', 'məs. Məmmədov');
  String get hintVerifyCode => _h('hintVerifyCode', '6 rəqəmli kod');
  String get hintCurrentPassword =>
      _h('hintCurrentPassword', 'Hazırkı şifrəni yaz');
  String get hintRepeatPassword =>
      _h('hintRepeatPassword', 'Yeni şifrəni təkrar yaz');
  String get hintAmount => _h('hintAmount', 'məs. 100');
  String get hintNumber => _h('hintNumber', 'məs. 10');
  String get hintNote => _h('hintNote', 'Qısa qeyd');
  String get hintReason => _h('hintReason', 'Səbəbi qısaca yaz');
  String get hintMenuItemName => _h('hintMenuItemName', 'məs. Latte');
  String get hintMenuItemDesc =>
      _h('hintMenuItemDesc', 'məs. Süd və espresso, 300 ml');
  String get hintPrice => _h('hintPrice', 'məs. 4.50');
  String get hintNotifTitle =>
      _h('hintNotifTitle', 'məs. Bu gün 20% endirim!');
  String get hintNotifBody =>
      _h('hintNotifBody', 'Müştərilərin görəcəyi mətn');
  String get hintPromoTitle =>
      _h('hintPromoTitle', 'məs. 5 qəhvəyə 6-cı pulsuz');
  String get hintPromoSubtitle =>
      _h('hintPromoSubtitle', 'məs. The Bagel Bar — hər gün');
  String get hintEmoji => _h('hintEmoji', 'məs. 🎉');
  String get hintButtonText => _h('hintButtonText', 'məs. Kart al');
  String get hintTagline =>
      _h('hintTagline', 'məs. Təzə qəhvə və ev şirniyyatı');
  String get hintAddress => _h('hintAddress', 'məs. Nizami küç. 87, Bakı');
  String get hintPhone => _h('hintPhone', '+994 50 123 45 67');
  String get hintLatitude => _h('hintLatitude', 'məs. 40.4093');
  String get hintLongitude => _h('hintLongitude', 'məs. 49.8671');
  String get hintNfcLabel => _h('hintNfcLabel', 'məs. Kassa 1');
}

const Map<String, Map<String, String>> _hints = <String, Map<String, String>>{
  'en': <String, String>{
    'hintFirstName': 'e.g. Ali',
    'hintLastName': 'e.g. Mammadov',
    'hintVerifyCode': '6-digit code',
    'hintCurrentPassword': 'Enter your current password',
    'hintRepeatPassword': 'Re-enter the new password',
    'hintAmount': 'e.g. 100',
    'hintNumber': 'e.g. 10',
    'hintNote': 'Short note',
    'hintReason': 'Briefly describe the reason',
    'hintMenuItemName': 'e.g. Latte',
    'hintMenuItemDesc': 'e.g. Milk and espresso, 300 ml',
    'hintPrice': 'e.g. 4.50',
    'hintNotifTitle': 'e.g. 20% off today!',
    'hintNotifBody': 'The text your customers will see',
    'hintPromoTitle': 'e.g. Buy 5 coffees, get the 6th free',
    'hintPromoSubtitle': 'e.g. The Bagel Bar — every day',
    'hintEmoji': 'e.g. 🎉',
    'hintButtonText': 'e.g. Get card',
    'hintTagline': 'e.g. Fresh coffee and homemade sweets',
    'hintAddress': 'e.g. 87 Nizami St, Baku',
    'hintPhone': '+994 50 123 45 67',
    'hintLatitude': 'e.g. 40.4093',
    'hintLongitude': 'e.g. 49.8671',
    'hintNfcLabel': 'e.g. Till 1',
  },
  'ru': <String, String>{
    'hintFirstName': 'напр. Али',
    'hintLastName': 'напр. Мамедов',
    'hintVerifyCode': '6-значный код',
    'hintCurrentPassword': 'Введите текущий пароль',
    'hintRepeatPassword': 'Повторите новый пароль',
    'hintAmount': 'напр. 100',
    'hintNumber': 'напр. 10',
    'hintNote': 'Короткая заметка',
    'hintReason': 'Кратко опишите причину',
    'hintMenuItemName': 'напр. Латте',
    'hintMenuItemDesc': 'напр. Молоко и эспрессо, 300 мл',
    'hintPrice': 'напр. 4.50',
    'hintNotifTitle': 'напр. Сегодня скидка 20%!',
    'hintNotifBody': 'Текст, который увидят клиенты',
    'hintPromoTitle': 'напр. 6-й кофе бесплатно',
    'hintPromoSubtitle': 'напр. The Bagel Bar — каждый день',
    'hintEmoji': 'напр. 🎉',
    'hintButtonText': 'напр. Получить карту',
    'hintTagline': 'напр. Свежий кофе и домашние сладости',
    'hintAddress': 'напр. ул. Низами 87, Баку',
    'hintPhone': '+994 50 123 45 67',
    'hintLatitude': 'напр. 40.4093',
    'hintLongitude': 'напр. 49.8671',
    'hintNfcLabel': 'напр. Касса 1',
  },
  'tr': <String, String>{
    'hintFirstName': 'örn. Ali',
    'hintLastName': 'örn. Memmedov',
    'hintVerifyCode': '6 haneli kod',
    'hintCurrentPassword': 'Mevcut şifreni gir',
    'hintRepeatPassword': 'Yeni şifreyi tekrar gir',
    'hintAmount': 'örn. 100',
    'hintNumber': 'örn. 10',
    'hintNote': 'Kısa not',
    'hintReason': 'Nedenini kısaca yaz',
    'hintMenuItemName': 'örn. Latte',
    'hintMenuItemDesc': 'örn. Süt ve espresso, 300 ml',
    'hintPrice': 'örn. 4.50',
    'hintNotifTitle': 'örn. Bugün %20 indirim!',
    'hintNotifBody': 'Müşterilerinin göreceği metin',
    'hintPromoTitle': 'örn. 5 kahveye 6. bedava',
    'hintPromoSubtitle': 'örn. The Bagel Bar — her gün',
    'hintEmoji': 'örn. 🎉',
    'hintButtonText': 'örn. Kart al',
    'hintTagline': 'örn. Taze kahve ve ev tatlıları',
    'hintAddress': 'örn. Nizami Cad. 87, Bakü',
    'hintPhone': '+994 50 123 45 67',
    'hintLatitude': 'örn. 40.4093',
    'hintLongitude': 'örn. 49.8671',
    'hintNfcLabel': 'örn. Kasa 1',
  },
};
