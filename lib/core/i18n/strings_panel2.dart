// Strings for the business / admin panel fixes (confirmations, till window,
// NFC tokens, fallbacks). Same contract as strings.dart: a missing
// translation falls back to the Azerbaijani text in the getter.
import 'strings.dart';

extension PanelStrings2 on S {
  String _q(String key, String az) => _panel2[lang]?[key] ?? az;

  // Admin → users: role / block confirmations.
  String pRoleToAdminBody(String who) => switch (lang) {
        'en' => '$who will get full access to the whole platform: every venue, user and coin.',
        'ru' => '$who получит полный доступ ко всей платформе: всем заведениям, пользователям и coin.',
        'tr' => '$who tüm platforma tam erişim alacak: her mekân, kullanıcı ve coin.',
        _ => '$who bütün platformaya tam giriş alacaq: bütün məkanlar, istifadəçilər və coinlər.',
      };

  String pRoleDemoteOwnerBody(String who) => switch (lang) {
        'en' => '$who is a business owner. They will lose access to their venue panel, programs and till.',
        'ru' => '$who — владелец бизнеса. Доступ к панели заведения, программам и кассе будет закрыт.',
        'tr' => '$who bir işletme sahibi. Mekân paneline, programlara ve kasaya erişimini kaybedecek.',
        _ => '$who biznes sahibidir. Məkan panelinə, kampaniyalara və kassaya girişini itirəcək.',
      };

  String pRoleChangeBody(String who, String role) => switch (lang) {
        'en' => '$who will become: $role.',
        'ru' => 'Новая роль для $who: $role.',
        'tr' => '$who için yeni rol: $role.',
        _ => '$who üçün yeni rol: $role.',
      };

  String pBlockUserBody(String who) => switch (lang) {
        'en' => '$who will be signed out and unable to sign in.',
        'ru' => '$who выйдет из системы и не сможет войти.',
        'tr' => '$who oturumu kapatılacak ve giriş yapamayacak.',
        _ => '$who hesabdan çıxarılacaq və daxil ola bilməyəcək.',
      };

  String pUnblockUserBody(String who) => switch (lang) {
        'en' => '$who will be able to sign in again.',
        'ru' => '$who снова сможет войти.',
        'tr' => '$who yeniden giriş yapabilecek.',
        _ => '$who yenidən daxil ola biləcək.',
      };

  // Admin → notifications.
  String pApproveNotifVenueBody(String venue) => switch (lang) {
        'en' => 'It will be sent to $venue customers right away.',
        'ru' => 'Уведомление сразу уйдёт клиентам заведения $venue.',
        'tr' => '$venue müşterilerine hemen gönderilecek.',
        _ => 'Bildiriş dərhal $venue müştərilərinə göndəriləcək.',
      };

  String get pRoleChangeTitle => _q('pRoleChangeTitle', 'Rolu dəyişirsən?');
  String get pApproveNotifAllBody =>
      _q('pApproveNotifAllBody', 'Bildiriş dərhal bütün istifadəçilərə göndəriləcək.');
  String get pAllUsers => _q('pAllUsers', 'Bütün istifadəçilər');
  String get pVenue => _q('pVenue', 'Məkan');
  String get pVenueRequired => _q('pVenueRequired', 'Məkanı seç');

  // Till.
  String get pSpendSessionGone =>
      _q('pSpendSessionGone', 'Bu müştəriyə artıq baxılıb və ya vaxtı bitib.');
  String get pCustomerAtTill => _q('pCustomerAtTill', 'Müştəri kassada gözləyir');
  String get pOpen => _q('pOpen', 'Aç');
  String get pTillCardSub =>
      _q('pTillCardSub', 'Kassada gözləyən müştərilər və hədiyyələr burada.');

  // NFC.
  String get pNfcTokenTitle => _q('pNfcTokenTitle', 'Kart kodu');
  String get pNfcTokenBody => _q('pNfcTokenBody',
      'Bu cihaz NFC yaza bilmir. Kodu kopyala və kartı Android telefonla yaz.');
  String get pNfcRotateWarn => _q('pNfcRotateWarn',
      'Kartın kodu yenilənəcək. Yenidən yazılana qədər kart işləməyəcək.');
  String get pNfcRevokedContactAdmin =>
      _q('pNfcRevokedContactAdmin', 'Kart ləğv edilib — adminlə əlaqə saxla');
  String get pCopy => _q('pCopy', 'Kopyala');
  String get pCopied => _q('pCopied', 'Kopyalandı');

  // Admin → venue detail.
  String get pCompanyApprovedDone => _q('pCompanyApprovedDone', 'Məkan təsdiqləndi');
  String get pCompanySuspendedDone =>
      _q('pCompanySuspendedDone', 'Məkan dayandırıldı');

