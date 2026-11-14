// Strings for the stamp/coin campaign flow fixes. Same contract as
// strings.dart: a missing translation falls back to the Azerbaijani text.
import 'strings.dart';

extension CampaignStrings on S {
  String _c(String key, String az) => _campaign[lang]?[key] ?? az;

  /// Balance line after a points tap: coins only count at this venue.
  String coinsAtVenue(int n) => switch (lang) {
        'en' => 'Your coins here: $n',
        'ru' => 'Ваши coin здесь: $n',
        'tr' => 'Bu mekândaki coinlerin: $n',
        _ => 'Bu məkandakı coinlərin: $n',
      };

  String coinsTotalAcross(int n) => switch (lang) {
        'en' => 'Total across venues: $n',
        'ru' => 'Всего во всех заведениях: $n',
        'tr' => 'Tüm mekânlarda toplam: $n',
        _ => 'Bütün məkanlarda cəmi: $n',
      };

  /// Purchase confirmation body.
  String buyConfirmBody(String item, int price, int after) => switch (lang) {
        'en' => '$item for $price coins. You will have $after coins left here.',
        'ru' => '$item за $price coin. Здесь останется $after coin.',
        'tr' => '$item, $price coin. Burada $after coin kalacak.',
        _ => '$item — $price coin. Bu məkanda $after coin qalacaq.',
      };

  String get coinsByVenue => _c('coinsByVenue', 'Coinlərin məkanlar üzrə');
  String get coinsOnlyHere => _c('coinsOnlyHere',
      'Coin yalnız qazandığın məkanda xərclənir.');
  String get noCoinsYet => _c('noCoinsYet', 'Hələ coin yoxdur');
  String get spendExpiredTitle => _c('spendExpiredTitle', 'Vaxt bitdi');
  String get spendExpiredBody => _c('spendExpiredBody',
      'Kassa pəncərəsi bağlandı. Hədiyyən üçün kartı yenidən oxut.');
  String get buyConfirmTitle => _c('buyConfirmTitle', 'Hədiyyəni alırsan?');
  String get giftEditTitle => _c('giftEditTitle', 'Hədiyyəni dəyiş');
  String get giftActive => _c('giftActive', 'Satışda');
  String get giftInactive => _c('giftInactive', 'Satışda deyil');
  String get giftDeleteTitle => _c('giftDeleteTitle', 'Hədiyyə silinsin?');
  String get giftDeleteBody => _c('giftDeleteBody',
      'Artıq alınmış kuponlar qüvvədə qalır.');
  String get programDeleteTitle =>
      _c('programDeleteTitle', 'Kampaniya silinsin?');
  String get programClosed => _c('programClosed', 'Bitib');
}

const Map<String, Map<String, String>> _campaign = <String, Map<String, String>>{
  'en': <String, String>{
    'coinsByVenue': 'Your coins by venue',
    'coinsOnlyHere': 'Coins can only be spent where you earned them.',
    'noCoinsYet': 'No coins yet',
    'spendExpiredTitle': 'Time is up',
    'spendExpiredBody':
        'The cashier window closed. Tap the card again for your gift.',
    'buyConfirmTitle': 'Buy this gift?',
    'giftEditTitle': 'Edit gift',
    'giftActive': 'On sale',
    'giftInactive': 'Not on sale',
    'giftDeleteTitle': 'Delete this gift?',
    'giftDeleteBody': 'Vouchers already bought stay valid.',
    'programDeleteTitle': 'Delete this campaign?',
    'programClosed': 'Ended',
  },
  'ru': <String, String>{
    'coinsByVenue': 'Ваши coin по заведениям',
    'coinsOnlyHere': 'Coin можно потратить только там, где вы их получили.',
    'noCoinsYet': 'Пока нет coin',
    'spendExpiredTitle': 'Время вышло',
    'spendExpiredBody':
        'Окно кассы закрылось. Приложите карту ещё раз, чтобы получить подарок.',
    'buyConfirmTitle': 'Купить подарок?',
    'giftEditTitle': 'Изменить подарок',
    'giftActive': 'В продаже',
    'giftInactive': 'Не в продаже',
    'giftDeleteTitle': 'Удалить подарок?',
    'giftDeleteBody': 'Уже купленные купоны остаются в силе.',
    'programDeleteTitle': 'Удалить кампанию?',
    'programClosed': 'Завершена',
  },
  'tr': <String, String>{
    'coinsByVenue': 'Mekâna göre coinlerin',
    'coinsOnlyHere': 'Coin yalnızca kazandığın mekânda harcanır.',
    'noCoinsYet': 'Henüz coin yok',
    'spendExpiredTitle': 'Süre doldu',
    'spendExpiredBody':
        'Kasa penceresi kapandı. Hediyen için kartı tekrar okut.',
    'buyConfirmTitle': 'Hediyeyi alıyor musun?',
    'giftEditTitle': 'Hediyeyi düzenle',
    'giftActive': 'Satışta',
    'giftInactive': 'Satışta değil',
    'giftDeleteTitle': 'Hediye silinsin mi?',
    'giftDeleteBody': 'Daha önce alınmış kuponlar geçerli kalır.',
    'programDeleteTitle': 'Kampanya silinsin mi?',
    'programClosed': 'Bitti',
  },
};
