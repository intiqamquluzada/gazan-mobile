import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/application/profile_settings_controller.dart';

export 'strings_avatar.dart';
export 'strings_campaign.dart';
export 'strings_email_otp.dart';
export 'strings_ext.dart';
export 'strings_hints.dart';
export 'strings_store.dart';

/// Lightweight translator for the app's UI chrome (tabs, buttons, dialog
/// text, menu rows, common labels). Backed by a per-language map; a
/// missing key falls back to the Azerbaijani default hard-coded in each
/// getter, so a gap is never a blank string.
///
/// Usage from any Consumer:
/// ```dart
/// final S s = ref.watch(sProvider);
/// Text(s.tabHome);
/// ```
class S {
  const S(this.lang);

  final String lang;

  String _(String key, String az) => _all[lang]?[key] ?? az;

  // ── Auth ─────────────────────────────────────────────────────────
  String get whoAreYou => _('whoAreYou', 'Sən kimsən?');
  String get whoAreYouSub => _('whoAreYouSub',
      'Hesab yaratmaq üçün rolunu seç. İstənilən vaxt dəyişə bilərsən.');
  String get iAmCustomer => _('iAmCustomer', 'Mən müştəriyəm');
  String get iAmBusiness => _('iAmBusiness', 'Mən biznesəm');
  String get customerHint =>
      _('customerHint', 'Sevimli yerlərimdən bonus toplamaq');
  String get businessHint =>
      _('businessHint', 'Müştərilərimi izləmək və sadiqlik proqramı yaratmaq');
  String get login => _('login', 'Daxil ol');
  String get register => _('register', 'Qeydiyyat');
  String get email => _('email', 'E-poçt');
  String get password => _('password', 'Şifrə');
  String get fullName => _('fullName', 'Ad və soyad');
  String get phone => _('phone', 'Telefon nömrəsi');
  String get forgotPassword => _('forgotPassword', 'Şifrəni unutmusan?');
  String get noAccount => _('noAccount', 'Hesabın yoxdur?');
  String get haveAccount => _('haveAccount', 'Hesabın var?');
  String get welcome => _('welcome', 'Xoş gəlmisiniz');
  String get createAccount => _('createAccount', 'Hesab yarat');

  // ── Customer tabs ────────────────────────────────────────────────
  String get tabHome => _('tabHome', 'Kəşf et');
  String get tabCompanies => _('tabCompanies', 'Kompaniyalar');
  String get tabCards => _('tabCards', 'Kartlarım');
  String get tabProfile => _('tabProfile', 'Profil');
  String get tabRewards => _('tabRewards', 'Hədiyyələrim');

  // ── Business tabs ────────────────────────────────────────────────
  String get tabDashboard => _('tabDashboard', 'Panel');
  String get tabCustomers => _('tabCustomers', 'Müştərilər');
  String get tabScan => _('tabScan', 'Skan');
  String get tabPrograms => _('tabPrograms', 'Proqramlar');
  String get tabMyBusiness => _('tabMyBusiness', 'Biznesim');

  // ── Admin tabs ───────────────────────────────────────────────────
  String get tabPanel => _('tabPanel', 'Panel');
  String get tabUsers => _('tabUsers', 'İstifadəçilər');
  String get tabBusinesses => _('tabBusinesses', 'Biznes');
  String get tabCoins => _('tabCoins', 'Coin');
  String get tabNotify => _('tabNotify', 'Bildiriş');

  // ── Common actions ───────────────────────────────────────────────
  String get save => _('save', 'Yadda saxla');
  String get cancel => _('cancel', 'Ləğv et');
  String get close => _('close', 'Bağla');
  String get logout => _('logout', 'Çıxış');
  String get stay => _('stay', 'Qal');
  String get all => _('all', 'Hamısı');
  String get seeAll => _('seeAll', 'Hamısına bax');
  String get edit => _('edit', 'Düzəliş et');
  String get search => _('search', 'Axtar...');
  String get logoutTitle => _('logoutTitle', 'Çıxmaq istəyirsən?');

  // ── Profile ──────────────────────────────────────────────────────
  String get profile => _('profile', 'Profil');
  String get account => _('account', 'Hesab');
  String get help => _('help', 'Yardım');
  String get editProfile => _('editProfile', 'Profili düzəliş et');
  String get security => _('security', 'Təhlükəsizlik');
  String get language => _('language', 'Dil');
  String get appearance => _('appearance', 'Görünüş');
  String get notifications => _('notifications', 'Bildirişlər');
  String get guest => _('guest', 'Qonaq');
  String get nameAndPhone => _('nameAndPhone', 'Ad, telefon');
  String get favorites => _('favorites', 'Sevimlilər');
  String get faq => _('faq', 'Tez-tez verilən suallar');
  String get contactSupport => _('contactSupport', 'Dəstəklə əlaqə');
  String get aboutApp => _('aboutApp', 'Tətbiq haqqında');
  String get deleteAccount => _('deleteAccount', 'Hesabı sil');
  String get activeCard => _('activeCard', 'Aktiv kart');
  String get rewardsEarned => _('rewardsEarned', 'Qazanılan mükafat');

  // ── Business ─────────────────────────────────────────────────────
  String get hello => _('hello', 'Salam,');
  String get activeCustomers => _('activeCustomers', 'Aktiv müştəri');
  String get stampsToday => _('stampsToday', 'Bu gün möhür');
  String get rewardsWeek => _('rewardsWeek', 'Həftədə mükafat');
  String get returnRate => _('returnRate', 'Geri qayıdış');
  String get recentCustomers => _('recentCustomers', 'Son müştərilər');
  String get scanCustomerQr =>
      _('scanCustomerQr', 'Müştərinin QR kodunu skan et');
  String get noCustomersYet => _('noCustomersYet', 'Hələ müştəri yoxdur');
  String get myBusiness => _('myBusiness', 'Mənim biznesim');
  String get writeNotification =>
      _('writeNotification', 'Müştərilərinə bildiriş yaz');

  // ── Cards / rewards ──────────────────────────────────────────────
  String get myCards => _('myCards', 'Kartlarım');
  String get loyaltyCards => _('loyaltyCards', 'Sadiqlik kartları');
  String get noCardsYet => _('noCardsYet', 'Hələ kartın yoxdur');
  String get rewardsActive => _('rewardsActive', 'Aktiv');
  String get rewardsUsed => _('rewardsUsed', 'İstifadə olunmuş');

  // ── Programs ─────────────────────────────────────────────────────
  String get loyaltyPrograms => _('loyaltyPrograms', 'Sadiqlik proqramları');
  String get stampPrograms => _('stampPrograms', 'Möhür proqramları');
  String get newProgram => _('newProgram', 'Yeni proqram');
  String get noProgramsYet => _('noProgramsYet', 'Hələ proqram yoxdur');
  String get rewardCatalog => _('rewardCatalog', 'Mükafat kataloqu');
  String get add => _('add', 'Əlavə et');
  String get delete => _('delete', 'Sil');

  // ── Common ───────────────────────────────────────────────────────
  String get error => _('error', 'Xəta');
  String get retry => _('retry', 'Yenidən cəhd et');
  String get nothingFound => _('nothingFound', 'Heç nə tapılmadı');
  String get comingSoon => _('comingSoon', 'Tezliklə');
  String get notLoaded => _('notLoaded', 'Yüklənmədi');
  String get notFound => _('notFound', 'Tapılmadı');
  String get loading => _('loading', 'Yüklənir...');
  String get loadMore => _('loadMore', 'Daha çox');
  String get failed => _('failed', 'Alınmadı');
  String get cardAddedSuffix => _('cardAddedSuffix', 'kartı əlavə olundu');
  String get purchasedSeeGifts =>
      _('purchasedSeeGifts', 'alındı — Hədiyyələrim-də gör');
  String get shareOnMap => _('shareOnMap', 'Xəritədə');
  String get shareDiscover => _('shareDiscover', 'Qazan tətbiqində kəşf et');
  String get enter => _('enter', 'Daxil et');
  String get done => _('done', 'Hazırdır');

  // ── Edit profile sheet ───────────────────────────────────────────
  String get profileUpdated => _('profileUpdated', 'Profil yeniləndi');
  String get emailReadOnly => _('emailReadOnly', 'E-poçt (dəyişdirilə bilməz)');
  String get enterName => _('enterName', 'Adı yaz');

  // ── Security sheet ───────────────────────────────────────────────
  String get changePassword => _('changePassword', 'Şifrəni dəyiş');
  String get passwordUpdated => _('passwordUpdated', 'Şifrə yeniləndi ✓');
  String get currentPassword => _('currentPassword', 'Hazırkı şifrə');
  String get newPassword => _('newPassword', 'Yeni şifrə');
  String get repeatNewPassword =>
      _('repeatNewPassword', 'Yeni şifrəni təkrarla');
  String get min8Chars => _('min8Chars', '8+ simvol olsun');
  String get passwordsDontMatch =>
      _('passwordsDontMatch', 'Şifrələr uyğun gəlmir');

  // ── Notifications sheet ──────────────────────────────────────────
  String get notifWhichEvents =>
      _('notifWhichEvents', 'Hansı hadisələrdən xəbərdar olmaq istəyirsən?');
  String get notifNewReward => _('notifNewReward', 'Yeni mükafat');
  String get notifNewRewardSub =>
      _('notifNewRewardSub', 'Bir kart tamamlananda dərhal məlumat ver');
  String get notifNearby => _('notifNearby', 'Yaxınlıqdakı təkliflər');
  String get notifNearbySub =>
      _('notifNearbySub', 'Sənin yerlərində yeni promo başlayanda xəbərdar et');
  String get notifWeekly => _('notifWeekly', 'Həftəlik xülasə');
  String get notifWeeklySub =>
      _('notifWeeklySub', 'Hər bazar nə qədər qazandığını göndər');
  String get notifMarketing => _('notifMarketing', 'Marketinq və promosiyalar');
  String get notifMarketingSub =>
      _('notifMarketingSub', 'Yeni biznes və xüsusi kampaniyalar');

  // ── Help / FAQ sheet ─────────────────────────────────────────────
  String get faqQ1 => _('faqQ1', 'Möhürü necə qazanıram?');
  String get faqA1 => _('faqA1',
      'Alış-veriş edəndə kassir məkanın kartını telefonuna toxundurur — möhür dərhal əlavə olunur.');
  String get faqQ2 => _('faqQ2', 'Mükafatı necə alıram?');
  String get faqA2 => _('faqA2',
      'Kart tam dolanda "Kartlarım" bölməsində bildiriş görəcəksən. Növbəti ziyarətdə hədiyyəni kassada təhvil al.');
  String get faqQ3 => _('faqQ3', 'Birdən çox kartım ola bilərmi?');
  String get faqA3 => _('faqA3',
      'Bəli! Hər obyektin öz kartı var. Bir obyektin müxtəlif proqramları üçün də ayrı kartlar yığa bilərsən.');
  String get faqQ4 => _('faqQ4', 'Müştəri məlumatlarım kimə görünür?');
  String get faqA4 => _('faqA4',
      'Yalnız sənin kart açdığın obyektlər səni görür — və yalnız sənin onlardakı möhür və ziyarət sayını.');
  String get faqQ5 => _('faqQ5', 'Mükafatın vaxtı bitirmi?');
  String get faqA5 => _('faqA5',
      'Bir qisim proqramların bitmə tarixi olur. Detalı kartın açılan səhifəsində görə bilərsən.');
  String get faqQ6 => _('faqQ6', 'Telefonumu dəyişsəm kartlarım itəcəkmi?');
  String get faqA6 => _('faqA6',
      'Yox. Hesabına yenidən daxil olduqda bütün kartların və möhür tarixçən bərpa olunacaq.');

  // ── Theme sheet ──────────────────────────────────────────────────
  String get themeLight => _('themeLight', 'Açıq');
  String get themeLightSub =>
      _('themeLightSub', 'Həmişə açıq tema istifadə et');
  String get themeDark => _('themeDark', 'Tünd');
  String get themeDarkSub => _('themeDarkSub', 'Həmişə tünd tema istifadə et');
  String get themeSystem => _('themeSystem', 'Sistem');
  String get themeSystemSub => _('themeSystemSub', 'Cihaz parametrini izlə');

  // ── Language sheet ───────────────────────────────────────────────
  String get languageNote => _(
      'languageNote', 'Qeyd: lokalizasiya tezliklə bütün ekranlara yayılacaq.');

