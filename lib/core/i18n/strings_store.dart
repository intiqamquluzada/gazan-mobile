// Strings for store compliance: legal links, review reporting, business
// account deletion. Same contract as strings.dart: a missing translation
// falls back to the Azerbaijani text.
import 'strings.dart';

extension StoreStrings on S {
  String _st(String key, String az) => _store[lang]?[key] ?? az;

  String get privacyPolicy => _st('privacyPolicy', 'Məxfilik siyasəti');
  String get termsOfUse => _st('termsOfUse', 'İstifadə şərtləri');
  String get consentPrefix => _st('consentPrefix', 'Qeydiyyatdan keçməklə ');
  String get consentAnd => _st('consentAnd', ' və ');
  String get consentSuffix => _st('consentSuffix', ' qəbul edirsən.');
  String get legalSection => _st('legalSection', 'Hüquqi');

  String get reportReview => _st('reportReview', 'Şikayət et');
  String get reportReviewTitle => _st('reportReviewTitle', 'Bu rəyi niyə şikayət edirsən?');
  String get reportReasonAbusive => _st('reportReasonAbusive', 'Təhqiramiz və ya nifrət dolu');
  String get reportReasonSpam => _st('reportReasonSpam', 'Spam və ya reklam');
  String get reportReasonFake => _st('reportReasonFake', 'Saxta və ya yanıltıcı');
  String get reportReasonOther => _st('reportReasonOther', 'Digər');
  String get reportNoteHint => _st('reportNoteHint', 'Qeyd (istəyə bağlı)');
  String get reportSend => _st('reportSend', 'Göndər');
  String get reportSent => _st('reportSent', 'Şikayətin göndərildi. 24 saat ərzində yoxlanılacaq.');
  String get reportedFilter => _st('reportedFilter', 'Şikayət edilən');
  String reportCount(int n) => switch (lang) {
        'en' => '$n reports',
        'ru' => 'Жалоб: $n',
        'tr' => '$n şikayet',
        _ => '$n şikayət',
      };

  String get deleteBusinessAccountBody => _st('deleteBusinessAccountBody',
      'Hesabın və şəxsi məlumatların silinəcək, bütün cihazlarda çıxış ediləcək. '
      'Məkanın səhifəsi admin tərəfindən bağlanana qədər görünə bilər. Bu əməliyyat geri qaytarılmır.');
}

const Map<String, Map<String, String>> _store = <String, Map<String, String>>{
  'en': <String, String>{
    'privacyPolicy': 'Privacy policy',
    'termsOfUse': 'Terms of use',
    'consentPrefix': 'By signing up you accept the ',
    'consentAnd': ' and the ',
    'consentSuffix': '.',
    'legalSection': 'Legal',
    'reportReview': 'Report',
    'reportReviewTitle': 'Why are you reporting this review?',
    'reportReasonAbusive': 'Abusive or hateful',
    'reportReasonSpam': 'Spam or advertising',
    'reportReasonFake': 'Fake or misleading',
    'reportReasonOther': 'Other',
    'reportNoteHint': 'Note (optional)',
    'reportSend': 'Send',
    'reportSent': 'Report sent. It will be reviewed within 24 hours.',
    'reportedFilter': 'Reported',
    'deleteBusinessAccountBody':
        'Your account and personal data will be deleted and you will be signed out everywhere. '
            'The venue page may stay visible until an admin closes it. This cannot be undone.',
  },
  'ru': <String, String>{
    'privacyPolicy': 'Политика конфиденциальности',
    'termsOfUse': 'Условия использования',
    'consentPrefix': 'Регистрируясь, вы принимаете ',
    'consentAnd': ' и ',
    'consentSuffix': '.',
    'legalSection': 'Правовая информация',
    'reportReview': 'Пожаловаться',
    'reportReviewTitle': 'Почему вы жалуетесь на отзыв?',
    'reportReasonAbusive': 'Оскорбления или ненависть',
    'reportReasonSpam': 'Спам или реклама',
    'reportReasonFake': 'Фейк или обман',
    'reportReasonOther': 'Другое',
    'reportNoteHint': 'Комментарий (необязательно)',
    'reportSend': 'Отправить',
    'reportSent': 'Жалоба отправлена. Её проверят в течение 24 часов.',
    'reportedFilter': 'С жалобами',
    'deleteBusinessAccountBody':
        'Аккаунт и личные данные будут удалены, вы выйдете на всех устройствах. '
            'Страница заведения может оставаться видимой, пока её не закроет администратор. Отменить нельзя.',
  },
  'tr': <String, String>{
    'privacyPolicy': 'Gizlilik politikası',
    'termsOfUse': 'Kullanım koşulları',
    'consentPrefix': 'Kayıt olarak ',
    'consentAnd': ' ve ',
    'consentSuffix': ' kabul edersin.',
    'legalSection': 'Yasal',
    'reportReview': 'Şikayet et',
    'reportReviewTitle': 'Bu yorumu neden şikayet ediyorsun?',
    'reportReasonAbusive': 'Hakaret veya nefret içerikli',
    'reportReasonSpam': 'Spam veya reklam',
    'reportReasonFake': 'Sahte veya yanıltıcı',
    'reportReasonOther': 'Diğer',
    'reportNoteHint': 'Not (isteğe bağlı)',
    'reportSend': 'Gönder',
    'reportSent': 'Şikayetin gönderildi. 24 saat içinde incelenecek.',
    'reportedFilter': 'Şikayet edilen',
    'deleteBusinessAccountBody':
        'Hesabın ve kişisel verilerin silinecek, tüm cihazlarda çıkış yapılacak. '
            'Mekân sayfası bir yönetici kapatana kadar görünebilir. Bu işlem geri alınamaz.',
  },
};