  // Fallbacks / defaults.
  String get pBusinessFallback => _q('pBusinessFallback', 'Biznes');
  String get pCustomerFallback => _q('pCustomerFallback', 'Müştəri');
  String get pPromoCtaDefault => _q('pPromoCtaDefault', 'Bax');
  String get pDefaultRewardItem => _q('pDefaultRewardItem', 'qəhvə');
  String get pCashbackWord => _q('pCashbackWord', 'keşbek');
}

const Map<String, Map<String, String>> _panel2 = <String, Map<String, String>>{
  'en': <String, String>{
    'pRoleChangeTitle': 'Change role?',
    'pApproveNotifAllBody': 'It will be sent to every user right away.',
    'pAllUsers': 'All users',
    'pVenue': 'Venue',
    'pVenueRequired': 'Pick a venue',
    'pSpendSessionGone': 'This customer was already served or the session expired.',
    'pCustomerAtTill': 'A customer is waiting at the till',
    'pOpen': 'Open',
    'pTillCardSub': 'Customers and gifts waiting at the till.',
    'pNfcTokenTitle': 'Card code',
    'pNfcTokenBody': 'This device cannot write NFC. Copy the code and write the card with an Android phone.',
    'pNfcRotateWarn': 'The card gets a new code. It stops working until it is rewritten.',
    'pNfcRevokedContactAdmin': 'Card revoked — contact the admin',
    'pCopy': 'Copy',
    'pCopied': 'Copied',
    'pCompanyApprovedDone': 'Venue approved',
    'pCompanySuspendedDone': 'Venue suspended',
    'pBusinessFallback': 'Business',
    'pCustomerFallback': 'Customer',
    'pPromoCtaDefault': 'View',
    'pDefaultRewardItem': 'coffee',
    'pCashbackWord': 'cashback',
  },
  'ru': <String, String>{
    'pRoleChangeTitle': 'Сменить роль?',
    'pApproveNotifAllBody': 'Уведомление сразу уйдёт всем пользователям.',
    'pAllUsers': 'Все пользователи',
    'pVenue': 'Заведение',
    'pVenueRequired': 'Выберите заведение',
    'pSpendSessionGone': 'Клиента уже обслужили или время сеанса истекло.',
    'pCustomerAtTill': 'Клиент ждёт на кассе',
    'pOpen': 'Открыть',
    'pTillCardSub': 'Клиенты и подарки, ожидающие на кассе.',
    'pNfcTokenTitle': 'Код карты',
    'pNfcTokenBody': 'Это устройство не умеет записывать NFC. Скопируйте код и запишите карту с Android-телефона.',
    'pNfcRotateWarn': 'У карты будет новый код. Она не будет работать, пока её не перезапишут.',
    'pNfcRevokedContactAdmin': 'Карта отозвана — обратитесь к администратору',
    'pCopy': 'Копировать',
    'pCopied': 'Скопировано',
    'pCompanyApprovedDone': 'Заведение одобрено',
    'pCompanySuspendedDone': 'Заведение приостановлено',
    'pBusinessFallback': 'Бизнес',
    'pCustomerFallback': 'Клиент',
    'pPromoCtaDefault': 'Смотреть',
    'pDefaultRewardItem': 'кофе',
    'pCashbackWord': 'кэшбэк',
  },
  'tr': <String, String>{
    'pRoleChangeTitle': 'Rol değiştirilsin mi?',
    'pApproveNotifAllBody': 'Tüm kullanıcılara hemen gönderilecek.',
    'pAllUsers': 'Tüm kullanıcılar',
    'pVenue': 'Mekân',
    'pVenueRequired': 'Mekân seç',
    'pSpendSessionGone': 'Bu müşteriyle zaten ilgilenildi veya süre doldu.',
    'pCustomerAtTill': 'Kasada bekleyen bir müşteri var',
    'pOpen': 'Aç',
    'pTillCardSub': 'Kasada bekleyen müşteriler ve hediyeler.',
    'pNfcTokenTitle': 'Kart kodu',
    'pNfcTokenBody': 'Bu cihaz NFC yazamıyor. Kodu kopyala ve kartı bir Android telefonla yaz.',
    'pNfcRotateWarn': 'Karta yeni kod verilecek. Yeniden yazılana kadar kart çalışmaz.',
    'pNfcRevokedContactAdmin': 'Kart iptal edildi — yöneticiyle iletişime geç',
    'pCopy': 'Kopyala',
    'pCopied': 'Kopyalandı',
    'pCompanyApprovedDone': 'Mekân onaylandı',
    'pCompanySuspendedDone': 'Mekân askıya alındı',
    'pBusinessFallback': 'İşletme',
    'pCustomerFallback': 'Müşteri',
    'pPromoCtaDefault': 'İncele',
    'pDefaultRewardItem': 'kahve',
    'pCashbackWord': 'nakit iade',
  },
};