  // ── Business profile screen ──────────────────────────────────────
  String get businessProfileUpdated =>
      _('businessProfileUpdated', 'Biznes profili yeniləndi ✓');
  String get photoNotPicked => _('photoNotPicked', 'Şəkil seçilmədi');
  String get photosSaved => _('photosSaved', 'Şəkillər yadda saxlanıldı ✓');
  String get photoNotUploaded => _('photoNotUploaded', 'Şəkil yüklənmədi');
  String get logoUpdated => _('logoUpdated', 'Profil şəkli yeniləndi ✓');
  String get logoNotUploaded => _('logoNotUploaded', 'Logo yüklənmədi');
  String get signOutBusinessBody => _('signOutBusinessBody',
      'Biznes hesabından çıxacaqsan. Yenidən daxil olaraq qayıda bilərsən.');
  String get sectionProfilePhoto => _('sectionProfilePhoto', 'Profil şəkli');
  String get logoHint => _('logoHint',
      'Müştəri ana səhifəsində bu şəkil görünür. Kvadrat / loqo şəkli yüklə.');
  String get uploadLogo => _('uploadLogo', 'Logo yüklə');
  String get change => _('change', 'Dəyiş');
  String get sectionBasicInfo => _('sectionBasicInfo', 'Əsas məlumat');
  String get name => _('name', 'Ad');
  String get taglineLabel => _('taglineLabel', 'Şüar / qısa təsvir');
  String get category => _('category', 'Kateqoriya');
  String get sectionContactHours => _('sectionContactHours', 'Əlaqə & saatlar');
  String get address => _('address', 'Ünvan');
  String get workingHours => _('workingHours', 'İş saatları');
  String get workingHoursHint => _('workingHoursHint', 'məs. 09:00 – 23:00');
  String get openNow => _('openNow', 'Açıqdır');
  String get closedNow => _('closedNow', 'Bağlıdır');
  String get collectPoints => _('collectPoints', 'Coin topla');
  String get nfcTitle => _('nfcTitle', 'Kartı oxut');
  String get nfcHoldPhone =>
      _('nfcHoldPhone', 'Telefonu kassadakı karta yaxınlaşdır');
  String get nfcHoldPhoneBody => _('nfcHoldPhoneBody',
      'Kassir möhür və ya xal kartını telefonun arxasına toxundursun.');
  String get nfcShowQrInstead => _('nfcShowQrInstead', 'QR göstər');
  String get nfcUnsupported => _('nfcUnsupported', 'Bu telefonda NFC yoxdur');
  String get nfcUnsupportedBody => _('nfcUnsupportedBody',
      'Möhür və xal toplamaq üçün kassirə müraciət et — hesabına əl ilə əlavə edə bilər.');
  String get nfcDisabled => _('nfcDisabled', 'NFC söndürülüb');
  String get nfcDisabledBody => _('nfcDisabledBody',
      'Telefonun ayarlarından NFC-ni aç və yenidən yoxla.');
  String get nfcRetry => _('nfcRetry', 'Yenidən yoxla');
  String get nfcFailed => _('nfcFailed', 'Alınmadı');
  String get nfcAgain => _('nfcAgain', 'Yenidən oxut');
  String get nfcNotOurCard =>
      _('nfcNotOurCard', 'Bu kart Qazan kartı deyil.');
  String get nfcOfflineQueued => _('nfcOfflineQueued',
      'İnternet yoxdur — oxunuş saxlanıldı, bağlantı qayıdanda göndəriləcək.');
  String nfcQueuedSent(int n) =>
      _('nfcQueuedSent', 'Oflayn {n} oxunuş göndərildi').replaceAll('{n}', '$n');
  String get nfcCards => _('nfcCards', 'NFC kartlar');
  String get nfcTapLog => _('nfcTapLog', 'Oxunuşlar');
  String get nfcWriteCard => _('nfcWriteCard', 'Karta yaz');
  String get nfcWriteHold =>
      _('nfcWriteHold', 'Boş kartı telefonun arxasına yaxınlaşdır');
  String get nfcWritten => _('nfcWritten', 'Kart yazıldı');
  String get nfcNewCard => _('nfcNewCard', 'Yeni kart');
  String get nfcKindStamp => _('nfcKindStamp', 'Möhür kartı');
  String get nfcKindPoints => _('nfcKindPoints', 'Xal kartı');
  String get nfcPointsPerTap => _('nfcPointsPerTap', 'Hər oxunuşda xal');
  String get nfcCooldown => _('nfcCooldown', 'Təkrar gözləmə (san.)');
  String get nfcDailyCap => _('nfcDailyCap', 'Gündə limit (hər müştəri)');
  String get nfcBlock => _('nfcBlock', 'Blokla');
  String get nfcUnblock => _('nfcUnblock', 'Blokdan çıxar');
  String get nfcRotate => _('nfcRotate', 'Yeni kod ver');
  String get nfcSuspiciousOnly => _('nfcSuspiciousOnly', 'Şübhəli');
  String get nfcTapShort => _('nfcTapShort', 'Kartı oxut');
  String get loginSub => _('loginSub',
      'Hesabınla daxil ol — müştəri və ya biznes, fərqi yoxdur.');
  String get countryLabel => _('countryLabel', 'Ölkə');
  String get currencyLabel => _('currencyLabel', 'Valyuta');
  String get roleCustomer2 => _('roleCustomer2', 'Müştəri');
  String get roleBusiness2 => _('roleBusiness2', 'Biznes');
  String get pendingRewards => _('pendingRewards', 'Gözləyən hədiyyələr');
  String get noPendingRewards =>
      _('noPendingRewards', 'Gözləyən hədiyyə yoxdur');
  String get noPendingRewardsHint => _('noPendingRewardsHint',
      'Müştəri kartı tamamlayanda və ya coinlə hədiyyə alanda burada görünəcək.');
  String get rewardHandOver => _('rewardHandOver', 'İstifadə olundu');
  String get rewardHandOverTitle =>
      _('rewardHandOverTitle', 'Hədiyyə istifadə olundu kimi qeyd edilsin?');
  String get nfcCardsTrailing => _('nfcCardsTrailing', 'Möhür və xal kartları');
  String get nfcNoCardsBusiness => _('nfcNoCardsBusiness',
      'Hələ kart verilməyib — admin ilə əlaqə saxlayın.');
  String get nfcNotWritten => _('nfcNotWritten', 'Karta yazılmayıb');
  String get nfcNotWritable => _('nfcNotWritable',
      'Bu etiketə yazmaq olmur (kilidlənib və ya uyğun deyil).');
  String get nfcWrittenBody => _('nfcWrittenBody',
      'Kartı kassaya ver. İndi müştəri telefonuna toxundurula bilər.');
  String get nfcCooldownHelp => _('nfcCooldownHelp',
      'Eyni müştəri bu kartı nə qədər tez-tez oxuda bilər.');
  String get menuOwnerHint => _('menuOwnerHint',
      'Menyu əlavə et ki, müştərilər nə təklif etdiyini və qiymətləri görsün.');
  String get menuDeleteBody =>
      _('menuDeleteBody', 'Bu məhsul menyudan silinəcək.');
  String get deleteReviewTitle => _('deleteReviewTitle', 'Rəyi sil?');
  String get lowRatingsOnly => _('lowRatingsOnly', '1–2 ulduz');
  String get myBusinessSection => _('myBusinessSection', 'Biznesim');
  String get menuOwnerTrailing =>
      _('menuOwnerTrailing', 'Məhsullar, qiymətlər');
  String get reviewsOwnerTrailing =>
      _('reviewsOwnerTrailing', 'Müştəri rəyləri');
  String get adImageLabel => _('adImageLabel', 'Arxa fon şəkli');
  String get adImageHint =>
      _('adImageHint', 'Boş qalsa, məkanın örtük şəkli istifadə olunur.');
  String get uploadPhoto => _('uploadPhoto', 'Şəkil yüklə');
  String get reviewLockedHint => _('reviewLockedHint',
      'Rəy yazmaq üçün bu məkanda ən azı bir möhür və ya coin qazan.');
  String get rewardReadyTitle => _('rewardReadyTitle', 'Hədiyyən hazırdır!');
  String get rewardReadyBody => _('rewardReadyBody',
      'Kartını tamamladın. Hədiyyəni kassada təhvil al.');
  String get useReward => _('useReward', 'İstifadə et');
  String moreCampaigns(int n) =>
      _('moreCampaigns', '+{n} kampaniya daha').replaceAll('{n}', '$n');
  String moreCampaignsShort(int n) =>
      _('moreCampaignsShort', '+{n} kampaniya').replaceAll('{n}', '$n');
  String get instagramHint => _('instagramHint', '@hesab');
  String get sectionLocationMap => _('sectionLocationMap', 'Yer (xəritə)');
  String get pickOnMap => _('pickOnMap', 'Xəritədən seç');
  String get latitude => _('latitude', 'Enlik (lat)');
  String get longitude => _('longitude', 'Uzunluq (lng)');
  String get sectionAmenities => _('sectionAmenities', 'İmkanlar');
  String get amWifi => _('amWifi', 'Wifi');
  String get amWorkspace => _('amWorkspace', 'Çalışma');
  String get amMeeting => _('amMeeting', 'Toplantı');
  String get amGarden => _('amGarden', 'Bağça');
  String get amParking => _('amParking', 'Avtopark');
  String get amVegan => _('amVegan', 'Vegan');
  String get amPet => _('amPet', 'Pet');
  String get sectionPhotoMenu => _('sectionPhotoMenu', 'Foto & menyu');
  String get businessPhotosHint => _('businessPhotosHint',
      'Biznes şəkilləri — telefon/kompüterindən yüklə (profil və axtarış səhifəsində görünür).');
  String get menuLink => _('menuLink', 'Menyu linki');
  String get menuLinkHint =>
      _('menuLinkHint', 'https://... (PDF / sayt / şəkil)');
  String get sectionCoinSystem => _('sectionCoinSystem', 'Coin sistemi');
  String get coinRate => _('coinRate', 'Coin dərəcəsi (1 ₼ üçün neçə coin)');
  String get coinRateHint => _('coinRateHint', 'məs. 0.1  → 1000 ₼ = 100 coin');
  String get coinRateNote => _('coinRateNote',
      'Kassir skan edəndə çek məbləğini yazır — coin avtomatik hesablanır. Mükafat kataloqu isə "Proqramlar" bölməsindədir.');
  String get translationsOptional =>
      _('translationsOptional', 'Tərcümələr (ixtiyari)');
  String get translationsHint => _('translationsHint',
      'Adı və şüarı EN / RU / TR dillərində doldura bilərsən.');
  String get nameEn => _('nameEn', 'Ad (EN)');
  String get taglineEn => _('taglineEn', 'Şüar (EN)');
  String get nameRu => _('nameRu', 'Ad (RU)');
  String get taglineRu => _('taglineRu', 'Şüar (RU)');
  String get nameTr => _('nameTr', 'Ad (TR)');
  String get taglineTr => _('taglineTr', 'Şüar (TR)');
  String get createYourBusiness => _('createYourBusiness', 'Biznesini yarat');
  String get createBusinessHint => _('createBusinessHint',
      'Bu hesabın hələ biznesi yoxdur. Aşağıdakıları doldur — sonra foto, menyu, imkanlar və s. əlavə edə bilərsən.');
  String get businessName => _('businessName', 'Biznes adı');
  String get createBusiness => _('createBusiness', 'Biznes yarat');
  String get enterBusinessName =>
      _('enterBusinessName', 'Biznes adını yaz (ən az 2 hərf)');
  String get businessCreated =>
      _('businessCreated', 'Biznes yaradıldı ✓ İndi profili tamamla');
  String get addPhoto => _('addPhoto', 'Şəkil əlavə et');

  // ── Admin dashboard ──────────────────────────────────────────────
  String get qazanAdmin => _('qazanAdmin', 'Qazan Admin');
  String get platformPanel => _('platformPanel', 'Platforma paneli');
  String get signOutAdminBody =>
      _('signOutAdminBody', 'Admin hesabından çıxacaqsan.');
  String get noData => _('noData', 'Məlumat yoxdur');
  String get statsUnavailable =>
      _('statsUnavailable', 'Statistika əlçatan deyil.');
  String get promotions => _('promotions', 'Reklamlar');
  String get menus => _('menus', 'Menyular');
  String get adminUser => _('adminUser', 'İstifadəçi');
  String get adminBusiness => _('adminBusiness', 'Biznes');
  String get loyaltyCard => _('loyaltyCard', 'Loyallıq kartı');
  String get coinTransaction => _('coinTransaction', 'Coin əməliyyatı');
  String get coinCirculation => _('coinCirculation', 'Coin dövriyyəsi');
  String get currentBalanceCoin =>
      _('currentBalanceCoin', 'cari balans (coin)');
  String get earnedLabel => _('earnedLabel', 'Qazanılıb');
  String get spentLabel => _('spentLabel', 'Xərclənib');
  String get recentSignups => _('recentSignups', 'Son qeydiyyatlar');
  String get noUsersYet => _('noUsersYet', 'Hələ istifadəçi yoxdur');
  String get signupsHere => _('signupsHere', 'Qeydiyyatlar burada görünəcək.');
  String get recentBusinesses => _('recentBusinesses', 'Son bizneslər');
  String get noBusinessesYet => _('noBusinessesYet', 'Hələ biznes yoxdur');
  String get newBusinessesHere =>
      _('newBusinessesHere', 'Yeni bizneslər burada görünəcək.');
  String get roleCustomer => _('roleCustomer', 'Müştəri');
  String get roleBusiness => _('roleBusiness', 'Biznes');
  String get roleAdmin => _('roleAdmin', 'Admin');
  String get unnamed => _('unnamed', '(adsız)');

  // ── Admin users ──────────────────────────────────────────────────
  String get searchNameEmail => _('searchNameEmail', 'Ad və ya e-poçt axtar');
  String get filterTryAgain =>
      _('filterTryAgain', 'Filtri dəyişib yenidən cəhd et.');
  String get assignRole => _('assignRole', 'Rol təyin et');
  String get blockUser => _('blockUser', 'İstifadəçini blokla');
  String get activateUser => _('activateUser', 'İstifadəçini aktivləşdir');
  String get userBlocked => _('userBlocked', 'bloklandı');
  String get userActivated => _('userActivated', 'aktivləşdi');

  // ── Auth extras (register / login / forgot) ──────────────────────
  String get promoteBusiness => _('promoteBusiness', 'Biznesini tanıt');
  String get registerBusinessSub =>
      _('registerBusinessSub', 'Biznes profilin sənin üçün hazırlanır.');
  String get registerCustomerSub => _(
      'registerCustomerSub', 'Bir neçə dəqiqədə qoşul və ilk möhürünü qazan.');
  String get businessNameHint => _('businessNameHint', 'məs. Qazan Coffee');
  String get fullNameHint => _('fullNameHint', 'məs. Əli Məmmədov');
  String get emailHint => _('emailHint', 'sən@qazan.az');
  String get enterNameShort => _('enterNameShort', 'Adı qeyd et');
  String get invalidEmail => _('invalidEmail', 'Düzgün e-poçt daxil et');
  String get passwordHintMin8 => _('passwordHintMin8', 'ən azı 8 simvol');
  String get registrationFailed =>
      _('registrationFailed', 'Qeydiyyat alınmadı');
  String get birthDateOptional =>
      _('birthDateOptional', 'Doğum tarixi (istəyə bağlı)');
  String get pickDate => _('pickDate', 'Tarixi seç');
  String get pickBirthDate => _('pickBirthDate', 'Doğum tarixini seç');
  String get selectAction => _('selectAction', 'Seç');
  String get phoneNumberInvalid =>
      _('phoneNumberInvalid', 'Telefon nömrəsi düzgün deyil');
  String get pwRuleMin8 => _('pwRuleMin8', 'Ən azı 8 simvol');
  String get pwRuleLetter => _('pwRuleLetter', 'Ən azı bir hərf');
  String get pwRuleDigit => _('pwRuleDigit', 'Ən azı bir rəqəm');
  String get pwErrMin8 => _('pwErrMin8', 'Ən azı 8 simvol');
  String get pwErrLetter => _('pwErrLetter', 'Ən azı bir hərf olmalıdır');
  String get pwErrDigit => _('pwErrDigit', 'Ən azı bir rəqəm olmalıdır');
  String get skip => _('skip', 'Keç');
  String get loginBusinessSub =>
      _('loginBusinessSub', 'Biznes hesabına daxil ol və müştərilərini izlə.');
  String get loginCustomerSub =>
      _('loginCustomerSub', 'Hesabına daxil ol və sevimli yerlərindən qazan.');
  String get loginFailed => _('loginFailed', 'Daxil olmaq alınmadı');
  String get roleMismatchBusiness => _('roleMismatchBusiness',
      'Bu giriş biznes hesabları üçündür. Müştəri hesabı ilə "Mən müştəriyəm" bölməsindən daxil ol.');
  String get roleMismatchCustomer => _('roleMismatchCustomer',
      'Bu giriş müştəri hesabları üçündür. Biznes hesabı ilə "Mən biznesəm" bölməsindən daxil ol.');
  String get passwordShort => _('passwordShort', 'Şifrə qısadır');
  String get resetPassword => _('resetPassword', 'Şifrəni sıfırla');
  String get resetPasswordEmailPrompt => _('resetPasswordEmailPrompt',
      'Hesabının e-poçtunu yaz — sənə 6 rəqəmli kod göndərək.');
  String get codeSentToEmail => _('codeSentToEmail',
      'Kod e-poçtuna göndərildi. Gəlməsə spam qovluğunu yoxla.');
  String get errorTryAgain =>
      _('errorTryAgain', 'Xəta baş verdi. Bir azdan yenidən cəhd et.');
  String get newPasswordReady =>
      _('newPasswordReady', 'İndi yeni şifrənlə daxil ola bilərsən.');
  String get codeSentPrompt =>
      _('codeSentPrompt', 'ünvanına göndərilən kodu və yeni şifrəni daxil et.');
  String get sendCode => _('sendCode', 'Kod göndər');
  String get resendCode => _('resendCode', 'Kodu yenidən göndər');
  String get confirmationCode => _('confirmationCode', 'Təsdiq kodu');
  String get sixDigits => _('sixDigits', '6 rəqəm');
  String get enterSixDigitCode =>
      _('enterSixDigitCode', '6 rəqəmli kodu daxil et');
  String get eightPlusChars => _('eightPlusChars', '8+ simvol');
  String get updatePasswordAction =>
      _('updatePasswordAction', 'Şifrəni yenilə');

  // ── Favorites ────────────────────────────────────────────────────
  String get noFavoritesYet => _('noFavoritesYet', 'Hələ sevimli yoxdur');
  String get noFavoritesHint => _('noFavoritesHint',
      'Bəyəndiyin biznesin profilində ürək işarəsinə toxun — burada toplansın.');

  // ── Map picker ───────────────────────────────────────────────────
  String get pickLocationTitle => _('pickLocationTitle', 'Yeri seç');
  String get mapTapHint => _('mapTapHint',
      'Xəritəyə toxunaraq biznesinin yerini işarələ. Enlik/uzunluq avtomatik doldurulacaq.');
  String get confirmThisLocation =>
      _('confirmThisLocation', 'Bu yeri təsdiqlə');

  // ── Business account ─────────────────────────────────────────────
  String get passwordLabel => _('passwordLabel', 'Parol');
  String get businessFallback => _('businessFallback', 'Biznes');

  // ── Customers list / detail ──────────────────────────────────────
  String get searchCustomer => _('searchCustomer', 'Müştəri axtar');
  String get visitsWord => _('visitsWord', 'ziyarət');
  String get lastVisit => _('lastVisit', 'son ziyarət');
  String get stampWord => _('stampWord', 'möhür');
  String get rewardWord => _('rewardWord', 'hədiyyə');
  String get customerTitle => _('customerTitle', 'Müştəri');
  String get recentPurchases => _('recentPurchases', 'Son alış-verişlər');
  String get noActivityYet => _('noActivityYet', 'Hələ hərəkət yoxdur');
  String get activityWillShow =>
      _('activityWillShow', 'Möhür vurulan kimi burada görünəcək.');
  String get callAction => _('callAction', 'Zəng et');
  String get memberSinceLabel => _('memberSinceLabel', 'Müştəri');
  String get totalStampsLabel => _('totalStampsLabel', 'Cəm möhür');
  String get earnedRewards => _('earnedRewards', 'Qazanılmış');
  String get readyReward => _('readyReward', 'Hazır mükafat');
  String get visitWord => _('visitWord', 'Ziyarət');
  String get readyWord => _('readyWord', 'hazır');
  String get rewardGained => _('rewardGained', 'Mükafat qazandı');
  String get stampAdded => _('stampAdded', 'Möhür əlavə olundu');

  // ── Manage programs ──────────────────────────────────────────────
  String get noBusinessProfile =>
      _('noBusinessProfile', 'Biznes profili yoxdur');
  String get createFirstOffer =>
      _('createFirstOffer', 'İlk təklifini yarat və müştəriləri qaytar.');
  String get deleteProgramTitle => _('deleteProgramTitle', 'Proqramı silək?');
  String get programCreated => _('programCreated', 'Proqram yaradıldı');
  String get programUpdated => _('programUpdated', 'Proqram yeniləndi');
  String get newLoyaltyProgram =>
      _('newLoyaltyProgram', 'Yeni sadiqlik proqramı');
  String get editProgram => _('editProgram', 'Proqramı düzəliş et');
  String get threeSimpleSteps => _('threeSimpleSteps',
      'Üç sadə addım — müştəri neçə möhürdən sonra nə qazanır.');
  String get whatCustomerEarns => _('whatCustomerEarns', 'Müştəri nə qazanır?');
  String get discountPercentLabel =>
      _('discountPercentLabel', 'Endirim faizi (%)');
  String get amountManatLabel => _('amountManatLabel', 'Məbləğ (₼)');
  String get egFifty => _('egFifty', 'Məs: 50');
  String get egFive => _('egFive', 'Məs: 5');
  String get validNumber => _('validNumber', 'Düzgün rəqəm daxil et');
  String get range0to100 => _('range0to100', '0–100 arası olmalıdır');
  String get whichProduct => _('whichProduct', 'Hansı məhsul üçün?');
  String get productExampleHint =>
      _('productExampleHint', 'Məs: qəhvə, burger, manikür');
  String get enterProduct => _('enterProduct', 'Məhsulu yaz');
  String get howManyStamps => _('howManyStamps', 'Neçə möhür lazımdır?');
  String get nameYourProgram => _('nameYourProgram', 'Proqrama ad ver');
  String get programNameLabel => _('programNameLabel', 'Proqram adı');
  String get programNameHint => _('programNameHint', 'Məs: 5 al, 6-cı pulsuz');
  String get descriptionOptional =>
      _('descriptionOptional', 'Açıqlama (istəyə bağlı)');
  String get descriptionShortHint =>
      _('descriptionShortHint', 'Müştərinin görəcəyi qısa təsvir');
  String get enterName2 => _('enterName2', 'Adı yaz');
  String get createAction => _('createAction', 'Yarat');
  String get previewWord => _('previewWord', 'Önbaxış');
  String get newProgramPlaceholder =>
      _('newProgramPlaceholder', 'Yeni proqram');

  // ── Reward catalog ───────────────────────────────────────────────
  String get addReward => _('addReward', 'Mükafat əlavə et');
  String get rewardNameHint => _('rewardNameHint', 'Ad — məs. San Sebastian');
  String get descOptionalHint =>
      _('descOptionalHint', 'Açıqlama (istəyə bağlı)');
  String get howManyCoinHint => _('howManyCoinHint', 'Neçə coin');
  String get nameAndValidCoin =>
      _('nameAndValidCoin', 'Ad və düzgün coin məbləği yaz');
  String get coinGiftsSub => _(
      'coinGiftsSub', 'Coinlə alınan hədiyyələr (möhür proqramlarından ayrı).');
  String get noRewardsYetHint => _('noRewardsYetHint',
      'Hələ mükafat yoxdur. "Əlavə et" ilə yarat — məs. 100 coin = 1 porsiya San Sebastian.');

  // ── Admin users / businesses ─────────────────────────────────────
  String get usersTitle => _('usersTitle', 'İstifadəçilər');
  String get businessesTitle => _('businessesTitle', 'Bizneslər');
  String get searchBusinessName => _('searchBusinessName', 'Biznes adı axtar');
  String get searchTryAgain =>
      _('searchTryAgain', 'Axtarışı dəyişib yenidən cəhd et.');
  String get reviewWord => _('reviewWord', 'rəy');
  String get featuredLabel => _('featuredLabel', 'Seçilmiş');
  String get failedColon => _('failedColon', 'Alınmadı');

  // ── Admin notifications ──────────────────────────────────────────
  String get titleAndBodyRequired =>
      _('titleAndBodyRequired', 'Başlıq və mətn yaz');
  String get notifSentToAll =>
      _('notifSentToAll', 'Bildiriş hər kəsə göndərildi ✓');
  String get sendNotification => _('sendNotification', 'Bildiriş göndər');
  String get notifReachAll => _('notifReachAll',
      'Bütün istifadəçilərə çatacaq və onların bildiriş qutusunda görünəcək.');
  String get titleLabel => _('titleLabel', 'Başlıq');
  String get bodyLabel => _('bodyLabel', 'Mətn');
  String get sendingWord => _('sendingWord', 'Göndərilir...');
  String get sendToAll => _('sendToAll', 'Hamısına göndər');
  String get sentItems => _('sentItems', 'Göndərilənlər');
  String get noNotifSent => _('noNotifSent', 'Hələ bildiriş göndərilməyib.');

  // ── Admin coins ──────────────────────────────────────────────────
  String get coinAdjustment => _('coinAdjustment', 'Coin düzəlişi');
  String get coinControl => _('coinControl', 'Coin nəzarəti');
  String get recentTransactions => _('recentTransactions', 'Son əməliyyatlar');
  String get noTransactions => _('noTransactions', 'Əməliyyat yoxdur');
  String get transactionsWillShow =>
      _('transactionsWillShow', 'Coin hərəkətləri burada görünəcək.');
  String get inCirculation => _('inCirculation', 'Dövriyyədə');
  String get transactionWord => _('transactionWord', 'Əməliyyat');
  String get unknownParen => _('unknownParen', '(naməlum)');
  String get adjustPositiveNegative => _('adjustPositiveNegative',
      'Müsbət məbləğ əlavə edir, mənfi məbləğ silir.');
  String get pickUserAndAmount =>
      _('pickUserAndAmount', 'İstifadəçi seç və sıfırdan fərqli məbləğ yaz.');
  String get searchUserByEmail =>
      _('searchUserByEmail', 'İstifadəçini e-poçt ilə tap');
  String get amountExample =>
      _('amountExample', 'Məbləğ (məs. 500 və ya -200)');
  String get noteOptional => _('noteOptional', 'Qeyd (istəyə bağlı)');
  String get applyingWord => _('applyingWord', 'Tətbiq olunur...');
  String get applyAction => _('applyAction', 'Tətbiq et');

  // ── Admin dashboard extras ───────────────────────────────────────
  String get usersLabel => _('usersLabel', 'İstifadəçi');
  String get businessLabel => _('businessLabel', 'Biznes');

  // ── Admin promotions ─────────────────────────────────────────────
  String get newAd => _('newAd', 'Yeni reklam');
  String get noAdsYet => _('noAdsYet', 'Hələ reklam yoxdur');
  String get createFirstBanner =>
      _('createFirstBanner', '"Yeni reklam" ilə ilk banneri yarat.');
  String get deleteAdTitle => _('deleteAdTitle', 'Reklamı sil?');
  String get willBeDeletedSuffix => _('willBeDeletedSuffix', 'silinəcək.');
  String get deleteFailed => _('deleteFailed', 'Silinmədi');
  String get activeWord => _('activeWord', 'Aktiv');
  String get inactiveWord => _('inactiveWord', 'Deaktiv');
  String get tagAndTitleRequired =>
      _('tagAndTitleRequired', 'Etiket və başlıq mütləqdir');
  String get editAd => _('editAd', 'Reklamı düzəliş et');
  String get tagLabel => _('tagLabel', 'Etiket');
  String get tagHint => _('tagHint', 'məs. YENİ, ENDİRİM');
  String get subtitleLabel => _('subtitleLabel', 'Alt yazı');
  String get emojiLabel => _('emojiLabel', 'Emoji');
  String get buttonTextLabel => _('buttonTextLabel', 'Düymə mətni');
  String get colorLabel => _('colorLabel', 'Rəng');
  String get savingWord => _('savingWord', 'Saxlanılır...');
  String get titleFallback => _('titleFallback', 'Başlıq');

  // ── Admin menus ──────────────────────────────────────────────────
  String get addFood => _('addFood', 'Yemək əlavə et');
  String get selectBusiness => _('selectBusiness', 'Biznes seç');
  String get menuLinkSaved =>
      _('menuLinkSaved', 'Menyu linki yadda saxlanıldı ✓');
  String get menuLinkDesc => _('menuLinkDesc',
      'PDF / sayt / şəkil linki. Struktur menyu yoxdursa bu göstərilir.');
  String get saveShort => _('saveShort', 'Saxla');
  String get structuredMenu =>
      _('structuredMenu', 'Struktur menyu (kateqoriyalar)');
  String get noFoodYet => _('noFoodYet',
      'Hələ yemək yoxdur. "Yemək əlavə et" ilə kateqoriyalı menyu yığ (məs. "Qəhvələr", "Şirniyyatlar").');
  String get categoryAndNameRequired =>
      _('categoryAndNameRequired', 'Kateqoriya və ad mütləqdir');
  String get categoryLabel => _('categoryLabel', 'Kateqoriya');
  String get categoryHint => _('categoryHint', 'məs. Qəhvələr, Əsas yeməklər');
  String get descriptionOptionalField =>
      _('descriptionOptionalField', 'Təsvir (istəyə bağlı)');
  String get priceOptional => _('priceOptional', 'Qiymət (₼, istəyə bağlı)');

  // ── My cards ─────────────────────────────────────────────────────
  String get discoverCardHint => _('discoverCardHint',
      'Kəşf et səhifəsindən sevimli yerini tap və kartını al.');
  String get coinBalanceNotLoaded =>
      _('coinBalanceNotLoaded', 'Coin balansı yüklənmədi');
  String get myCoinBalance => _('myCoinBalance', 'Coin balansım');

  // ── QR scanner ───────────────────────────────────────────────────
  String get myQrTitle => _('myQrTitle', 'QR kodum');
  String get showThisCodeHint => _('showThisCodeHint',
      'Bu kodu obyektə göstər — möhürün avtomatik əlavə olunacaq.');
  String get scanQr => _('scanQr', 'QR-i skan et');
  String get holdCustomerQr =>
      _('holdCustomerQr', 'Müştərinin QR kodunu çərçivəyə tut');
  String get autoDetected => _('autoDetected', 'Avtomatik tanınacaq');
  String get createBusinessFirst =>
      _('createBusinessFirst', 'Skan etmək üçün əvvəlcə biznesini yarat.');
  String get customerFound => _('customerFound', 'Müştəri tapıldı');
  String get activeRewards => _('activeRewards', 'Aktiv hədiyyələr');
  String get giveStamp => _('giveStamp', 'Möhür ver');
  String get giveCoin => _('giveCoin', 'Coin ver');
  String get stampRewardLabel => _('stampRewardLabel', 'Möhür mükafatı');
  String get useAction => _('useAction', 'İstifadə et');
  String get howManyCoinQ => _('howManyCoinQ', 'Neçə coin?');
  String get amountWord => _('amountWord', 'Məbləğ');
  String get giveAction => _('giveAction', 'Ver');
  String get stampWordShort => _('stampWordShort', 'möhür');
  String get rewardsWaitSuffix =>
      _('rewardsWaitSuffix', 'mükafat səni gözləyir!');
  String get catCoffee => _('catCoffee', 'Kafe & Qəhvəxana');
  String get catCoffeeShort => _('catCoffeeShort', 'Kafe');
  String get catRestaurant => _('catRestaurant', 'Restoran');
  String get catBeauty => _('catBeauty', 'Gözəllik');
  String get catBarber => _('catBarber', 'Bərbər');
  String get catCarwash => _('catCarwash', 'Avtoyuma');
  String get catFitness => _('catFitness', 'Fitness');
  String get catBakery => _('catBakery', 'Şirniyyat');
  String get catOther => _('catOther', 'Digər');
  String get scanTapHint =>
      _('scanTapHint', 'Bir toxunuş — möhür avtomatik əlavə olunur.');
  String get firstCustomerHint => _('firstCustomerHint',
      'Kartı ilk dəfə müştərinin telefonuna toxundurduğun an o, burada görünəcək.');
  String get daysLeftSuffix => _('daysLeftSuffix', 'gün qalıb');
  String get hoursLeftSuffix => _('hoursLeftSuffix', 'saat qalıb');
  String get minsLeftSuffix => _('minsLeftSuffix', 'dəq qalıb');
  String get rewardFreeItem => _('rewardFreeItem', 'Pulsuz məhsul');
  String get rewardPercentDiscount =>
      _('rewardPercentDiscount', 'Faiz endirim');
  String get rewardFixedDiscount => _('rewardFixedDiscount', 'Sabit endirim');
  String get rewardCashback => _('rewardCashback', 'Cashback');
  String get freeWord => _('freeWord', 'pulsuz');
  String get onWord => _('onWord', 'üzrə');
  String get discountWord => _('discountWord', 'endirim');
  String get productFallback => _('productFallback', 'məhsul');
  String get onbTitle1 => _('onbTitle1', 'Sevdiyin yerlərdən qazan');
  String get onbSub1 => _('onbSub1',
      'Kafeləri, restoranları, salonları kəşf et — hər ziyarət sənə bonus gətirsin.');
  String get onbTitle2 => _('onbTitle2', 'Kartı telefona toxundur');
  String get onbSub2 => _(
      'onbSub2', 'Kassir kartı telefonuna toxundurur — möhür və xal avtomatik yazılır.');
  String get onbTitle3 => _('onbTitle3', 'Mükafatları topla');
  String get onbSub3 => _('onbSub3',
      '6-cı qəhvə sənindir — sənin üçün hazırlanmış xüsusi təkliflərlə qazan.');
  String get getStarted => _('getStarted', 'Başlayaq');
  String get continueAction => _('continueAction', 'Davam et');
  String get coinGivenSuffix => _('coinGivenSuffix', 'coin müştəriyə verildi');
  String get usedSuffixCheck => _('usedSuffixCheck', 'istifadə olundu ✓');
  String get scanBonusNote => _('scanBonusNote', 'Skan bonusu');

  // ── Story viewer ─────────────────────────────────────────────────
  String get noStories => _('noStories', 'Hekayə yoxdur');

  // ── Profile screen extras ────────────────────────────────────────
  String get signOutBody => _('signOutBody',
      'Hesabından çıxacaqsan. Yenidən daxil olaraq qayıda bilərsən.');
  String get deleteAccountTitle =>
      _('deleteAccountTitle', 'Hesabı silmək istəyirsən?');
  String get deleteAccountBody => _('deleteAccountBody',
      'Bu, hesabını həmişəlik silir. Profil məlumatların silinəcək və bu əməliyyat geri qaytarıla bilməz.\n\nQazandığın coinlər və kartlar da əlçatmaz olacaq.');
  String get accountDeleteFailed => _('accountDeleteFailed', 'Hesab silinmədi');
  String get phoneWord => _('phoneWord', 'Telefon');
  String get whatsappSub => _('whatsappSub', 'Mesaj yaz — 5 dəqiqəyə cavab');
  String get aboutBody => _('aboutBody',
      'Sadiqlik və müştəri izləmə platforması — kafelər, restoranlar, salonlar üçün.');
  String get allRightsReserved =>
      _('allRightsReserved', '© 2026 Qazan. Bütün hüquqlar qorunur.');
  String get notifActiveSuffix => _('notifActiveSuffix', 'aktiv');

  // ── My rewards ───────────────────────────────────────────────────
  String get rewardsActiveTab => _('rewardsActiveTab', 'Aktiv');
  String get rewardsUsedTab => _('rewardsUsedTab', 'İstifadə olunmuş');
  String get noActiveRewards =>
      _('noActiveRewards', 'Hələ aktiv hədiyyən yoxdur');
  String get noActiveRewardsSub => _('noActiveRewardsSub',
      'İşlətmə səhifəsində coinlə hədiyyə al və ya möhür kartını tamamla.');
  String get noUsageHistory =>
      _('noUsageHistory', 'Hələ istifadə tarixçəsi yoxdur');
  String get noUsageHistorySub => _('noUsageHistorySub',
      'Kassada istifadə etdiyin hədiyyələr burada görünəcək.');
  String get coinLabel => _('coinLabel', 'Coin');
  String get stampLabel => _('stampLabel', 'Möhür');
  String get showQrCashier =>
      _('showQrCashier', 'Kassada təhvil al');
  String get usedPrefix => _('usedPrefix', 'İstifadə olunub');
  String get nowWord => _('nowWord', 'indi');
  String get minAgo => _('minAgo', 'dəq əvvəl');
  String get hourAgo => _('hourAgo', 'saat əvvəl');
  String get dayAgo => _('dayAgo', 'gün əvvəl');

  // ── Notifications inbox ──────────────────────────────────────────
  String get noNotifications => _('noNotifications', 'Bildiriş yoxdur');
  String get newNotifsHere =>
      _('newNotifsHere', 'Yeni bildirişlər burada görünəcək.');

  // ── Company detail ───────────────────────────────────────────────
  String get menuWord => _('menuWord', 'Menyu');
  String get fullMenu => _('fullMenu', 'Tam menyu');
  String get showQr => _('showQr', 'QR göstər');
  String get campaigns => _('campaigns', 'Kampaniyalar');
  String get noCampaignYet => _('noCampaignYet', 'Hələ kampaniya yoxdur');
  String get campaignComingSoon =>
      _('campaignComingSoon', 'Bu obyekt tezliklə təklif əlavə edəcək.');
  String get joinCampaign => _('joinCampaign', 'Kampaniyaya qoşul');
  String get buyWithCoin => _('buyWithCoin', 'Coinlə al');
  String get buyWithCoinHint => _('buyWithCoinHint',
      '"Al" toxun — coin çıxılır, hədiyyə Hədiyyələrim-ə əlavə olunur. Sonra kassada təhvil alırsan.');
  String get buyAction => _('buyAction', 'Al');
  String get insufficientWord => _('insufficientWord', 'Çatmır');
  String get mAway => _('mAway', 'm uzaqda');
  String get kmAway => _('kmAway', 'km uzaqda');
  String get errorOccurred => _('errorOccurred', 'Xəta baş verdi');

  // ── Discover ─────────────────────────────────────────────────────
  String get helloName => _('helloName', 'Salam');
  String get whereEarnToday => _('whereEarnToday', 'Bu gün hardan qazanaq?');
  String get friendFallback => _('friendFallback', 'Dost');
  String get allPlaces => _('allPlaces', 'Bütün yerlər');
  String get nothingFoundHint =>
      _('nothingFoundHint', 'Filtri dəyişməyi və ya başqa söz axtarmağı sına.');

  // ── Location map ─────────────────────────────────────────────────
  String get directions => _('directions', 'Yol göstər');

  // ── Reviews ──────────────────────────────────────────────────────
  String get reviewsNotLoaded => _('reviewsNotLoaded', 'Rəylər yüklənmədi');
  String get reviewsWord => _('reviewsWord', 'Rəylər');
  String get noReviewsYet =>
      _('noReviewsYet', 'Hələ rəy yoxdur. İlk rəyi sən yaz!');
  String get writeReview => _('writeReview', 'Rəy yaz');
  String get editReview => _('editReview', 'Rəyini dəyiş');
  String get youParen => _('youParen', 'sən');
  String get rateExperience => _('rateExperience', 'Təcrübəni qiymətləndir');
  String get reviewHint => _('reviewHint', 'Rəyin (istəyə bağlı)…');
  String get sendAction => _('sendAction', 'Göndər');
  String get reviewThanks => _('reviewThanks', 'Rəyin üçün təşəkkürlər ✓');
  String get atLeastOneStar => _('atLeastOneStar', 'Ən azı 1 ulduz seç');

  static const Map<String, Map<String, String>> _all =
      <String, Map<String, String>>{
    'en': <String, String>{
      'whoAreYou': 'Who are you?',
      'whoAreYouSub':
          'Pick your role to create an account. You can change it any time.',
      'iAmCustomer': "I'm a customer",
      'iAmBusiness': "I'm a business",
      'customerHint': 'Collect rewards from my favorite places',
      'businessHint': 'Track customers and run loyalty programs',
      'login': 'Sign in',
      'register': 'Sign up',
      'email': 'Email',
      'password': 'Password',
      'fullName': 'Full name',
      'phone': 'Phone number',
      'forgotPassword': 'Forgot your password?',
      'noAccount': "Don't have an account?",
      'haveAccount': 'Already have an account?',
      'welcome': 'Welcome',
      'createAccount': 'Create account',
      'tabHome': 'Discover',
      'tabCompanies': 'Places',
      'tabCards': 'My cards',
      'tabProfile': 'Profile',
      'tabRewards': 'Rewards',
      'tabDashboard': 'Dashboard',
      'tabCustomers': 'Customers',
      'tabScan': 'Scan',
      'tabPrograms': 'Programs',
      'tabMyBusiness': 'Business',
      'tabPanel': 'Panel',
      'tabUsers': 'Users',
      'tabBusinesses': 'Businesses',
      'tabCoins': 'Coins',
      'tabNotify': 'Notify',
      'save': 'Save',
      'cancel': 'Cancel',
      'close': 'Close',
      'logout': 'Sign out',
      'stay': 'Stay',
      'all': 'All',
      'seeAll': 'See all',
      'edit': 'Edit',
      'search': 'Search...',
      'logoutTitle': 'Sign out?',
      'profile': 'Profile',
      'account': 'Account',
      'help': 'Help',
      'editProfile': 'Edit profile',
      'security': 'Security',
      'language': 'Language',
      'appearance': 'Appearance',
      'notifications': 'Notifications',
      'guest': 'Guest',
      'nameAndPhone': 'Name, phone',
      'favorites': 'Favorites',
      'faq': 'FAQ',
      'contactSupport': 'Contact support',
      'aboutApp': 'About the app',
      'deleteAccount': 'Delete account',
      'activeCard': 'Active cards',
      'rewardsEarned': 'Rewards earned',
      'hello': 'Hi,',
      'activeCustomers': 'Active customers',
      'stampsToday': 'Stamps today',
      'rewardsWeek': 'Rewards / week',
      'returnRate': 'Return rate',
      'recentCustomers': 'Recent customers',
      'scanCustomerQr': "Scan the customer's QR",
      'noCustomersYet': 'No customers yet',
      'myBusiness': 'My business',
      'writeNotification': 'Message your customers',
      'myCards': 'My cards',
      'loyaltyCards': 'Loyalty cards',
      'noCardsYet': "You don't have cards yet",
      'rewardsActive': 'Active',
      'rewardsUsed': 'Used',
      'loyaltyPrograms': 'Loyalty programs',
      'stampPrograms': 'Stamp programs',
      'newProgram': 'New program',
      'noProgramsYet': 'No programs yet',
      'rewardCatalog': 'Reward catalog',
      'add': 'Add',
      'delete': 'Delete',
      'error': 'Error',
      'retry': 'Try again',
      'nothingFound': 'Nothing found',
      'comingSoon': 'Coming soon',
      'notLoaded': 'Failed to load',
      'notFound': 'Not found',
      'loading': 'Loading...',
      'loadMore': 'Load more',
      'failed': 'Failed',
      'cardAddedSuffix': 'card added',
      'purchasedSeeGifts': 'purchased — see in My Gifts',
      'shareOnMap': 'On the map',
      'shareDiscover': 'Discover it on Qazan',
      'enter': 'Enter it',
      'done': 'Done',
      'profileUpdated': 'Profile updated',
      'emailReadOnly': 'Email (cannot be changed)',
      'enterName': 'Enter your name',
      'changePassword': 'Change password',
      'passwordUpdated': 'Password updated ✓',
      'currentPassword': 'Current password',
      'newPassword': 'New password',
      'repeatNewPassword': 'Repeat new password',
      'min8Chars': 'Use 8+ characters',
      'passwordsDontMatch': "Passwords don't match",
      'notifWhichEvents': 'Which events do you want to hear about?',
      'notifNewReward': 'New reward',
      'notifNewRewardSub': 'Notify me the moment a card is completed',
      'notifNearby': 'Nearby offers',
      'notifNearbySub': 'Alert me when a new promo starts at your places',
      'notifWeekly': 'Weekly recap',
      'notifWeeklySub': 'Send how much I earned every Sunday',
      'notifMarketing': 'Marketing & promotions',
      'notifMarketingSub': 'New businesses and special campaigns',
      'faqQ1': 'How do I earn a stamp?',
      'faqA1':
          'When you pay, the cashier taps the venue card on your phone and the stamp lands instantly.',
      'faqQ2': 'How do I claim a reward?',
      'faqA2':
          'When a card is full you\'ll see a notice in "My cards". Collect the reward at the counter on your next visit.',
      'faqQ3': 'Can I have more than one card?',
      'faqA3':
          'Yes! Every place has its own card. You can even collect separate cards for a place\'s different programs.',
      'faqQ4': 'Who can see my customer data?',
      'faqA4':
          'Only the places where you opened a card can see you — and only your stamps and visit count with them.',
      'faqQ5': 'Do rewards expire?',
      'faqA5':
          'Some programs have an expiry date. You can see the details on the card\'s detail page.',
      'faqQ6': 'Will I lose my cards if I change my phone?',
      'faqA6':
          'No. When you sign back into your account, all your cards and stamp history are restored.',
      'themeLight': 'Light',
      'themeLightSub': 'Always use the light theme',
      'themeDark': 'Dark',
      'themeDarkSub': 'Always use the dark theme',
      'themeSystem': 'System',
      'themeSystemSub': 'Follow the device setting',
      'languageNote': 'Note: localization will soon reach every screen.',
      'businessProfileUpdated': 'Business profile updated ✓',
      'photoNotPicked': 'No image picked',
      'photosSaved': 'Photos saved ✓',
      'photoNotUploaded': 'Image upload failed',
      'logoUpdated': 'Profile photo updated ✓',
      'logoNotUploaded': 'Logo upload failed',
      'signOutBusinessBody':
          'You\'ll sign out of your business account. Sign in again to return.',
      'sectionProfilePhoto': 'Profile photo',
      'logoHint':
          'This image appears on the customer home page. Upload a square / logo image.',
      'uploadLogo': 'Upload logo',
      'change': 'Change',
      'sectionBasicInfo': 'Basic info',
      'name': 'Name',
      'taglineLabel': 'Slogan / short description',
      'category': 'Category',
      'sectionContactHours': 'Contact & hours',
      'address': 'Address',
      'workingHours': 'Working hours',
      'workingHoursHint': 'e.g. 09:00 – 23:00',
      'openNow': 'Open',
      'closedNow': 'Closed',
      'collectPoints': 'Collect points',
      'nfcTitle': 'Tap the card',
      'nfcHoldPhone': 'Hold your phone to the card at the counter',
      'nfcHoldPhoneBody': 'Ask the cashier to touch the stamp or points card to the back of your phone.',
      'nfcShowQrInstead': 'Show QR',
      'nfcUnsupported': 'This phone has no NFC',
      'nfcUnsupportedBody': 'Ask the cashier to add your stamps and points manually.',
      'nfcDisabled': 'NFC is off',
      'nfcDisabledBody': 'Turn NFC on in your phone settings and try again.',
      'nfcRetry': 'Try again',
      'nfcFailed': 'Did not work',
      'nfcAgain': 'Tap again',
      'nfcNotOurCard': 'This is not a Qazan card.',
      'nfcOfflineQueued': 'No connection — the tap was saved and will be sent later.',
      'nfcQueuedSent': '{n} offline taps sent',
      'nfcCards': 'NFC cards',
      'nfcTapLog': 'Taps',
      'nfcWriteCard': 'Write to card',
      'nfcWriteHold': 'Hold a blank card to the back of your phone',
      'nfcWritten': 'Card written',
      'nfcNewCard': 'New card',
      'nfcKindStamp': 'Stamp card',
      'nfcKindPoints': 'Points card',
      'nfcPointsPerTap': 'Points per tap',
      'nfcCooldown': 'Cooldown (sec)',
      'nfcDailyCap': 'Daily limit (per customer)',
      'nfcBlock': 'Block',
      'nfcUnblock': 'Unblock',
      'nfcRotate': 'New code',
      'nfcSuspiciousOnly': 'Suspicious',
      'nfcTapShort': 'Tap card',
      'loginSub': 'Sign in with your account — customer or business.',
      'countryLabel': 'Country',
      'currencyLabel': 'Currency',
      'roleCustomer2': 'Customer',
      'roleBusiness2': 'Business',
      'pendingRewards': 'Pending rewards',
      'noPendingRewards': 'Nothing waiting',
      'noPendingRewardsHint': 'Rewards show up here when a customer completes a card or buys one with coins.',
      'rewardHandOver': 'Mark used',
      'rewardHandOverTitle': 'Mark this gift as used?',
      'onbTitle2': 'Tap the card to your phone',
      'nfcCardsTrailing': 'Stamp and points cards',
      'nfcNoCardsBusiness': 'No cards issued yet — contact the admin.',
      'nfcNotWritten': 'Not written to a tag',
      'nfcNotWritable': 'This tag cannot be written (locked or unsupported).',
      'nfcWrittenBody': 'Hand the card to the counter. It can now be tapped on customer phones.',
      'nfcCooldownHelp': 'How often the same customer may tap this card.',
      'menuOwnerHint':
          'Add a menu so customers can see what you offer and your prices.',
      'menuDeleteBody': 'This item will be removed from the menu.',
      'deleteReviewTitle': 'Delete review?',
      'lowRatingsOnly': '1–2 stars',
      'myBusinessSection': 'My business',
      'menuOwnerTrailing': 'Items, prices',
      'reviewsOwnerTrailing': 'Customer reviews',
      'adImageLabel': 'Background photo',
      'adImageHint': 'Leave empty to use the venue cover photo.',
      'uploadPhoto': 'Upload photo',
      'reviewLockedHint':
          'Earn a stamp or coins at this place to leave a review.',
      'rewardReadyTitle': 'Your reward is ready!',
      'rewardReadyBody':
          'You completed your card. Collect the reward at the counter.',
      'useReward': 'Use it',
      'moreCampaigns': '+{n} more offers',
      'moreCampaignsShort': '+{n} offers',
      'instagramHint': '@handle',
      'sectionLocationMap': 'Location (map)',
      'pickOnMap': 'Pick on map',
      'latitude': 'Latitude (lat)',
      'longitude': 'Longitude (lng)',
      'sectionAmenities': 'Amenities',
      'amWifi': 'Wifi',
      'amWorkspace': 'Workspace',
      'amMeeting': 'Meeting',
      'amGarden': 'Garden',
      'amParking': 'Parking',
      'amVegan': 'Vegan',
      'amPet': 'Pet',
      'sectionPhotoMenu': 'Photos & menu',
      'businessPhotosHint':
          'Business photos — upload from your phone/computer (shown on the profile and search pages).',
      'menuLink': 'Menu link',
      'menuLinkHint': 'https://... (PDF / site / image)',
      'sectionCoinSystem': 'Coin system',
      'coinRate': 'Coin rate (how many coins per 1 ₼)',
      'coinRateHint': 'e.g. 0.1  → 1000 ₼ = 100 coins',
      'coinRateNote':
          'When the cashier scans, they enter the receipt total — coins are calculated automatically. The reward catalog is under "Programs".',
      'translationsOptional': 'Translations (optional)',
      'translationsHint': 'You can fill the name and slogan in EN / RU / TR.',
      'nameEn': 'Name (EN)',
      'taglineEn': 'Slogan (EN)',
      'nameRu': 'Name (RU)',
      'taglineRu': 'Slogan (RU)',
      'nameTr': 'Name (TR)',
      'taglineTr': 'Slogan (TR)',
      'createYourBusiness': 'Create your business',
      'createBusinessHint':
          'This account has no business yet. Fill in the fields below — then you can add photos, a menu, amenities and more.',
      'businessName': 'Business name',
      'createBusiness': 'Create business',
      'enterBusinessName': 'Enter the business name (at least 2 letters)',
      'businessCreated': 'Business created ✓ Now complete the profile',
      'addPhoto': 'Add photo',
      'qazanAdmin': 'Qazan Admin',
      'platformPanel': 'Platform panel',
      'signOutAdminBody': 'You\'ll sign out of your admin account.',
      'noData': 'No data',
      'statsUnavailable': 'Statistics are unavailable.',
      'promotions': 'Ads',
      'menus': 'Menus',
      'adminUser': 'Users',
      'adminBusiness': 'Businesses',
      'loyaltyCard': 'Loyalty cards',
      'coinTransaction': 'Coin transactions',
      'coinCirculation': 'Coins in circulation',
      'currentBalanceCoin': 'current balance (coins)',
      'earnedLabel': 'Earned',
      'spentLabel': 'Spent',
      'recentSignups': 'Recent signups',
      'noUsersYet': 'No users yet',
      'signupsHere': 'Signups will appear here.',
      'recentBusinesses': 'Recent businesses',
      'noBusinessesYet': 'No businesses yet',
      'newBusinessesHere': 'New businesses will appear here.',
      'roleCustomer': 'Customer',
      'roleBusiness': 'Business',
      'roleAdmin': 'Admin',
      'unnamed': '(unnamed)',
      'searchNameEmail': 'Search name or email',
      'filterTryAgain': 'Change the filter and try again.',
      'assignRole': 'Assign role',
      'blockUser': 'Block user',
      'activateUser': 'Activate user',
      'userBlocked': 'blocked',
      'userActivated': 'activated',
      'promoteBusiness': 'Set up your business',
      'registerBusinessSub': 'Your business profile is being prepared.',
      'registerCustomerSub': 'Join in a minute and earn your first stamp.',
      'businessNameHint': 'e.g. Qazan Coffee',
      'fullNameHint': 'e.g. Ali Mammadov',
      'emailHint': 'you@qazan.az',
      'enterNameShort': 'Enter your name',
      'invalidEmail': 'Enter a valid email',
      'passwordHintMin8': 'at least 8 characters',
      'registrationFailed': 'Sign-up failed',
      'birthDateOptional': 'Date of birth (optional)',
      'pickDate': 'Pick a date',
      'pickBirthDate': 'Pick your date of birth',
      'selectAction': 'Select',
      'phoneNumberInvalid': 'Phone number is invalid',
      'pwRuleMin8': 'At least 8 characters',
      'pwRuleLetter': 'At least one letter',
      'pwRuleDigit': 'At least one digit',
      'pwErrMin8': 'At least 8 characters',
      'pwErrLetter': 'Must contain at least one letter',
      'pwErrDigit': 'Must contain at least one digit',
      'skip': 'Skip',
      'loginBusinessSub':
          'Sign in to your business account and track your customers.',
      'loginCustomerSub': 'Sign in and earn from your favorite places.',
      'loginFailed': 'Sign-in failed',
      'passwordShort': 'Password is too short',
      'resetPassword': 'Reset password',
      'resetPasswordEmailPrompt':
          "Enter your account email — we'll send you a 6-digit code.",
      'codeSentToEmail':
          "A code was sent to your email. If it doesn't arrive, check spam.",
      'errorTryAgain': 'Something went wrong. Try again shortly.',
      'newPasswordReady': 'You can now sign in with your new password.',
      'codeSentPrompt': 'enter the code sent to it and your new password.',
      'sendCode': 'Send code',
      'resendCode': 'Resend code',
      'confirmationCode': 'Confirmation code',
      'sixDigits': '6 digits',
      'enterSixDigitCode': 'Enter the 6-digit code',
      'eightPlusChars': '8+ characters',
      'updatePasswordAction': 'Update password',
      'noFavoritesYet': 'No favorites yet',
      'noFavoritesHint':
          "Tap the heart on a business you like — it'll collect here.",
      'pickLocationTitle': 'Pick a location',
      'mapTapHint':
          'Tap the map to mark your business location. Latitude/longitude will fill automatically.',
      'confirmThisLocation': 'Confirm this location',
      'passwordLabel': 'Password',
      'businessFallback': 'Business',
      'searchCustomer': 'Search customer',
      'visitsWord': 'visits',
      'lastVisit': 'last visit',
      'stampWord': 'stamps',
      'rewardWord': 'gifts',
      'customerTitle': 'Customer',
      'recentPurchases': 'Recent purchases',
      'noActivityYet': 'No activity yet',
      'activityWillShow': 'It will appear here once a stamp is added.',
      'callAction': 'Call',
      'totalStampsLabel': 'Total stamps',
      'earnedRewards': 'Earned',
      'readyReward': 'Ready reward',
      'visitWord': 'Visits',
      'readyWord': 'ready',
      'rewardGained': 'Earned a reward',
      'stampAdded': 'Stamp added',
      'noBusinessProfile': 'No business profile',
      'createFirstOffer': 'Create your first offer and bring customers back.',
      'deleteProgramTitle': 'Delete program?',
      'programCreated': 'Program created',
      'programUpdated': 'Program updated',
      'newLoyaltyProgram': 'New loyalty program',
      'editProgram': 'Edit program',
      'threeSimpleSteps':
          'Three simple steps — after how many stamps the customer earns what.',
      'whatCustomerEarns': 'What does the customer earn?',
      'discountPercentLabel': 'Discount percent (%)',
      'amountManatLabel': 'Amount (₼)',
      'egFifty': 'e.g. 50',
      'egFive': 'e.g. 5',
      'validNumber': 'Enter a valid number',
      'range0to100': 'Must be between 0–100',
      'whichProduct': 'For which product?',
      'productExampleHint': 'e.g. coffee, burger, manicure',
      'enterProduct': 'Enter the product',
      'howManyStamps': 'How many stamps are needed?',
      'nameYourProgram': 'Name your program',
      'programNameLabel': 'Program name',
      'programNameHint': 'e.g. Buy 5, 6th free',
      'descriptionOptional': 'Description (optional)',
      'descriptionShortHint': 'A short description the customer will see',
      'enterName2': 'Enter a name',
      'createAction': 'Create',
      'previewWord': 'Preview',
      'newProgramPlaceholder': 'New program',
      'addReward': 'Add reward',
      'rewardNameHint': 'Name — e.g. San Sebastian',
      'descOptionalHint': 'Description (optional)',
      'howManyCoinHint': 'How many coins',
      'nameAndValidCoin': 'Enter a name and a valid coin amount',
      'coinGiftsSub': 'Gifts bought with coins (separate from stamp programs).',
      'noRewardsYetHint':
          'No rewards yet. Create one with "Add" — e.g. 100 coins = 1 San Sebastian.',
      'usersTitle': 'Users',
      'businessesTitle': 'Businesses',
      'searchBusinessName': 'Search business name',
      'searchTryAgain': 'Change your search and try again.',
      'reviewWord': 'reviews',
      'featuredLabel': 'Featured',
      'failedColon': 'Failed',
      'titleAndBodyRequired': 'Enter a title and body',
      'notifSentToAll': 'Notification sent to everyone ✓',
      'sendNotification': 'Send notification',
      'notifReachAll':
          "It will reach all users and appear in their notification inbox.",
      'titleLabel': 'Title',
      'bodyLabel': 'Body',
      'sendingWord': 'Sending...',
      'sendToAll': 'Send to all',
      'sentItems': 'Sent',
      'noNotifSent': 'No notifications sent yet.',
      'coinAdjustment': 'Coin adjustment',
      'coinControl': 'Coin control',
      'recentTransactions': 'Recent transactions',
      'noTransactions': 'No transactions',
      'transactionsWillShow': 'Coin movements will appear here.',
      'inCirculation': 'In circulation',
      'transactionWord': 'Transactions',
      'unknownParen': '(unknown)',
      'adjustPositiveNegative':
          'A positive amount adds coins, a negative one removes them.',
      'pickUserAndAmount': 'Pick a user and enter a non-zero amount.',
      'searchUserByEmail': 'Find a user by email',
      'amountExample': 'Amount (e.g. 500 or -200)',
      'noteOptional': 'Note (optional)',
      'applyingWord': 'Applying...',
      'applyAction': 'Apply',
      'usersLabel': 'Users',
      'businessLabel': 'Businesses',
      'newAd': 'New ad',
      'noAdsYet': 'No ads yet',
      'createFirstBanner': 'Create your first banner with "New ad".',
      'deleteAdTitle': 'Delete ad?',
      'deleteFailed': 'Delete failed',
      'activeWord': 'Active',
      'inactiveWord': 'Inactive',
      'tagAndTitleRequired': 'Tag and title are required',
      'editAd': 'Edit ad',
      'tagLabel': 'Tag',
      'tagHint': 'e.g. NEW, SALE',
      'subtitleLabel': 'Subtitle',
      'emojiLabel': 'Emoji',
      'buttonTextLabel': 'Button text',
      'colorLabel': 'Color',
      'savingWord': 'Saving...',
      'titleFallback': 'Title',
      'addFood': 'Add food',
      'selectBusiness': 'Select a business',
      'menuLinkSaved': 'Menu link saved ✓',
      'menuLinkDesc':
          'PDF / site / image link. Shown when there is no structured menu.',
      'saveShort': 'Save',
      'structuredMenu': 'Structured menu (categories)',
      'noFoodYet':
          'No food yet. Use "Add food" to build a categorized menu (e.g. "Coffees", "Desserts").',
      'categoryAndNameRequired': 'Category and name are required',
      'categoryLabel': 'Category',
      'categoryHint': 'e.g. Coffees, Mains',
      'descriptionOptionalField': 'Description (optional)',
      'priceOptional': 'Price (₼, optional)',
      'discoverCardHint':
          'Find your favorite place on Discover and grab its card.',
      'coinBalanceNotLoaded': 'Coin balance failed to load',
      'myCoinBalance': 'My coin balance',
      'scanQr': 'Scan the QR',
      'holdCustomerQr': "Hold the customer's QR in the frame",
      'autoDetected': 'Detected automatically',
      'createBusinessFirst': 'To scan, create your business first.',
      'customerFound': 'Customer found',
      'activeRewards': 'Active rewards',
      'giveStamp': 'Give a stamp',
      'giveCoin': 'Give coins',
      'stampRewardLabel': 'Stamp reward',
      'useAction': 'Use',
      'howManyCoinQ': 'How many coins?',
      'amountWord': 'Amount',
      'giveAction': 'Give',
      'noStories': 'No stories',
      'signOutBody':
          "You'll sign out of your account. Sign in again to return.",
      'deleteAccountTitle': 'Delete your account?',
      'deleteAccountBody':
          'This permanently deletes your account. Your profile data will be erased and this cannot be undone.\n\nThe coins and cards you earned will also become inaccessible.',
      'accountDeleteFailed': 'Account deletion failed',
      'phoneWord': 'Phone',
      'whatsappSub': 'Send a message — reply within 5 minutes',
      'aboutBody':
          'A loyalty and customer-tracking platform — for cafes, restaurants and salons.',
      'allRightsReserved': '© 2026 Qazan. All rights reserved.',
      'notifActiveSuffix': 'active',
      'rewardsActiveTab': 'Active',
      'rewardsUsedTab': 'Used',
      'noActiveRewards': 'No active rewards yet',
      'noActiveRewardsSub':
          'Buy a gift with coins on the business page or complete a stamp card.',
      'noUsageHistory': 'No usage history yet',
      'noUsageHistorySub': 'Gifts you use at the counter will appear here.',
      'coinLabel': 'Coin',
      'stampLabel': 'Stamp',
      'showQrCashier': 'Collect it at the counter',
      'usedPrefix': 'Used',
      'nowWord': 'now',
      'minAgo': 'min ago',
      'hourAgo': 'h ago',
      'dayAgo': 'd ago',
      'noNotifications': 'No notifications',
      'newNotifsHere': 'New notifications will appear here.',
      'menuWord': 'Menu',
      'fullMenu': 'Full menu',
      'showQr': 'Show QR',
      'campaigns': 'Campaigns',
      'noCampaignYet': 'No campaigns yet',
      'campaignComingSoon': 'This place will add offers soon.',
      'joinCampaign': 'Join the campaign',
      'buyWithCoin': 'Buy with coins',
      'buyWithCoinHint':
          'Tap "Buy" — coins are deducted and the reward lands in My rewards. Collect it at the counter.',
      'buyAction': 'Buy',
      'insufficientWord': 'Not enough',
      'mAway': 'm away',
      'kmAway': 'km away',
      'errorOccurred': 'An error occurred',
      'helloName': 'Hi',
      'whereEarnToday': 'Where shall we earn today?',
      'friendFallback': 'Friend',
      'allPlaces': 'All places',
      'nothingFoundHint': 'Try changing the filter or searching another word.',
      'directions': 'Directions',
      'reviewsNotLoaded': 'Reviews failed to load',
      'reviewsWord': 'Reviews',
      'noReviewsYet': 'No reviews yet. Be the first to write one!',
      'writeReview': 'Write a review',
      'editReview': 'Edit your review',
      'youParen': 'you',
      'rateExperience': 'Rate your experience',
      'reviewHint': 'Your review (optional)…',
      'sendAction': 'Send',
      'reviewThanks': 'Thanks for your review ✓',
      'atLeastOneStar': 'Pick at least 1 star',
      'memberSinceLabel': 'Member since',
      'myQrTitle': 'My QR',
      'showThisCodeHint':
          'Show this code at the venue — your stamp is added automatically.',
      'stampWordShort': 'stamp',
      'coinGivenSuffix': 'coins given to the customer',
      'usedSuffixCheck': 'used ✓',
      'scanBonusNote': 'Scan bonus',
      'willBeDeletedSuffix': 'will be deleted.',
      'rewardsWaitSuffix': 'rewards are waiting for you!',
      'catCoffee': 'Cafe & Coffee',
      'catCoffeeShort': 'Cafe',
      'catRestaurant': 'Restaurant',
      'catBeauty': 'Beauty',
      'catBarber': 'Barber',
      'catCarwash': 'Car wash',
      'catFitness': 'Fitness',
      'catBakery': 'Bakery',
      'catOther': 'Other',
      'scanTapHint': 'One tap — the stamp is added automatically.',
      'firstCustomerHint':
          'A customer appears here the first time you tap your card on their phone.',
      'daysLeftSuffix': 'days left',
      'hoursLeftSuffix': 'hours left',
      'minsLeftSuffix': 'min left',
      'rewardFreeItem': 'Free item',
      'rewardPercentDiscount': '% discount',
      'rewardFixedDiscount': 'Fixed discount',
      'rewardCashback': 'Cashback',
      'freeWord': 'free',
      'onWord': 'on',
      'discountWord': 'discount',
      'productFallback': 'item',
      'onbTitle1': 'Earn from places you love',
      'onbSub1':
          'Discover cafes, restaurants and salons — every visit earns you a bonus.',
      'onbSub2':
          'The cashier taps the card on your phone — stamps and points are added automatically.',
      'onbTitle3': 'Collect your rewards',
      'onbSub3':
          'The 6th coffee is on us — earn with offers made just for you.',
      'getStarted': 'Get started',
      'continueAction': 'Continue',
      'roleMismatchBusiness':
          'This entrance is for business accounts. With a customer account, sign in from \'I am a customer\'.',
      'roleMismatchCustomer':
          'This entrance is for customer accounts. With a business account, sign in from \'I am a business\'.',
    },
    'ru': <String, String>{
      'whoAreYou': 'Кто вы?',
      'whoAreYouSub':
          'Выберите роль, чтобы создать аккаунт. Можно изменить в любой момент.',
      'iAmCustomer': 'Я клиент',
      'iAmBusiness': 'Я бизнес',
      'customerHint': 'Копить бонусы в любимых местах',
      'businessHint': 'Следить за клиентами и вести программу лояльности',
      'login': 'Войти',
      'register': 'Регистрация',
      'email': 'Эл. почта',
      'password': 'Пароль',
      'fullName': 'Имя и фамилия',
      'phone': 'Телефон',
      'forgotPassword': 'Забыли пароль?',
      'noAccount': 'Нет аккаунта?',
      'haveAccount': 'Уже есть аккаунт?',
      'welcome': 'Добро пожаловать',
      'createAccount': 'Создать аккаунт',
      'tabHome': 'Открыть',
      'tabCompanies': 'Места',
      'tabCards': 'Карты',
      'tabProfile': 'Профиль',
      'tabRewards': 'Подарки',
      'tabDashboard': 'Панель',
      'tabCustomers': 'Клиенты',
      'tabScan': 'Скан',
      'tabPrograms': 'Программы',
      'tabMyBusiness': 'Бизнес',
      'tabPanel': 'Панель',
      'tabUsers': 'Пользователи',
      'tabBusinesses': 'Бизнес',
      'tabCoins': 'Койны',
      'tabNotify': 'Увед.',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'close': 'Закрыть',
      'logout': 'Выйти',
      'stay': 'Остаться',
      'all': 'Все',
      'seeAll': 'Все',
      'edit': 'Изменить',
      'search': 'Поиск...',
      'logoutTitle': 'Выйти из аккаунта?',
      'profile': 'Профиль',
      'account': 'Аккаунт',
      'help': 'Помощь',
      'editProfile': 'Редактировать профиль',
      'security': 'Безопасность',
      'language': 'Язык',
      'appearance': 'Тема',
      'notifications': 'Уведомления',
      'guest': 'Гость',
      'nameAndPhone': 'Имя, телефон',
      'favorites': 'Избранное',
      'faq': 'Частые вопросы',
      'contactSupport': 'Связаться с поддержкой',
      'aboutApp': 'О приложении',
      'deleteAccount': 'Удалить аккаунт',
      'activeCard': 'Активных карт',
      'rewardsEarned': 'Получено наград',
      'hello': 'Привет,',
      'activeCustomers': 'Активных клиентов',
      'stampsToday': 'Штампов сегодня',
      'rewardsWeek': 'Наград за неделю',
      'returnRate': 'Возвращаемость',
      'recentCustomers': 'Последние клиенты',
      'scanCustomerQr': 'Сканируйте QR клиента',
      'noCustomersYet': 'Клиентов пока нет',
      'myBusiness': 'Мой бизнес',
      'writeNotification': 'Сообщение клиентам',
      'myCards': 'Мои карты',
      'loyaltyCards': 'Карты лояльности',
      'noCardsYet': 'У вас пока нет карт',
      'rewardsActive': 'Активные',
      'rewardsUsed': 'Использованные',
      'loyaltyPrograms': 'Программы лояльности',
      'stampPrograms': 'Штамп-программы',
      'newProgram': 'Новая программа',
      'noProgramsYet': 'Программ пока нет',
      'rewardCatalog': 'Каталог наград',
      'add': 'Добавить',
      'delete': 'Удалить',
      'error': 'Ошибка',
      'retry': 'Повторить',
      'nothingFound': 'Ничего не найдено',
      'comingSoon': 'Скоро',
      'notLoaded': 'Не удалось загрузить',
      'notFound': 'Не найдено',
      'loading': 'Загрузка...',
      'loadMore': 'Ещё',
      'failed': 'Не удалось',
      'cardAddedSuffix': 'карта добавлена',
      'purchasedSeeGifts': 'куплено — см. в «Мои подарки»',
      'shareOnMap': 'На карте',
      'shareDiscover': 'Откройте в Qazan',
      'enter': 'Введите',
      'done': 'Готово',
      'profileUpdated': 'Профиль обновлён',
      'emailReadOnly': 'Эл. почта (нельзя изменить)',
      'enterName': 'Введите имя',
      'changePassword': 'Сменить пароль',
      'passwordUpdated': 'Пароль обновлён ✓',
      'currentPassword': 'Текущий пароль',
      'newPassword': 'Новый пароль',
      'repeatNewPassword': 'Повторите новый пароль',
      'min8Chars': 'Не менее 8 символов',
      'passwordsDontMatch': 'Пароли не совпадают',
      'notifWhichEvents': 'О каких событиях вы хотите узнавать?',
      'notifNewReward': 'Новая награда',
      'notifNewRewardSub': 'Сообщать сразу, как карта заполнена',
      'notifNearby': 'Предложения рядом',
      'notifNearbySub': 'Уведомлять, когда в ваших местах стартует новое промо',
      'notifWeekly': 'Недельная сводка',
      'notifWeeklySub': 'Присылать, сколько вы заработали, каждое воскресенье',
      'notifMarketing': 'Маркетинг и акции',
      'notifMarketingSub': 'Новые заведения и специальные кампании',
      'faqQ1': 'Как получить штамп?',
      'faqA1':
          'При оплате кассир прикладывает карту заведения к вашему телефону — штамп добавляется сразу.',
      'faqQ2': 'Как получить награду?',
      'faqA2':
          'Когда карта заполнится, появится уведомление в «Моих картах». Заберите подарок на кассе при следующем визите.',
      'faqQ3': 'Может ли быть несколько карт?',
      'faqA3':
          'Да! У каждого заведения своя карта. Можно собирать отдельные карты и для разных программ одного заведения.',
      'faqQ4': 'Кому видны мои данные?',
      'faqA4':
          'Только те заведения, где вы открыли карту, видят вас — и только ваши штампы и число визитов у них.',
      'faqQ5': 'Истекает ли срок награды?',
      'faqA5':
          'У части программ есть срок действия. Детали можно посмотреть на странице карты.',
      'faqQ6': 'Потеряю ли я карты при смене телефона?',
      'faqA6':
          'Нет. При повторном входе в аккаунт все карты и история штампов восстановятся.',
      'themeLight': 'Светлая',
      'themeLightSub': 'Всегда использовать светлую тему',
      'themeDark': 'Тёмная',
      'themeDarkSub': 'Всегда использовать тёмную тему',
      'themeSystem': 'Система',
      'themeSystemSub': 'Следовать настройке устройства',
      'languageNote': 'Примечание: локализация скоро охватит все экраны.',
      'businessProfileUpdated': 'Профиль бизнеса обновлён ✓',
      'photoNotPicked': 'Изображение не выбрано',
      'photosSaved': 'Фото сохранены ✓',
      'photoNotUploaded': 'Не удалось загрузить изображение',
      'logoUpdated': 'Фото профиля обновлено ✓',
      'logoNotUploaded': 'Не удалось загрузить логотип',
      'signOutBusinessBody':
          'Вы выйдете из бизнес-аккаунта. Войдите снова, чтобы вернуться.',
      'sectionProfilePhoto': 'Фото профиля',
      'logoHint':
          'Это изображение показывается на главной клиента. Загрузите квадратное фото / логотип.',
      'uploadLogo': 'Загрузить логотип',
      'change': 'Изменить',
      'sectionBasicInfo': 'Основное',
      'name': 'Название',
      'taglineLabel': 'Слоган / краткое описание',
      'category': 'Категория',
      'sectionContactHours': 'Контакты и часы',
      'address': 'Адрес',
      'workingHours': 'Часы работы',
      'workingHoursHint': 'напр. 09:00 – 23:00',
      'openNow': 'Открыто',
      'closedNow': 'Закрыто',
      'collectPoints': 'Копить баллы',
      'nfcTitle': 'Приложите карту',
      'nfcHoldPhone': 'Поднесите телефон к карте на кассе',
      'nfcHoldPhoneBody': 'Кассир приложит карту штампа или баллов к задней части телефона.',
      'nfcShowQrInstead': 'Показать QR',
      'nfcUnsupported': 'В этом телефоне нет NFC',
      'nfcUnsupportedBody': 'Попросите кассира начислить штампы и баллы вручную.',
      'nfcDisabled': 'NFC выключен',
      'nfcDisabledBody': 'Включите NFC в настройках телефона и повторите.',
      'nfcRetry': 'Повторить',
      'nfcFailed': 'Не получилось',
      'nfcAgain': 'Приложить ещё раз',
      'nfcNotOurCard': 'Это не карта Qazan.',
      'nfcOfflineQueued': 'Нет связи — считывание сохранено и будет отправлено позже.',
      'nfcQueuedSent': 'Отправлено офлайн-считываний: {n}',
      'nfcCards': 'NFC-карты',
      'nfcTapLog': 'Считывания',
      'nfcWriteCard': 'Записать на карту',
      'nfcWriteHold': 'Поднесите пустую карту к задней части телефона',
      'nfcWritten': 'Карта записана',
      'nfcNewCard': 'Новая карта',
      'nfcKindStamp': 'Карта штампов',
      'nfcKindPoints': 'Карта баллов',
      'nfcPointsPerTap': 'Баллов за считывание',
      'nfcCooldown': 'Пауза (сек)',
      'nfcDailyCap': 'Лимит в день (на клиента)',
      'nfcBlock': 'Заблокировать',
      'nfcUnblock': 'Разблокировать',
      'nfcRotate': 'Новый код',
      'nfcSuspiciousOnly': 'Подозрительные',
      'nfcTapShort': 'Приложить',
      'loginSub': 'Войдите в свой аккаунт — клиент или бизнес.',
      'countryLabel': 'Страна',
      'currencyLabel': 'Валюта',
      'roleCustomer2': 'Клиент',
      'roleBusiness2': 'Бизнес',
      'pendingRewards': 'Ожидают выдачи',
      'noPendingRewards': 'Ничего не ожидает',
      'noPendingRewardsHint': 'Появится, когда клиент заполнит карту или купит подарок за баллы.',
      'rewardHandOver': 'Использован',
      'rewardHandOverTitle': 'Отметить подарок как использованный?',
      'onbTitle2': 'Приложите карту к телефону',
      'nfcCardsTrailing': 'Карты штампов и баллов',
      'nfcNoCardsBusiness': 'Карты ещё не выданы — обратитесь к админу.',
      'nfcNotWritten': 'Не записана на метку',
      'nfcNotWritable': 'На эту метку нельзя записать (заблокирована или не подходит).',
      'nfcWrittenBody': 'Передайте карту на кассу. Теперь её можно прикладывать к телефонам клиентов.',
      'nfcCooldownHelp': 'Как часто один и тот же клиент может прикладывать эту карту.',
      'menuOwnerHint':
          'Добавьте меню, чтобы клиенты видели ассортимент и цены.',
      'menuDeleteBody': 'Позиция будет удалена из меню.',
      'deleteReviewTitle': 'Удалить отзыв?',
      'lowRatingsOnly': '1–2 звезды',
      'myBusinessSection': 'Мой бизнес',
      'menuOwnerTrailing': 'Позиции, цены',
      'reviewsOwnerTrailing': 'Отзывы клиентов',
      'adImageLabel': 'Фоновое фото',
      'adImageHint': 'Если пусто — используется обложка заведения.',
      'uploadPhoto': 'Загрузить фото',
      'reviewLockedHint':
          'Получите штамп или монеты в этом заведении, чтобы оставить отзыв.',
      'rewardReadyTitle': 'Ваш подарок готов!',
      'rewardReadyBody':
          'Карта заполнена. Получите подарок на кассе.',
      'useReward': 'Использовать',
      'moreCampaigns': 'Ещё {n} акции',
      'moreCampaignsShort': '+{n} акции',
      'instagramHint': '@аккаунт',
      'sectionLocationMap': 'Место (карта)',
      'pickOnMap': 'Выбрать на карте',
      'latitude': 'Широта (lat)',
      'longitude': 'Долгота (lng)',
      'sectionAmenities': 'Удобства',
      'amWifi': 'Wifi',
      'amWorkspace': 'Рабочее место',
      'amMeeting': 'Переговорная',
      'amGarden': 'Сад',
      'amParking': 'Парковка',
      'amVegan': 'Веган',
      'amPet': 'Питомцы',
      'sectionPhotoMenu': 'Фото и меню',
      'businessPhotosHint':
          'Фото бизнеса — загрузите с телефона/компьютера (видны на странице профиля и в поиске).',
      'menuLink': 'Ссылка на меню',
      'menuLinkHint': 'https://... (PDF / сайт / изображение)',
      'sectionCoinSystem': 'Система койнов',
      'coinRate': 'Курс койнов (сколько койнов за 1 ₼)',
      'coinRateHint': 'напр. 0.1  → 1000 ₼ = 100 койнов',
      'coinRateNote':
          'При сканировании кассир вводит сумму чека — койны считаются автоматически. Каталог наград находится в разделе «Программы».',
      'translationsOptional': 'Переводы (по желанию)',
      'translationsHint': 'Можно заполнить название и слоган на EN / RU / TR.',
      'nameEn': 'Название (EN)',
      'taglineEn': 'Слоган (EN)',
      'nameRu': 'Название (RU)',
      'taglineRu': 'Слоган (RU)',
      'nameTr': 'Название (TR)',
      'taglineTr': 'Слоган (TR)',
      'createYourBusiness': 'Создайте бизнес',
      'createBusinessHint':
          'У этого аккаунта пока нет бизнеса. Заполните поля ниже — затем можно добавить фото, меню, удобства и прочее.',
      'businessName': 'Название бизнеса',
      'createBusiness': 'Создать бизнес',
      'enterBusinessName': 'Введите название бизнеса (не менее 2 букв)',
      'businessCreated': 'Бизнес создан ✓ Теперь заполните профиль',
      'addPhoto': 'Добавить фото',
      'qazanAdmin': 'Qazan Admin',
      'platformPanel': 'Панель платформы',
      'signOutAdminBody': 'Вы выйдете из аккаунта администратора.',
      'noData': 'Нет данных',
      'statsUnavailable': 'Статистика недоступна.',
      'promotions': 'Реклама',
      'menus': 'Меню',
      'adminUser': 'Пользователи',
      'adminBusiness': 'Бизнес',
      'loyaltyCard': 'Карты лояльности',
      'coinTransaction': 'Операции с койнами',
      'coinCirculation': 'Койны в обороте',
      'currentBalanceCoin': 'текущий баланс (койны)',
      'earnedLabel': 'Начислено',
      'spentLabel': 'Потрачено',
      'recentSignups': 'Последние регистрации',
      'noUsersYet': 'Пользователей пока нет',
      'signupsHere': 'Регистрации появятся здесь.',
      'recentBusinesses': 'Последние бизнесы',
      'noBusinessesYet': 'Бизнесов пока нет',
      'newBusinessesHere': 'Новые бизнесы появятся здесь.',
      'roleCustomer': 'Клиент',
      'roleBusiness': 'Бизнес',
      'roleAdmin': 'Админ',
      'unnamed': '(без имени)',
      'searchNameEmail': 'Поиск по имени или эл. почте',
      'filterTryAgain': 'Измените фильтр и попробуйте снова.',
      'assignRole': 'Назначить роль',
      'blockUser': 'Заблокировать',
      'activateUser': 'Активировать',
      'userBlocked': 'заблокирован',
      'userActivated': 'активирован',
      'promoteBusiness': 'Представьте свой бизнес',
      'registerBusinessSub': 'Ваш бизнес-профиль готовится.',
      'registerCustomerSub':
          'Присоединяйтесь за минуту и получите первую печать.',
      'businessNameHint': 'напр. Qazan Coffee',
      'fullNameHint': 'напр. Али Мамедов',
      'emailHint': 'you@qazan.az',
      'enterNameShort': 'Введите имя',
      'invalidEmail': 'Введите корректный email',
      'passwordHintMin8': 'не менее 8 символов',
      'registrationFailed': 'Регистрация не удалась',
      'birthDateOptional': 'Дата рождения (необязательно)',
      'pickDate': 'Выберите дату',
      'pickBirthDate': 'Выберите дату рождения',
      'selectAction': 'Выбрать',
      'phoneNumberInvalid': 'Неверный номер телефона',
      'pwRuleMin8': 'Не менее 8 символов',
      'pwRuleLetter': 'Хотя бы одна буква',
      'pwRuleDigit': 'Хотя бы одна цифра',
      'pwErrMin8': 'Не менее 8 символов',
      'pwErrLetter': 'Должна быть хотя бы одна буква',
      'pwErrDigit': 'Должна быть хотя бы одна цифра',
      'skip': 'Пропустить',
      'loginBusinessSub': 'Войдите в бизнес-аккаунт и отслеживайте клиентов.',
      'loginCustomerSub': 'Войдите и зарабатывайте в любимых местах.',
      'loginFailed': 'Не удалось войти',
      'passwordShort': 'Пароль слишком короткий',
      'resetPassword': 'Сбросить пароль',
      'resetPasswordEmailPrompt':
          'Введите email аккаунта — мы отправим 6-значный код.',
      'codeSentToEmail':
          'Код отправлен на email. Проверьте спам, если его нет.',
      'errorTryAgain': 'Что-то пошло не так. Повторите позже.',
      'newPasswordReady': 'Теперь вы можете войти с новым паролем.',
      'codeSentPrompt': 'введите отправленный код и новый пароль.',
      'sendCode': 'Отправить код',
      'resendCode': 'Отправить код снова',
      'confirmationCode': 'Код подтверждения',
      'sixDigits': '6 цифр',
      'enterSixDigitCode': 'Введите 6-значный код',
      'eightPlusChars': '8+ символов',
      'updatePasswordAction': 'Обновить пароль',
      'noFavoritesYet': 'Пока нет избранного',
      'noFavoritesHint':
          'Нажмите на сердечко в профиле понравившегося бизнеса — оно появится здесь.',
      'pickLocationTitle': 'Выберите местоположение',
      'mapTapHint':
          'Нажмите на карту, чтобы отметить местоположение бизнеса. Широта/долгота заполнятся автоматически.',
      'confirmThisLocation': 'Подтвердить это местоположение',
      'passwordLabel': 'Пароль',
      'businessFallback': 'Бизнес',
      'searchCustomer': 'Поиск клиента',
      'visitsWord': 'визитов',
      'lastVisit': 'последний визит',
      'stampWord': 'печатей',
      'rewardWord': 'подарков',
      'customerTitle': 'Клиент',
      'recentPurchases': 'Недавние покупки',
      'noActivityYet': 'Пока нет активности',
      'activityWillShow': 'Появится здесь после добавления печати.',
      'callAction': 'Позвонить',
      'totalStampsLabel': 'Всего печатей',
      'earnedRewards': 'Получено',
      'readyReward': 'Готовая награда',
      'visitWord': 'Визиты',
      'readyWord': 'готово',
      'rewardGained': 'Получена награда',
      'stampAdded': 'Печать добавлена',
      'noBusinessProfile': 'Нет бизнес-профиля',
      'createFirstOffer': 'Создайте первое предложение и вернёте клиентов.',
      'deleteProgramTitle': 'Удалить программу?',
      'programCreated': 'Программа создана',
      'programUpdated': 'Программа обновлена',
      'newLoyaltyProgram': 'Новая программа лояльности',
      'editProgram': 'Изменить программу',
      'threeSimpleSteps':
          'Три простых шага — после скольких печатей и что получает клиент.',
      'whatCustomerEarns': 'Что получает клиент?',
      'discountPercentLabel': 'Процент скидки (%)',
      'amountManatLabel': 'Сумма (₼)',
      'egFifty': 'напр. 50',
      'egFive': 'напр. 5',
      'validNumber': 'Введите корректное число',
      'range0to100': 'Должно быть от 0 до 100',
      'whichProduct': 'Для какого товара?',
      'productExampleHint': 'напр. кофе, бургер, маникюр',
      'enterProduct': 'Введите товар',
      'howManyStamps': 'Сколько печатей нужно?',
      'nameYourProgram': 'Назовите программу',
      'programNameLabel': 'Название программы',
      'programNameHint': 'напр. Купи 5, 6-я бесплатно',
      'descriptionOptional': 'Описание (необязательно)',
      'descriptionShortHint': 'Краткое описание, которое увидит клиент',
      'enterName2': 'Введите название',
      'createAction': 'Создать',
      'previewWord': 'Предпросмотр',
      'newProgramPlaceholder': 'Новая программа',
      'addReward': 'Добавить награду',
      'rewardNameHint': 'Название — напр. Сан-Себастьян',
      'descOptionalHint': 'Описание (необязательно)',
      'howManyCoinHint': 'Сколько монет',
      'nameAndValidCoin': 'Введите название и корректное количество монет',
      'coinGiftsSub': 'Подарки за монеты (отдельно от программ с печатями).',
      'noRewardsYetHint':
          'Пока нет наград. Создайте через «Добавить» — напр. 100 монет = 1 Сан-Себастьян.',
      'usersTitle': 'Пользователи',
      'businessesTitle': 'Бизнесы',
      'searchBusinessName': 'Поиск по названию бизнеса',
      'searchTryAgain': 'Измените запрос и попробуйте снова.',
      'reviewWord': 'отзывов',
      'featuredLabel': 'Рекомендуемое',
      'failedColon': 'Не удалось',
      'titleAndBodyRequired': 'Введите заголовок и текст',
      'notifSentToAll': 'Уведомление отправлено всем ✓',
      'sendNotification': 'Отправить уведомление',
      'notifReachAll':
          'Оно дойдёт до всех пользователей и появится в их уведомлениях.',
      'titleLabel': 'Заголовок',
      'bodyLabel': 'Текст',
      'sendingWord': 'Отправка...',
      'sendToAll': 'Отправить всем',
      'sentItems': 'Отправлено',
      'noNotifSent': 'Уведомления ещё не отправлялись.',
      'coinAdjustment': 'Корректировка монет',
      'coinControl': 'Управление монетами',
      'recentTransactions': 'Недавние операции',
      'noTransactions': 'Нет операций',
      'transactionsWillShow': 'Движения монет появятся здесь.',
      'inCirculation': 'В обращении',
      'transactionWord': 'Операции',
      'unknownParen': '(неизвестно)',
      'adjustPositiveNegative':
          'Положительное значение добавляет монеты, отрицательное — списывает.',
      'pickUserAndAmount': 'Выберите пользователя и введите ненулевую сумму.',
      'searchUserByEmail': 'Найти пользователя по email',
      'amountExample': 'Сумма (напр. 500 или -200)',
      'noteOptional': 'Заметка (необязательно)',
      'applyingWord': 'Применение...',
      'applyAction': 'Применить',
      'usersLabel': 'Пользователи',
      'businessLabel': 'Бизнесы',
      'newAd': 'Новая реклама',
      'noAdsYet': 'Пока нет рекламы',
      'createFirstBanner': 'Создайте первый баннер через «Новая реклама».',
      'deleteAdTitle': 'Удалить рекламу?',
      'deleteFailed': 'Не удалось удалить',
      'activeWord': 'Активно',
      'inactiveWord': 'Неактивно',
      'tagAndTitleRequired': 'Тег и заголовок обязательны',
      'editAd': 'Изменить рекламу',
      'tagLabel': 'Тег',
      'tagHint': 'напр. НОВОЕ, АКЦИЯ',
      'subtitleLabel': 'Подзаголовок',
      'emojiLabel': 'Эмодзи',
      'buttonTextLabel': 'Текст кнопки',
      'colorLabel': 'Цвет',
      'savingWord': 'Сохранение...',
      'titleFallback': 'Заголовок',
      'addFood': 'Добавить блюдо',
      'selectBusiness': 'Выберите бизнес',
      'menuLinkSaved': 'Ссылка на меню сохранена ✓',
      'menuLinkDesc':
          'Ссылка на PDF / сайт / изображение. Показывается при отсутствии структурированного меню.',
      'saveShort': 'Сохранить',
      'structuredMenu': 'Структурированное меню (категории)',
      'noFoodYet':
          'Пока нет блюд. Через «Добавить блюдо» создайте меню по категориям (напр. «Кофе», «Десерты»).',
      'categoryAndNameRequired': 'Категория и название обязательны',
      'categoryLabel': 'Категория',
      'categoryHint': 'напр. Кофе, Основные',
      'descriptionOptionalField': 'Описание (необязательно)',
      'priceOptional': 'Цена (₼, необязательно)',
      'discoverCardHint':
          'Найдите любимое место в разделе «Обзор» и получите его карту.',
      'coinBalanceNotLoaded': 'Не удалось загрузить баланс монет',
      'myCoinBalance': 'Мой баланс монет',
      'scanQr': 'Отсканируйте QR',
      'holdCustomerQr': 'Наведите QR-код клиента в рамку',
      'autoDetected': 'Определено автоматически',
      'createBusinessFirst': 'Чтобы сканировать, сначала создайте бизнес.',
      'customerFound': 'Клиент найден',
      'activeRewards': 'Активные награды',
      'giveStamp': 'Выдать печать',
      'giveCoin': 'Начислить монеты',
      'stampRewardLabel': 'Награда за печати',
      'useAction': 'Использовать',
      'howManyCoinQ': 'Сколько монет?',
      'amountWord': 'Сумма',
      'giveAction': 'Выдать',
      'noStories': 'Нет историй',
      'signOutBody':
          'Вы выйдете из аккаунта. Вы сможете вернуться, войдя снова.',
      'deleteAccountTitle': 'Удалить аккаунт?',
      'deleteAccountBody':
          'Это навсегда удалит ваш аккаунт. Данные профиля будут стёрты, и это нельзя отменить.\n\nЗаработанные монеты и карты также станут недоступны.',
      'accountDeleteFailed': 'Не удалось удалить аккаунт',
      'phoneWord': 'Телефон',
      'whatsappSub': 'Отправьте сообщение — ответим в течение 5 минут',
      'aboutBody':
          'Платформа лояльности и учёта клиентов — для кафе, ресторанов и салонов.',
      'allRightsReserved': '© 2026 Qazan. Все права защищены.',
      'notifActiveSuffix': 'активно',
      'rewardsActiveTab': 'Активные',
      'rewardsUsedTab': 'Использованные',
      'noActiveRewards': 'Пока нет активных наград',
      'noActiveRewardsSub':
          'Купите подарок за монеты на странице бизнеса или заполните карту с печатями.',
      'noUsageHistory': 'Пока нет истории использования',
      'noUsageHistorySub': 'Подарки, использованные на кассе, появятся здесь.',
      'coinLabel': 'Монета',
      'stampLabel': 'Печать',
      'showQrCashier': 'Получите на кассе',
      'usedPrefix': 'Использовано',
      'nowWord': 'сейчас',
      'minAgo': 'мин назад',
      'hourAgo': 'ч назад',
      'dayAgo': 'д назад',
      'noNotifications': 'Нет уведомлений',
      'newNotifsHere': 'Новые уведомления появятся здесь.',
      'menuWord': 'Меню',
      'fullMenu': 'Всё меню',
      'showQr': 'Показать QR',
      'campaigns': 'Кампании',
      'noCampaignYet': 'Пока нет кампаний',
      'campaignComingSoon': 'Это место скоро добавит предложения.',
      'joinCampaign': 'Присоединиться к кампании',
      'buyWithCoin': 'Купить за монеты',
      'buyWithCoinHint':
          'Нажмите «Купить» — баллы спишутся, подарок попадёт в «Мои подарки». Заберите его на кассе.',
      'buyAction': 'Купить',
      'insufficientWord': 'Недостаточно',
      'mAway': 'м',
      'kmAway': 'км',
      'errorOccurred': 'Произошла ошибка',
      'helloName': 'Привет',
      'whereEarnToday': 'Где сегодня заработаем?',
      'friendFallback': 'Друг',
      'allPlaces': 'Все места',
      'nothingFoundHint': 'Измените фильтр или поищите другое слово.',
      'directions': 'Маршрут',
      'reviewsNotLoaded': 'Не удалось загрузить отзывы',
      'reviewsWord': 'Отзывы',
      'noReviewsYet': 'Пока нет отзывов. Будьте первым!',
      'writeReview': 'Написать отзыв',
      'editReview': 'Изменить отзыв',
      'youParen': 'вы',
      'rateExperience': 'Оцените впечатление',
      'reviewHint': 'Ваш отзыв (необязательно)…',
      'sendAction': 'Отправить',
      'reviewThanks': 'Спасибо за отзыв ✓',
      'atLeastOneStar': 'Поставьте хотя бы 1 звезду',
      'memberSinceLabel': 'Клиент с',
      'myQrTitle': 'Мой QR',
      'showThisCodeHint':
          'Покажите этот код заведению — печать добавится автоматически.',
      'stampWordShort': 'печать',
      'coinGivenSuffix': 'монет начислено клиенту',
      'usedSuffixCheck': 'использовано ✓',
      'scanBonusNote': 'Бонус за скан',
      'willBeDeletedSuffix': 'будет удалено.',
      'rewardsWaitSuffix': 'наград ждут вас!',
      'catCoffee': 'Кафе и кофейни',
      'catCoffeeShort': 'Кафе',
      'catRestaurant': 'Ресторан',
      'catBeauty': 'Красота',
      'catBarber': 'Барбершоп',
      'catCarwash': 'Автомойка',
      'catFitness': 'Фитнес',
      'catBakery': 'Кондитерская',
      'catOther': 'Другое',
      'scanTapHint': 'Одно касание — штамп добавляется автоматически.',
      'firstCustomerHint':
          'Клиент появится здесь, как только вы впервые приложите карту к его телефону.',
      'daysLeftSuffix': 'дн. осталось',
      'hoursLeftSuffix': 'ч. осталось',
      'minsLeftSuffix': 'мин осталось',
      'rewardFreeItem': 'Бесплатный товар',
      'rewardPercentDiscount': 'Скидка %',
      'rewardFixedDiscount': 'Фикс. скидка',
      'rewardCashback': 'Кэшбэк',
      'freeWord': 'бесплатно',
      'onWord': 'на',
      'discountWord': 'скидка',
      'productFallback': 'товар',
      'onbTitle1': 'Зарабатывайте в любимых местах',
      'onbSub1':
          'Открывайте кафе, рестораны и салоны — каждый визит приносит бонус.',
      'onbSub2':
          'Кассир прикладывает карту к вашему телефону — штампы и баллы начисляются автоматически.',
      'onbTitle3': 'Собирайте награды',
      'onbSub3':
          '6-й кофе за наш счёт — зарабатывайте с предложениями для вас.',
      'getStarted': 'Начать',
      'continueAction': 'Продолжить',
      'roleMismatchBusiness':
          'Этот вход для бизнес-аккаунтов. С аккаунтом клиента войдите через «Я клиент».',
      'roleMismatchCustomer':
          'Этот вход для аккаунтов клиентов. С бизнес-аккаунтом войдите через «Я бизнес».',
    },
    'tr': <String, String>{
      'whoAreYou': 'Kimsin?',
      'whoAreYouSub':
          'Hesap oluşturmak için rolünü seç. İstediğin zaman değiştirebilirsin.',
      'iAmCustomer': 'Müşteriyim',
      'iAmBusiness': 'İşletmeyim',
      'customerHint': 'Sevdiğim yerlerden ödül topla',
      'businessHint': 'Müşterileri takip et ve sadakat programı yürüt',
      'login': 'Giriş yap',
      'register': 'Kayıt ol',
      'email': 'E-posta',
      'password': 'Şifre',
      'fullName': 'Ad ve soyad',
      'phone': 'Telefon numarası',
      'forgotPassword': 'Şifrenizi mi unuttunuz?',
      'noAccount': 'Hesabınız yok mu?',
      'haveAccount': 'Hesabın var mı?',
      'welcome': 'Hoş Geldiniz',
      'createAccount': 'Hesap oluştur',
      'tabHome': 'Keşfet',
      'tabCompanies': 'Yerler',
      'tabCards': 'Kartlarım',
      'tabProfile': 'Profil',
      'tabRewards': 'Hediyeler',
      'tabDashboard': 'Panel',
      'tabCustomers': 'Müşteriler',
      'tabScan': 'Tara',
      'tabPrograms': 'Programlar',
      'tabMyBusiness': 'İşletmem',
      'tabPanel': 'Panel',
      'tabUsers': 'Kullanıcılar',
      'tabBusinesses': 'İşletmeler',
      'tabCoins': 'Koin',
      'tabNotify': 'Bildirim',
      'save': 'Kaydet',
      'cancel': 'İptal',
      'close': 'Kapat',
      'logout': 'Çıkış',
      'stay': 'Kal',
      'all': 'Tümü',
      'seeAll': 'Tümünü gör',
      'edit': 'Düzenle',
      'search': 'Ara...',
      'logoutTitle': 'Çıkmak ister misin?',
      'profile': 'Profil',
      'account': 'Hesap',
      'help': 'Yardım',
      'editProfile': 'Profili düzenle',
      'security': 'Güvenlik',
      'language': 'Dil',
      'appearance': 'Görünüm',
      'notifications': 'Bildirimler',
      'guest': 'Misafir',
      'nameAndPhone': 'Ad, telefon',
      'favorites': 'Favoriler',
      'faq': 'Sıkça sorulan sorular',
      'contactSupport': 'Destek ile iletişim',
      'aboutApp': 'Uygulama hakkında',
      'deleteAccount': 'Hesabı sil',
      'activeCard': 'Aktif kart',
      'rewardsEarned': 'Kazanılan ödül',
      'hello': 'Merhaba,',
      'activeCustomers': 'Aktif müşteri',
      'stampsToday': 'Bugün damga',
      'rewardsWeek': 'Haftalık ödül',
      'returnRate': 'Geri dönüş',
      'recentCustomers': 'Son müşteriler',
      'scanCustomerQr': "Müşterinin QR'ını tara",
      'noCustomersYet': 'Henüz müşteri yok',
      'myBusiness': 'İşletmem',
      'writeNotification': 'Müşterilerine mesaj yaz',
      'myCards': 'Kartlarım',
      'loyaltyCards': 'Sadakat kartları',
      'noCardsYet': 'Henüz kartın yok',
      'rewardsActive': 'Aktif',
      'rewardsUsed': 'Kullanılmış',
      'loyaltyPrograms': 'Sadakat programları',
      'stampPrograms': 'Damga programları',
      'newProgram': 'Yeni program',
      'noProgramsYet': 'Henüz program yok',
      'rewardCatalog': 'Ödül kataloğu',
      'add': 'Ekle',
      'delete': 'Sil',
      'error': 'Hata',
      'retry': 'Tekrar dene',
      'nothingFound': 'Hiçbir şey bulunamadı',
      'comingSoon': 'Yakında',
      'notLoaded': 'Yüklenemedi',
      'notFound': 'Bulunamadı',
      'loading': 'Yükleniyor...',
      'loadMore': 'Daha fazla',
      'failed': 'Başarısız',
      'cardAddedSuffix': 'kartı eklendi',
      'purchasedSeeGifts': 'satın alındı — Hediyelerim\'de gör',
      'shareOnMap': 'Haritada',
      'shareDiscover': 'Qazan uygulamasında keşfet',
      'enter': 'Gir',
      'done': 'Tamam',
      'profileUpdated': 'Profil güncellendi',
      'emailReadOnly': 'E-posta (değiştirilemez)',
      'enterName': 'Adını yaz',
      'changePassword': 'Şifreyi değiştir',
      'passwordUpdated': 'Şifre güncellendi ✓',
      'currentPassword': 'Mevcut şifre',
      'newPassword': 'Yeni şifre',
      'repeatNewPassword': 'Yeni şifreyi tekrarla',
      'min8Chars': '8+ karakter olsun',
      'passwordsDontMatch': 'Şifreler uyuşmuyor',
      'notifWhichEvents': 'Hangi olaylardan haberdar olmak istersin?',
      'notifNewReward': 'Yeni ödül',
      'notifNewRewardSub': 'Bir kart tamamlanınca hemen bilgi ver',
      'notifNearby': 'Yakındaki teklifler',
      'notifNearbySub': 'Mekanlarında yeni bir kampanya başlayınca haber ver',
      'notifWeekly': 'Haftalık özet',
      'notifWeeklySub': 'Her pazar ne kadar kazandığını gönder',
      'notifMarketing': 'Pazarlama ve kampanyalar',
      'notifMarketingSub': 'Yeni işletmeler ve özel kampanyalar',
      'faqQ1': 'Damgayı nasıl kazanırım?',
      'faqA1':
          'Alışverişte kasiyer mekanın kartını telefonuna değdirir, damga anında eklenir.',
      'faqQ2': 'Ödülü nasıl alırım?',
      'faqA2':
          'Kart dolunca "Kartlarım" bölümünde bildirim görürsün. Sonraki ziyaretinde hediyeni kasadan teslim alırsın.',
      'faqQ3': 'Birden fazla kartım olabilir mi?',
      'faqA3':
          'Evet! Her mekanın kendi kartı var. Bir mekanın farklı programları için de ayrı kartlar biriktirebilirsin.',
      'faqQ4': 'Müşteri verilerimi kim görür?',
      'faqA4':
          'Yalnızca kart açtığın mekanlar seni görür — ve yalnızca onlardaki damga ve ziyaret sayını.',
      'faqQ5': 'Ödülün süresi doluyor mu?',
      'faqA5':
          'Bazı programların bitiş tarihi olur. Ayrıntıyı kartın açılan sayfasında görebilirsin.',
      'faqQ6': 'Telefonumu değiştirirsem kartlarım kaybolur mu?',
      'faqA6':
          'Hayır. Hesabına yeniden giriş yaptığında tüm kartların ve damga geçmişin geri gelir.',
      'themeLight': 'Açık',
      'themeLightSub': 'Her zaman açık temayı kullan',
      'themeDark': 'Koyu',
      'themeDarkSub': 'Her zaman koyu temayı kullan',
      'themeSystem': 'Sistem',
      'themeSystemSub': 'Cihaz ayarını izle',
      'languageNote': 'Not: yerelleştirme yakında tüm ekranlara yayılacak.',
      'businessProfileUpdated': 'İşletme profili güncellendi ✓',
      'photoNotPicked': 'Görsel seçilmedi',
      'photosSaved': 'Fotoğraflar kaydedildi ✓',
      'photoNotUploaded': 'Görsel yüklenemedi',
      'logoUpdated': 'Profil fotoğrafı güncellendi ✓',
      'logoNotUploaded': 'Logo yüklenemedi',
      'signOutBusinessBody':
          'İşletme hesabından çıkacaksın. Tekrar giriş yaparak dönebilirsin.',
      'sectionProfilePhoto': 'Profil fotoğrafı',
      'logoHint':
          'Bu görsel müşteri ana sayfasında görünür. Kare / logo görseli yükle.',
      'uploadLogo': 'Logo yükle',
      'change': 'Değiştir',
      'sectionBasicInfo': 'Temel bilgi',
      'name': 'Ad',
      'taglineLabel': 'Slogan / kısa açıklama',
      'category': 'Kategori',
      'sectionContactHours': 'İletişim & saatler',
      'address': 'Adres',
      'workingHours': 'Çalışma saatleri',
      'workingHoursHint': 'örn. 09:00 – 23:00',
      'openNow': 'Açık',
      'closedNow': 'Kapalı',
      'collectPoints': 'Puan Topla',
      'nfcTitle': 'Kartı okut',
      'nfcHoldPhone': 'Telefonu kasadaki karta yaklaştır',
      'nfcHoldPhoneBody': 'Kasiyer damga veya puan kartını telefonun arkasına değdirsin.',
      'nfcShowQrInstead': 'QR göster',
      'nfcUnsupported': 'Bu telefonda NFC yok',
      'nfcUnsupportedBody': 'Damga ve puanların için kasiyere başvur — hesabına elle ekleyebilir.',
      'nfcDisabled': 'NFC kapalı',
      'nfcDisabledBody': 'Telefon ayarlarından NFC’yi aç ve tekrar dene.',
      'nfcRetry': 'Tekrar dene',
      'nfcFailed': 'Olmadı',
      'nfcAgain': 'Tekrar okut',
      'nfcNotOurCard': 'Bu bir Qazan kartı değil.',
      'nfcOfflineQueued': 'İnternet yok — okutma kaydedildi, bağlantı gelince gönderilecek.',
      'nfcQueuedSent': 'Çevrimdışı {n} okutma gönderildi',
      'nfcCards': 'NFC kartlar',
      'nfcTapLog': 'Okutmalar',
      'nfcWriteCard': 'Karta yaz',
      'nfcWriteHold': 'Boş kartı telefonun arkasına yaklaştır',
      'nfcWritten': 'Kart yazıldı',
      'nfcNewCard': 'Yeni kart',
      'nfcKindStamp': 'Damga kartı',
      'nfcKindPoints': 'Puan kartı',
      'nfcPointsPerTap': 'Okutma başına puan',
      'nfcCooldown': 'Bekleme (sn)',
      'nfcDailyCap': 'Günlük limit (müşteri başına)',
      'nfcBlock': 'Blokla',
      'nfcUnblock': 'Bloku kaldır',
      'nfcRotate': 'Yeni kod ver',
      'nfcSuspiciousOnly': 'Şüpheli',
      'nfcTapShort': 'Kartı okut',
      'loginSub': 'Hesabınla giriş yap — müşteri ya da işletme fark etmez.',
      'countryLabel': 'Ülke',
      'currencyLabel': 'Para birimi',
      'roleCustomer2': 'Müşteri',
      'roleBusiness2': 'İşletme',
      'pendingRewards': 'Bekleyen hediyeler',
      'noPendingRewards': 'Bekleyen hediye yok',
      'noPendingRewardsHint': 'Müşteri kartı tamamlayınca veya coinle hediye alınca burada görünür.',
      'rewardHandOver': 'Kullanıldı',
      'rewardHandOverTitle': 'Hediye kullanıldı olarak işaretlensin mi?',
      'onbTitle2': 'Kartı telefona okut',
      'nfcCardsTrailing': 'Damga ve puan kartları',
      'nfcNoCardsBusiness': 'Henüz kart verilmemiş — admin ile iletişime geçin.',
      'nfcNotWritten': 'Karta yazılmadı',
      'nfcNotWritable': 'Bu etikete yazılamıyor (kilitli veya uyumsuz).',
      'nfcWrittenBody': 'Kartı kasaya ver. Artık müşteri telefonlarına okutulabilir.',
      'nfcCooldownHelp': 'Aynı müşteri bu kartı ne sıklıkla okutabilir.',
      'menuOwnerHint':
          'Müşteriler ne sunduğunu ve fiyatları görsün diye menü ekle.',
      'menuDeleteBody': 'Bu ürün menüden silinecek.',
      'deleteReviewTitle': 'Yorum silinsin mi?',
      'lowRatingsOnly': '1–2 yıldız',
      'myBusinessSection': 'İşletmem',
      'menuOwnerTrailing': 'Ürünler, fiyatlar',
      'reviewsOwnerTrailing': 'Müşteri yorumları',
      'adImageLabel': 'Arka plan fotoğrafı',
      'adImageHint': 'Boş bırakılırsa mekanın kapak fotoğrafı kullanılır.',
      'uploadPhoto': 'Fotoğraf yükle',
      'reviewLockedHint':
          'Yorum yazmak için bu mekanda en az bir damga veya coin kazan.',
      'rewardReadyTitle': 'Hediyen hazır!',
      'rewardReadyBody':
          'Kartını tamamladın. Hediyeni kasadan teslim al.',
      'useReward': 'Kullan',
      'moreCampaigns': '+{n} Kampanya daha',
      'moreCampaignsShort': '+{n} kampanya',
      'instagramHint': '@hesap',
      'sectionLocationMap': 'Konum (harita)',
      'pickOnMap': 'Haritadan seç',
      'latitude': 'Enlem (lat)',
      'longitude': 'Boylam (lng)',
      'sectionAmenities': 'Olanaklar',
      'amWifi': 'Wifi',
      'amWorkspace': 'Çalışma',
      'amMeeting': 'Toplantı',
      'amGarden': 'Bahçe',
      'amParking': 'Otopark',
      'amVegan': 'Vegan',
      'amPet': 'Evcil',
      'sectionPhotoMenu': 'Fotoğraf & menü',
      'businessPhotosHint':
          'İşletme fotoğrafları — telefonundan/bilgisayarından yükle (profil ve arama sayfasında görünür).',
      'menuLink': 'Menü bağlantısı',
      'menuLinkHint': 'https://... (PDF / site / görsel)',
      'sectionCoinSystem': 'Koin sistemi',
      'coinRate': 'Koin oranı (1 ₼ için kaç koin)',
      'coinRateHint': 'örn. 0.1  → 1000 ₼ = 100 koin',
      'coinRateNote':
          'Kasiyer taradığında fiş tutarını yazar — koin otomatik hesaplanır. Ödül kataloğu ise "Programlar" bölümündedir.',
      'translationsOptional': 'Çeviriler (isteğe bağlı)',
      'translationsHint':
          'Adı ve sloganı EN / RU / TR dillerinde doldurabilirsin.',
      'nameEn': 'Ad (EN)',
      'taglineEn': 'Slogan (EN)',
      'nameRu': 'Ad (RU)',
      'taglineRu': 'Slogan (RU)',
      'nameTr': 'Ad (TR)',
      'taglineTr': 'Slogan (TR)',
      'createYourBusiness': 'İşletmeni oluştur',
      'createBusinessHint':
          'Bu hesabın henüz işletmesi yok. Aşağıdakileri doldur — sonra fotoğraf, menü, olanaklar vb. ekleyebilirsin.',
      'businessName': 'İşletme adı',
      'createBusiness': 'İşletme oluştur',
      'enterBusinessName': 'İşletme adını yaz (en az 2 harf)',
      'businessCreated': 'İşletme oluşturuldu ✓ Şimdi profili tamamla',
      'addPhoto': 'Fotoğraf ekle',
      'qazanAdmin': 'Qazan Admin',
      'platformPanel': 'Platform paneli',
      'signOutAdminBody': 'Admin hesabından çıkacaksın.',
      'noData': 'Veri yok',
      'statsUnavailable': 'İstatistik mevcut değil.',
      'promotions': 'Reklamlar',
      'menus': 'Menüler',
      'adminUser': 'Kullanıcılar',
      'adminBusiness': 'İşletmeler',
      'loyaltyCard': 'Sadakat kartı',
      'coinTransaction': 'Koin işlemi',
      'coinCirculation': 'Koin dolaşımı',
      'currentBalanceCoin': 'güncel bakiye (koin)',
      'earnedLabel': 'Kazanıldı',
      'spentLabel': 'Harcandı',
      'recentSignups': 'Son kayıtlar',
      'noUsersYet': 'Henüz kullanıcı yok',
      'signupsHere': 'Kayıtlar burada görünecek.',
      'recentBusinesses': 'Son işletmeler',
      'noBusinessesYet': 'Henüz işletme yok',
      'newBusinessesHere': 'Yeni işletmeler burada görünecek.',
      'roleCustomer': 'Müşteri',
      'roleBusiness': 'İşletme',
      'roleAdmin': 'Admin',
      'unnamed': '(adsız)',
      'searchNameEmail': 'Ad veya e-posta ara',
      'filterTryAgain': 'Filtreyi değiştirip tekrar dene.',
      'assignRole': 'Rol ata',
      'blockUser': 'Kullanıcıyı engelle',
      'activateUser': 'Kullanıcıyı aktifleştir',
      'userBlocked': 'engellendi',
      'userActivated': 'aktifleşti',
      'promoteBusiness': 'İşletmeni tanıt',
      'registerBusinessSub': 'İşletme profilin hazırlanıyor.',
      'registerCustomerSub': 'Bir dakikada katıl ve ilk damganı kazan.',
      'businessNameHint': 'örn. Qazan Coffee',
      'fullNameHint': 'örn. Ali Memmedov',
      'emailHint': 'sen@qazan.az',
      'enterNameShort': 'Adını gir',
      'invalidEmail': 'Geçerli bir e-posta gir',
      'passwordHintMin8': 'en az 8 karakter',
      'registrationFailed': 'Kayıt başarısız',
      'birthDateOptional': 'Doğum tarihi (isteğe bağlı)',
      'pickDate': 'Tarih seç',
      'pickBirthDate': 'Doğum tarihini seç',
      'selectAction': 'Seç',
      'phoneNumberInvalid': 'Telefon numarası geçersiz',
      'pwRuleMin8': 'En az 8 karakter',
      'pwRuleLetter': 'En az bir harf',
      'pwRuleDigit': 'En az bir rakam',
      'pwErrMin8': 'En az 8 karakter',
      'pwErrLetter': 'En az bir harf olmalı',
      'pwErrDigit': 'En az bir rakam olmalı',
      'skip': 'Geç',
      'loginBusinessSub':
          'İşletme hesabına giriş yap ve müşterilerini takip et.',
      'loginCustomerSub': 'Giriş yap ve favori mekanlarından kazan.',
      'loginFailed': 'Giriş başarısız',
      'passwordShort': 'Şifre çok kısa',
      'resetPassword': 'Şifreyi sıfırla',
      'resetPasswordEmailPrompt':
          'Hesabının e-postasını yaz — sana 6 haneli doğrulama kodu göndereceğiz.',
      'codeSentToEmail':
          'Kod e-postana gönderildi. Gelmezse spam klasörünü kontrol et.',
      'errorTryAgain': 'Bir şeyler ters gitti. Birazdan tekrar dene.',
      'newPasswordReady': 'Artık yeni şifrenle giriş yapabilirsin.',
      'codeSentPrompt': 'adresine gönderilen kodu ve yeni şifreyi gir.',
      'sendCode': 'Kod gönder',
      'resendCode': 'Kodu tekrar gönder',
      'confirmationCode': 'Onay kodu',
      'sixDigits': '6 hane',
      'enterSixDigitCode': '6 haneli kodu gir',
      'eightPlusChars': '8+ karakter',
      'updatePasswordAction': 'Şifreyi güncelle',
      'noFavoritesYet': 'Henüz favori yok',
      'noFavoritesHint':
          'Beğendiğin işletmenin profilinde kalp simgesine dokun — burada toplansın.',
      'pickLocationTitle': 'Konum seç',
      'mapTapHint':
          'İşletme konumunu işaretlemek için haritaya dokun. Enlem/boylam otomatik dolacak.',
      'confirmThisLocation': 'Bu konumu onayla',
      'passwordLabel': 'Şifre',
      'businessFallback': 'İşletme',
      'searchCustomer': 'Müşteri ara',
      'visitsWord': 'ziyaret',
      'lastVisit': 'son ziyaret',
      'stampWord': 'damga',
      'rewardWord': 'hediye',
      'customerTitle': 'Müşteri',
      'recentPurchases': 'Son alışverişler',
      'noActivityYet': 'Henüz aktivite yok',
      'activityWillShow': 'Bir damga eklendiğinde burada görünecek.',
      'callAction': 'Ara',
      'totalStampsLabel': 'Toplam damga',
      'earnedRewards': 'Kazanılan',
      'readyReward': 'Hazır ödül',
      'visitWord': 'Ziyaretler',
      'readyWord': 'hazır',
      'rewardGained': 'Ödül kazandı',
      'stampAdded': 'Damga eklendi',
      'noBusinessProfile': 'İşletme profili yok',
      'createFirstOffer': 'İlk teklifini oluştur ve müşterileri geri getir.',
      'deleteProgramTitle': 'Program silinsin mi?',
      'programCreated': 'Program oluşturuldu',
      'programUpdated': 'Program güncellendi',
      'newLoyaltyProgram': 'Yeni sadakat programı',
      'editProgram': 'Programı düzenle',
      'threeSimpleSteps':
          'Üç basit adım — kaç damgadan sonra müşteri ne kazanır.',
      'whatCustomerEarns': 'Müşteri ne kazanır?',
      'discountPercentLabel': 'İndirim yüzdesi (%)',
      'amountManatLabel': 'Tutar (₼)',
      'egFifty': 'örn. 50',
      'egFive': 'örn. 5',
      'validNumber': 'Geçerli bir sayı gir',
      'range0to100': '0–100 arasında olmalı',
      'whichProduct': 'Hangi ürün için?',
      'productExampleHint': 'örn. kahve, burger, manikür',
      'enterProduct': 'Ürünü gir',
      'howManyStamps': 'Kaç damga gerekli?',
      'nameYourProgram': 'Programına ad ver',
      'programNameLabel': 'Program adı',
      'programNameHint': 'örn. 5 al, 6. bedava',
      'descriptionOptional': 'Açıklama (isteğe bağlı)',
      'descriptionShortHint': 'Müşterinin göreceği kısa açıklama',
      'enterName2': 'Bir ad gir',
      'createAction': 'Oluştur',
      'previewWord': 'Önizleme',
      'newProgramPlaceholder': 'Yeni program',
      'addReward': 'Ödül ekle',
      'rewardNameHint': 'Ad — örn. San Sebastian',
      'descOptionalHint': 'Açıklama (isteğe bağlı)',
      'howManyCoinHint': 'Kaç coin',
      'nameAndValidCoin': 'Bir ad ve geçerli coin miktarı gir',
      'coinGiftsSub': 'Coin ile alınan hediyeler (damga programlarından ayrı).',
      'noRewardsYetHint':
          'Henüz ödül yok. «Ekle» ile oluştur — örn. 100 coin = 1 San Sebastian.',
      'usersTitle': 'Kullanıcılar',
      'businessesTitle': 'İşletmeler',
      'searchBusinessName': 'İşletme adı ara',
      'searchTryAgain': 'Aramanı değiştir ve tekrar dene.',
      'reviewWord': 'yorum',
      'featuredLabel': 'Öne çıkan',
      'failedColon': 'Başarısız',
      'titleAndBodyRequired': 'Başlık ve metin gir',
      'notifSentToAll': 'Bildirim herkese gönderildi ✓',
      'sendNotification': 'Bildirim gönder',
      'notifReachAll':
          'Tüm kullanıcılara ulaşacak ve bildirim kutularında görünecek.',
      'titleLabel': 'Başlık',
      'bodyLabel': 'Metin',
      'sendingWord': 'Gönderiliyor...',
      'sendToAll': 'Herkese gönder',
      'sentItems': 'Gönderilenler',
      'noNotifSent': 'Henüz bildirim gönderilmedi.',
      'coinAdjustment': 'Coin düzenlemesi',
      'coinControl': 'Coin kontrolü',
      'recentTransactions': 'Son işlemler',
      'noTransactions': 'İşlem yok',
      'transactionsWillShow': 'Coin hareketleri burada görünecek.',
      'inCirculation': 'Dolaşımda',
      'transactionWord': 'İşlemler',
      'unknownParen': '(bilinmiyor)',
      'adjustPositiveNegative':
          'Pozitif değer coin ekler, negatif değer çıkarır.',
      'pickUserAndAmount':
          'Bir kullanıcı seç ve sıfırdan farklı bir tutar gir.',
      'searchUserByEmail': 'E-posta ile kullanıcı bul',
      'amountExample': 'Tutar (örn. 500 veya -200)',
      'noteOptional': 'Not (isteğe bağlı)',
      'applyingWord': 'Uygulanıyor...',
      'applyAction': 'Uygula',
      'usersLabel': 'Kullanıcılar',
      'businessLabel': 'İşletmeler',
      'newAd': 'Yeni reklam',
      'noAdsYet': 'Henüz reklam yok',
      'createFirstBanner': '«Yeni reklam» ile ilk afişini oluştur.',
      'deleteAdTitle': 'Reklam silinsin mi?',
      'deleteFailed': 'Silme başarısız',
      'activeWord': 'Aktif',
      'inactiveWord': 'Pasif',
      'tagAndTitleRequired': 'Etiket ve başlık gerekli',
      'editAd': 'Reklamı düzenle',
      'tagLabel': 'Etiket',
      'tagHint': 'örn. YENİ, İNDİRİM',
      'subtitleLabel': 'Alt başlık',
      'emojiLabel': 'Emoji',
      'buttonTextLabel': 'Buton metni',
      'colorLabel': 'Renk',
      'savingWord': 'Kaydediliyor...',
      'titleFallback': 'Başlık',
      'addFood': 'Yemek ekle',
      'selectBusiness': 'Bir işletme seç',
      'menuLinkSaved': 'Menü bağlantısı kaydedildi ✓',
      'menuLinkDesc':
          'PDF / site / görsel bağlantısı. Yapılandırılmış menü yoksa gösterilir.',
      'saveShort': 'Kaydet',
      'structuredMenu': 'Yapılandırılmış menü (kategoriler)',
      'noFoodYet':
          'Henüz yemek yok. «Yemek ekle» ile kategorili menü oluştur (örn. «Kahveler», «Tatlılar»).',
      'categoryAndNameRequired': 'Kategori ve ad gerekli',
      'categoryLabel': 'Kategori',
      'categoryHint': 'örn. Kahveler, Ana yemekler',
      'descriptionOptionalField': 'Açıklama (isteğe bağlı)',
      'priceOptional': 'Fiyat (₼, isteğe bağlı)',
      'discoverCardHint': 'Favori mekanını Keşfet\'te bul ve kartını al.',
      'coinBalanceNotLoaded': 'Coin bakiyesi yüklenemedi',
      'myCoinBalance': 'Coin bakiyem',
      'scanQr': 'QR\'ı tara',
      'holdCustomerQr': 'Müşterinin QR kodunu çerçeveye tut',
      'autoDetected': 'Otomatik algılandı',
      'createBusinessFirst': 'Taramak için önce işletmeni oluştur.',
      'customerFound': 'Müşteri bulundu',
      'activeRewards': 'Aktif ödüller',
      'giveStamp': 'Damga ver',
      'giveCoin': 'Coin ver',
      'stampRewardLabel': 'Damga ödülü',
      'useAction': 'Kullan',
      'howManyCoinQ': 'Kaç coin?',
      'amountWord': 'Tutar',
      'giveAction': 'Ver',
      'noStories': 'Hikaye yok',
      'signOutBody':
          'Hesabından çıkış yapacaksın. Tekrar giriş yaparak dönebilirsin.',
      'deleteAccountTitle': 'Hesabını sil?',
      'deleteAccountBody':
          'Bu, hesabını kalıcı olarak siler. Profil verilerin silinir ve bu geri alınamaz.\n\nKazandığın coinler ve kartlar da erişilemez olur.',
      'accountDeleteFailed': 'Hesap silme başarısız',
      'phoneWord': 'Telefon',
      'whatsappSub': 'Mesaj gönder — 5 dakika içinde yanıtlarız',
      'aboutBody':
          'Bir sadakat ve müşteri takip platformu — kafeler, restoranlar ve salonlar için.',
      'allRightsReserved': '© 2026 Qazan. Tüm hakları saklıdır.',
      'notifActiveSuffix': 'aktif',
      'rewardsActiveTab': 'Aktif',
      'rewardsUsedTab': 'Kullanılan',
      'noActiveRewards': 'Henüz aktif ödül yok',
      'noActiveRewardsSub':
          'İşletme sayfasında coin ile hediye al veya bir damga kartını tamamla.',
      'noUsageHistory': 'Henüz kullanım geçmişi yok',
      'noUsageHistorySub': 'Kasada kullandığın hediyeler burada görünecek.',
      'coinLabel': 'Coin',
      'stampLabel': 'Damga',
      'showQrCashier': 'Kasadan teslim al',
      'usedPrefix': 'Kullanıldı',
      'nowWord': 'şimdi',
      'minAgo': 'dk önce',
      'hourAgo': 'sa önce',
      'dayAgo': 'g önce',
      'noNotifications': 'Bildirim yok',
      'newNotifsHere': 'Yeni bildirimler burada görünecek.',
      'menuWord': 'Menü',
      'fullMenu': 'Tüm menü',
      'showQr': 'QR göster',
      'campaigns': 'Kampanyalar',
      'noCampaignYet': 'Henüz kampanya yok',
      'campaignComingSoon': 'Bu mekan yakında teklifler ekleyecek.',
      'joinCampaign': 'Kampanyaya katıl',
      'buyWithCoin': 'Coin ile al',
      'buyWithCoinHint':
          '"Al" düğmesine bas — coin düşülür, hediye Hediyelerim\'e eklenir. Sonra kasadan teslim alırsın.',
      'buyAction': 'Al',
      'insufficientWord': 'Yetersiz',
      'mAway': 'm uzakta',
      'kmAway': 'km uzakta',
      'errorOccurred': 'Bir hata oluştu',
      'helloName': 'Merhaba',
      'whereEarnToday': 'Bugün nereden kazanalım?',
      'friendFallback': 'Dost',
      'allPlaces': 'Tüm mekanlar',
      'nothingFoundHint': 'Filtreyi değiştir veya başka bir kelime ara.',
      'directions': 'Yol tarifi',
      'reviewsNotLoaded': 'Yorumlar yüklenemedi',
      'reviewsWord': 'Yorumlar',
      'noReviewsYet': 'Henüz yorum yok. İlk yorumu sen yaz!',
      'writeReview': 'Yorum yaz',
      'editReview': 'Yorumunu düzenle',
      'youParen': 'sen',
      'rateExperience': 'Deneyimini değerlendir',
      'reviewHint': 'Yorumun (isteğe bağlı)…',
      'sendAction': 'Gönder',
      'reviewThanks': 'Yorumun için teşekkürler ✓',
      'atLeastOneStar': 'En az 1 yıldız seç',
      'memberSinceLabel': 'Müşteri',
      'myQrTitle': 'QR kodum',
      'showThisCodeHint': 'Bu kodu mekanda göster — damgan otomatik eklenir.',
      'stampWordShort': 'damga',
      'coinGivenSuffix': 'coin müşteriye verildi',
      'usedSuffixCheck': 'kullanıldı ✓',
      'scanBonusNote': 'Tarama bonusu',
      'willBeDeletedSuffix': 'silinecek.',
      'rewardsWaitSuffix': 'ödül seni bekliyor!',
      'catCoffee': 'Kafe & Kahve',
      'catCoffeeShort': 'Kafe',
      'catRestaurant': 'Restoran',
      'catBeauty': 'Güzellik',
      'catBarber': 'Berber',
      'catCarwash': 'Oto yıkama',
      'catFitness': 'Fitness',
      'catBakery': 'Pastane',
      'catOther': 'Diğer',
      'scanTapHint': 'Tek dokunuş — damga otomatik eklenir.',
      'firstCustomerHint':
          'Kartı ilk kez bir müşterinin telefonuna değdirdiğinde burada görünür.',
      'daysLeftSuffix': 'gün kaldı',
      'hoursLeftSuffix': 'saat kaldı',
      'minsLeftSuffix': 'dk kaldı',
      'rewardFreeItem': 'Ücretsiz ürün',
      'rewardPercentDiscount': 'Yüzde indirim',
      'rewardFixedDiscount': 'Sabit indirim',
      'rewardCashback': 'Cashback',
      'freeWord': 'ücretsiz',
      'onWord': 'için',
      'discountWord': 'indirim',
      'productFallback': 'ürün',
      'onbTitle1': 'Sevdiğin yerlerden kazan',
      'onbSub1':
          'Kafeleri, restoranları, salonları keşfet — her ziyaret sana bonus getirsin.',
      'onbSub2': 'Kasiyer kartı telefonuna değdirir — damga ve puan otomatik yazılır.',
      'onbTitle3': 'Ödülleri topla',
      'onbSub3': '6. kahve bizden — sana özel tekliflerle kazan.',
      'getStarted': 'Başlayalım',
      'continueAction': 'Devam et',
      'roleMismatchBusiness':
          'Bu giriş işletme hesapları içindir. Müşteri hesabıyla «Ben müşteriyim» bölümünden giriş yap.',
      'roleMismatchCustomer':
          'Bu giriş müşteri hesapları içindir. İşletme hesabıyla «Ben işletmeyim» bölümünden giriş yap.',
    },
  };
}

/// Reflects the currently selected language; rebuilds dependents on change.
final Provider<S> sProvider =
    Provider<S>((Ref ref) => S(ref.watch(languageProvider)));
