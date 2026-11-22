// Strings added for phone sign-up, the cashier window and the panels.
// Same contract as strings.dart: a missing translation falls back to the
// Azerbaijani text in the getter.
import 'strings.dart';

extension PanelStrings on S {
  String _p(String key, String az) => _panel[lang]?[key] ?? az;

  /// "Step 2 of 3".
  String stepOf(int step, int total) => switch (lang) {
        'en' => 'Step $step of $total',
        'ru' => 'Шаг $step из $total',
        'tr' => 'Adım $step / $total',
        _ => 'Addım $step / $total',
      };

  String get networkError => _p('networkError', 'Serverlə əlaqə qurulmadı. İnterneti yoxla.');
  String get phoneRequired => _p('phoneRequired', 'Telefon nömrəsini daxil et');
  String get regPhoneTitle => _p('regPhoneTitle', 'Telefon nömrən');
  String get regPhoneSub => _p('regPhoneSub', 'Başlamaq üçün nömrəni yaz.');
  String get phoneAlreadyRegistered => _p('phoneAlreadyRegistered', 'Bu nömrə artıq qeydiyyatdadır. Daxil ol.');
  String get regVerifyTitle => _p('regVerifyTitle', 'Nömrəni təsdiqlə');
  String get regVerifySub => _p('regVerifySub', 'Kodu bu nömrəyə göndərdik:');
  String get regVerifyCode => _p('regVerifyCode', 'Təsdiq kodu');
  String get regDetailsTitle => _p('regDetailsTitle', 'Özün haqqında');
  String get firstName => _p('firstName', 'Ad');
  String get lastName => _p('lastName', 'Soyad');
  String get regPasswordTitle => _p('regPasswordTitle', 'Şifrə yarat');
  String get regPasswordSub => _p('regPasswordSub', 'Növbəti girişlərdə lazım olacaq.');
  String get birthDateLabel => _p('birthDateLabel', 'Doğum tarixi');
  String get birthDateRequired => _p('birthDateRequired', 'Doğum tarixini seç');
  String get socialSignInFailed => _p('socialSignInFailed', 'Giriş alınmadı. Yenidən cəhd et.');
  String get orContinueWith => _p('orContinueWith', 'və ya');
  // Onboarding: title = a + highlighted b + c.
  String get onb1a => _p('onb1a', 'Sevdiyin yerlərdən ');
  String get onb1b => _p('onb1b', 'qazan');
  String get onb1c => _p('onb1c', '');
  String get onb2a => _p('onb2a', 'Kartını ');
  String get onb2b => _p('onb2b', 'NFC');
  String get onb2c => _p('onb2c', ' ilə oxut');
  String get onb3a => _p('onb3a', 'Mükafatlarını topla və istifadə et');
  String get onb3b => _p('onb3b', '');
  String get onb3c => _p('onb3c', '');
  String get onbBody1 => _p('onbBody1', 'Kafe, restoran, salon və daha çox məkanda alış-veriş et, xüsusi mükafatlar qazan.');
  String get onbBody2 => _p('onbBody2', 'Telefonunu kassadakı Qazan NFC kartına yaxınlaşdır, xalların dərhal yazılsın.');
  String get onbBody3 => _p('onbBody3', 'Topladığın xallarla xüsusi endirimlər, hədiyyələr və sürpriz üstünlüklərdən yararlan.');
  String get aboutTab => _p('aboutTab', 'Haqqında');
  String get brandSubtitle => _p('brandSubtitle', 'Müştəri sadiqlik platforması');
  String get loginTagline => _p('loginTagline', 'Xal qazan, üstünlüklərdən yararlan və sənə özəl kampaniyaları qaçırma.');
  String get signInWithGoogle => _p('signInWithGoogle', 'Google ilə daxil ol');
  String get signInWithApple => _p('signInWithApple', 'Apple ilə daxil ol');
  String get continueWithGoogle => _p('continueWithGoogle', 'Google ilə davam et');
  String get continueWithApple => _p('continueWithApple', 'Apple ilə davam et');
  String get completeProfileTitle => _p('completeProfileTitle', 'Son bir addım');
  String get completeProfileSub => _p('completeProfileSub', 'Məkanların səni tapa bilməsi üçün telefon nömrəni əlavə et.');
  String get businessOnlyTitle => _p('businessOnlyTitle', 'Bu tətbiq bizneslər üçündür');
  String get businessOnlyBody => _p('businessOnlyBody', 'Biznes sahibi və ya kassir hesabı ilə daxil ol.');
  String get phoneOrEmail => _p('phoneOrEmail', 'Telefon və ya e-poçt');
  String get phoneOrEmailHint => _p('phoneOrEmailHint', '+994 50 123 45 67');
  String get phoneOrEmailInvalid => _p('phoneOrEmailInvalid', 'Düzgün telefon və ya e-poçt yaz');
  String get rewardUsedTitle => _p('rewardUsedTitle', 'Hədiyyən istifadə olundu');
  String get viewMyRewards => _p('viewMyRewards', 'Hədiyyələrim');
  String get spendWaitingTitle => _p('spendWaitingTitle', 'Kassa');
  String get spendWaitingBody => _p('spendWaitingBody', 'Kassir hədiyyəni təsdiqləyir...');
  String get spendFinished => _p('spendFinished', 'Tamamlandı');
  String get spendYourRewards => _p('spendYourRewards', 'Hədiyyələrin');
  String get spendUsedNow => _p('spendUsedNow', 'İstifadə olundu');
  String get nfcCancelled => _p('nfcCancelled', 'Oxuma ləğv edildi.');
  String get nfcStartScan => _p('nfcStartScan', 'Oxutmağa başla');
  String get nfcIdleBody => _p('nfcIdleBody',
      'Hazır olanda düyməyə bas və telefonu kassadakı karta yaxınlaşdır.');
  String get nfcHoldCard => _p('nfcHoldCard', 'Kartı telefonun arxasına yaxınlaşdır');
  String get nfcScanCard => _p('nfcScanCard', 'Kartı oxut');
  String get nfcNeedsAssign => _p('nfcNeedsAssign', 'Hələ təyin edilməyib');
  String get nfcAssignAction => _p('nfcAssignAction', 'Təyin et');
  String get nfcAssignTitle => _p('nfcAssignTitle', 'Bu kart nə etsin?');
  String get nfcStampsPerTap => _p('nfcStampsPerTap', 'Hər oxunuşda möhür');
  String get nfcKindSpend => _p('nfcKindSpend', 'Xərcləmə');
  String get nfcKindUnassigned => _p('nfcKindUnassigned', 'Təyinsiz');
  String get nfcExplainStamp => _p('nfcExplainStamp', 'Müştəri bu kampaniyadan möhür qazanır.');
  String get nfcExplainPoints => _p('nfcExplainPoints', 'Müştəri sabit coin qazanır.');
  String get nfcExplainSpend => _p('nfcExplainSpend', 'Müştərinin pəncərəsi kassada açılır.');
  String get nfcLabelHint => _p('nfcLabelHint', 'Kassa 1');
  String get statusActive => _p('statusActive', 'Aktiv');
  String get statusLost => _p('statusLost', 'İtib');
  String get statusRevoked => _p('statusRevoked', 'Ləğv edilib');
  String get statusSuspended => _p('statusSuspended', 'Dayandırılıb');
  String get statusPending => _p('statusPending', 'Gözləyir');
  String get statusApproved => _p('statusApproved', 'Təsdiqlənib');
  String get statusRejected => _p('statusRejected', 'Rədd edilib');
  String get nfcResCooldown => _p('nfcResCooldown', 'Çox tez oxudulub');
  String get nfcResDailyCap => _p('nfcResDailyCap', 'Günlük limit');
  String get nfcResOutOfRange => _p('nfcResOutOfRange', 'Məkandan uzaq');
  String get nfcResBadCard => _p('nfcResBadCard', 'Tanınmayan kart');
  String get nfcResOther => _p('nfcResOther', 'Rədd edilib');
  String get cashierCards => _p('cashierCards', 'Kartları');
  String get cashierRewards => _p('cashierRewards', 'Hədiyyələri');
  String get cashierNoRewardsLeft => _p('cashierNoRewardsLeft', 'İstifadə ediləcək hədiyyə qalmadı.');
  String get markUsed => _p('markUsed', 'İstifadə olundu');
  String get cashierWindow => _p('cashierWindow', 'Kassa');
  String get cashierAtTill => _p('cashierAtTill', 'Kassada gözləyənlər');
  String get manualTitle => _p('manualTitle', 'Əl ilə əlavə et');
  String get manualTab => _p('manualTab', 'Əl ilə');
  String get manualHint => _p('manualHint', 'Kart oxudula bilmirsə, müştərini nömrəsi ilə tap.');
  String get manualFind => _p('manualFind', 'Müştərini tap');
  String get manualNotFound => _p('manualNotFound', 'Bu nömrə ilə müştəri yoxdur');
  String get manualAdd => _p('manualAdd', 'Əlavə et');
  String get manualDone => _p('manualDone', 'əlavə olundu');
  String get manualPickProgram => _p('manualPickProgram', 'Kampaniya seç');
  String get manualBadAmount => _p('manualBadAmount', 'Dəyəri yoxla');
  String get staffTitle => _p('staffTitle', 'Kassirlər');
  String get staffAdd => _p('staffAdd', 'Kassir əlavə et');
  String get staffEmpty => _p('staffEmpty', 'Hələ kassir yoxdur');
  String get staffEmptyHint => _p('staffEmptyHint', 'Kassir yalnız kassa ekranını görür.');
  String get staffRemoveTitle => _p('staffRemoveTitle', 'Kassir silinsin?');
  String get analyticsTitle => _p('analyticsTitle', 'Hesabatlar');
  String get daysWord => _p('daysWord', 'gün');
  String get anNewCustomers => _p('anNewCustomers', 'Yeni müştəri');
  String get anActiveCustomers => _p('anActiveCustomers', 'Aktiv müştəri');
  String get anReturning => _p('anReturning', 'Qayıdan müştəri');
  String get anStamps => _p('anStamps', 'Möhür');
  String get anRewards => _p('anRewards', 'Hədiyyə');
  String get anCoinsEarned => _p('anCoinsEarned', 'Qazanılan coin');
  String get anCoinsSpent => _p('anCoinsSpent', 'Xərclənən coin');
  String get anNfcAccepted => _p('anNfcAccepted', 'Qəbul edilən oxunuş');
  String get anNfcRejected => _p('anNfcRejected', 'Rədd edilən oxunuş');
  String get anDailyTrend => _p('anDailyTrend', 'Günlük gedişat');
  String get anPrograms => _p('anPrograms', 'Kampaniyaların nəticəsi');
  String get anNoPrograms => _p('anNoPrograms', 'Hələ kampaniya yoxdur');
  String get anMembers => _p('anMembers', 'Üzv');
  String get anCompleted => _p('anCompleted', 'Tamamlanan');
  String get anRedeemed => _p('anRedeemed', 'İstifadə olunan');
  String get notifyTitle => _p('notifyTitle', 'Müştərilərə bildiriş');
  String get notifyHint => _p('notifyHint', 'Bildiriş kartı olan müştərilərinə admin təsdiqindən sonra gedir.');
  String get notifySend => _p('notifySend', 'Təsdiqə göndər');
  String get notifySubmitted => _p('notifySubmitted', 'Təsdiqə göndərildi');
  String get notifyMine => _p('notifyMine', 'Göndərdiklərim');
  String get programExpiry => _p('programExpiry', 'Bitmə tarixi');
  String get programNoExpiry => _p('programNoExpiry', 'Müddətsiz');
  String get companyPendingTitle => _p('companyPendingTitle', 'Biznesin təsdiq gözləyir');
  String get companyPendingBody => _p('companyPendingBody', 'Təsdiqlənənə qədər müştərilər onu görə bilməz və kartlar işləməz.');
  String get companySuspendedTitle => _p('companySuspendedTitle', 'Biznesin dayandırılıb');
  String get companySuspendedBody => _p('companySuspendedBody', 'Ətraflı məlumat üçün dəstəklə əlaqə saxla.');
  String get companySuspend => _p('companySuspend', 'Dayandır');
  String get companyApprove => _p('companyApprove', 'Təsdiqlə');
  String get companyDetailTitle => _p('companyDetailTitle', 'Biznes');
  String get reasonLabel => _p('reasonLabel', 'Səbəb');
  String get auditTitle => _p('auditTitle', 'Əməliyyat jurnalı');
  String get auditEmpty => _p('auditEmpty', 'Hələ qeyd yoxdur');
  String get userDetailTitle => _p('userDetailTitle', 'İstifadəçi');
  String get resetPasswordAction => _p('resetPasswordAction', 'Şifrəni sıfırla');
  String get passwordResetDone => _p('passwordResetDone', 'Şifrə dəyişdirildi');
  String get lastLoginLabel => _p('lastLoginLabel', 'Son giriş');
  String get createUserAction => _p('createUserAction', 'İstifadəçi yarat');
  String get roleCashier => _p('roleCashier', 'Kassir');
  String get pendingCompaniesLabel => _p('pendingCompaniesLabel', 'Təsdiq gözləyən biznes');
  String get pendingNotificationsLabel => _p('pendingNotificationsLabel', 'Təsdiq gözləyən bildiriş');
  String get activeUsers30dLabel => _p('activeUsers30dLabel', 'Aktiv (30 gün)');
  String get new7dLabel => _p('new7dLabel', 'Yeni istifadəçi / biznes (7 gün)');
  String get signupsChartTitle => _p('signupsChartTitle', 'Qeydiyyatlar');
  String get coinsByCompanyTitle => _p('coinsByCompanyTitle', 'Bizneslər üzrə coin (30 gün)');
  String get grantsLabel => _p('grantsLabel', 'Əl ilə verilən');
  String get rejectAction => _p('rejectAction', 'Rədd et');
  String get approveAction => _p('approveAction', 'Təsdiqlə');
  String get promoCompany => _p('promoCompany', 'Biznes');
  String get promoNoCompany => _p('promoNoCompany', 'Bağlı deyil');
  String get promoEndsAt => _p('promoEndsAt', 'Bitmə tarixi');
  // Customer-side fixes.
  String get cardNotLoaded => _p('cardNotLoaded', 'Kart yüklənmədi');
  String get coinUnit => _p('coinUnit', 'coin');
  String get couldNotOpenLink => _p('couldNotOpenLink', 'Açmaq alınmadı');
  String get nfcAlreadyCounted => _p('nfcAlreadyCounted', 'Bu oxutma artıq qeydə alınıb');
  String get favoriteSemantic => _p('favoriteSemantic', 'Sevimli');
}

const Map<String, Map<String, String>> _panel = <String, Map<String, String>>{
  'en': <String, String>{
    'networkError': 'Could not reach the server. Check your connection.',
    'phoneRequired': 'Enter your phone number',
    'regPhoneTitle': 'Your phone number',
    'regPhoneSub': 'Enter your number to get started.',
    'phoneAlreadyRegistered': 'This number is already registered. Please sign in.',
    'regVerifyTitle': 'Verify your number',
    'regVerifySub': 'We sent a code to',
    'regVerifyCode': 'Verification code',
    'regDetailsTitle': 'About you',
    'firstName': 'First name',
    'lastName': 'Last name',
    'regPasswordTitle': 'Create a password',
    'regPasswordSub': 'You will use it to sign in.',
    'birthDateLabel': 'Date of birth',
    'birthDateRequired': 'Pick your date of birth',
    'socialSignInFailed': 'Sign-in failed. Please try again.',
    'orContinueWith': 'or',
    'onb1a': '',
    'onb1b': 'Earn',
    'onb1c': ' at the places you love',
    'onb2a': 'Scan your card with ',
    'onb2b': 'NFC',
    'onb2c': '',
    'onb3a': 'Collect and use your rewards',
    'onb3b': '',
    'onb3c': '',
    'onbBody1': 'Shop at cafés, restaurants, salons and more — and earn special rewards.',
    'onbBody2': 'Hold your phone to the Qazan NFC card at the till — points land instantly.',
    'onbBody3': 'Use your points for exclusive discounts, gifts and surprise perks.',
    'aboutTab': 'About',
    'brandSubtitle': 'Customer loyalty platform',
    'loginTagline': 'Earn points, enjoy perks and never miss the offers made for you.',
    'signInWithGoogle': 'Sign in with Google',
    'signInWithApple': 'Sign in with Apple',
    'continueWithGoogle': 'Continue with Google',
    'continueWithApple': 'Continue with Apple',
    'completeProfileTitle': 'One last step',
    'completeProfileSub': 'Add your phone number so venues can find you.',
    'businessOnlyTitle': 'This app is for businesses',
    'businessOnlyBody': 'Sign in with an owner or cashier account.',
    'phoneOrEmail': 'Phone or email',
    'phoneOrEmailHint': '+994 50 123 45 67',
    'phoneOrEmailInvalid': 'Enter a valid phone or email',
    'rewardUsedTitle': 'Reward used',
    'viewMyRewards': 'My rewards',
    'spendWaitingTitle': 'At the till',
    'spendWaitingBody': 'The cashier is confirming your reward...',
    'spendFinished': 'Done',
    'spendYourRewards': 'Your rewards',
    'spendUsedNow': 'Used',
    'nfcCancelled': 'Reading was cancelled.',
    'nfcStartScan': 'Start scanning',
    'nfcIdleBody': 'When you are ready, tap the button and hold your phone to the card at the counter.',
    'nfcHoldCard': 'Hold the card to the back of the phone',
    'nfcScanCard': 'Scan a card',
    'nfcNeedsAssign': 'Not set up yet',
    'nfcAssignAction': 'Set up',
    'nfcAssignTitle': 'What should this card do?',
    'nfcStampsPerTap': 'Stamps per tap',
    'nfcKindSpend': 'Spend',
    'nfcKindUnassigned': 'Unassigned',
    'nfcExplainStamp': 'The customer earns a stamp in this campaign.',
    'nfcExplainPoints': 'The customer earns a fixed number of coins.',
    'nfcExplainSpend': 'Opens the customer window at the till.',
    'nfcLabelHint': 'Till 1',
    'statusActive': 'Active',
    'statusLost': 'Lost',
    'statusRevoked': 'Revoked',
    'statusSuspended': 'Suspended',
    'statusPending': 'Pending',
    'statusApproved': 'Approved',
    'statusRejected': 'Rejected',
    'nfcResCooldown': 'Tapped too soon',
    'nfcResDailyCap': 'Daily limit',
    'nfcResOutOfRange': 'Away from venue',
    'nfcResBadCard': 'Unrecognized card',
    'nfcResOther': 'Rejected',
    'cashierCards': 'Cards',
    'cashierRewards': 'Rewards',
    'cashierNoRewardsLeft': 'No rewards left to use.',
    'markUsed': 'Mark used',
    'cashierWindow': 'Till',
    'cashierAtTill': 'Waiting at the till',
    'manualTitle': 'Add manually',
    'manualTab': 'Manual',
    'manualHint': 'If a card cannot be tapped, find the customer by number.',
    'manualFind': 'Find customer',
    'manualNotFound': 'No customer with this number',
    'manualAdd': 'Add',
    'manualDone': 'added',
    'manualPickProgram': 'Pick a campaign',
    'manualBadAmount': 'Check the value',
    'staffTitle': 'Cashiers',
    'staffAdd': 'Add cashier',
    'staffEmpty': 'No cashiers yet',
    'staffEmptyHint': 'A cashier only sees the till.',
    'staffRemoveTitle': 'Remove this cashier?',
    'analyticsTitle': 'Reports',
    'daysWord': 'days',
    'anNewCustomers': 'New customers',
    'anActiveCustomers': 'Active customers',
    'anReturning': 'Returning',
    'anStamps': 'Stamps',
    'anRewards': 'Rewards',
    'anCoinsEarned': 'Coins earned',
    'anCoinsSpent': 'Coins spent',
    'anNfcAccepted': 'Accepted taps',
    'anNfcRejected': 'Rejected taps',
    'anDailyTrend': 'Daily trend',
    'anPrograms': 'Campaign results',
    'anNoPrograms': 'No campaigns yet',
    'anMembers': 'Members',
    'anCompleted': 'Completed',
    'anRedeemed': 'Redeemed',
    'notifyTitle': 'Notify customers',
    'notifyHint': 'Sent to your cardholders after admin approval.',
    'notifySend': 'Send for approval',
    'notifySubmitted': 'Sent for approval',
    'notifyMine': 'My submissions',
    'programExpiry': 'End date',
    'programNoExpiry': 'No end date',
    'companyPendingTitle': 'Your business is awaiting approval',
    'companyPendingBody': 'Until approved, customers cannot see it and cards will not work.',
    'companySuspendedTitle': 'Your business is suspended',
    'companySuspendedBody': 'Contact support for details.',
    'companySuspend': 'Suspend',
    'companyApprove': 'Approve',
    'companyDetailTitle': 'Business',
    'reasonLabel': 'Reason',
    'auditTitle': 'Activity log',
    'auditEmpty': 'No entries yet',
    'userDetailTitle': 'User details',
    'resetPasswordAction': 'Reset password',
    'passwordResetDone': 'Password changed',
    'lastLoginLabel': 'Last sign-in',
    'createUserAction': 'Create user',
    'roleCashier': 'Cashier',
    'pendingCompaniesLabel': 'Businesses to approve',
    'pendingNotificationsLabel': 'Notifications to approve',
    'activeUsers30dLabel': 'Active (30 days)',
    'new7dLabel': 'New users / businesses (7 days)',
    'signupsChartTitle': 'Sign-ups',
    'coinsByCompanyTitle': 'Coins by business (30 days)',
    'grantsLabel': 'Manual grants',
    'rejectAction': 'Reject',
    'approveAction': 'Approve',
    'promoCompany': 'Business',
    'promoNoCompany': 'Not linked',
    'promoEndsAt': 'End date',
    'cardNotLoaded': 'Card could not be loaded',
    'coinUnit': 'coins',
    'couldNotOpenLink': 'Could not open',
    'nfcAlreadyCounted': 'This tap is already counted',
    'favoriteSemantic': 'Favorite',
  },
  'ru': <String, String>{
    'networkError': 'Не удалось связаться с сервером. Проверьте интернет.',
    'phoneRequired': 'Введите номер телефона',
    'regPhoneTitle': 'Ваш номер телефона',
    'regPhoneSub': 'Введите номер, чтобы начать.',
    'phoneAlreadyRegistered': 'Этот номер уже зарегистрирован. Войдите.',
    'regVerifyTitle': 'Подтвердите номер',
    'regVerifySub': 'Мы отправили код на',
    'regVerifyCode': 'Код подтверждения',
    'regDetailsTitle': 'О вас',
    'firstName': 'Имя',
    'lastName': 'Фамилия',
    'regPasswordTitle': 'Создайте пароль',
    'regPasswordSub': 'Он понадобится для входа.',
    'birthDateLabel': 'Дата рождения',
    'birthDateRequired': 'Выберите дату рождения',
    'socialSignInFailed': 'Не удалось войти. Попробуйте снова.',
    'orContinueWith': 'или',
    'onb1a': '',
    'onb1b': 'Зарабатывайте',
    'onb1c': ' в любимых местах',
    'onb2a': 'Сканируйте карту через ',
    'onb2b': 'NFC',
    'onb2c': '',
    'onb3a': 'Собирайте и тратьте награды',
    'onb3b': '',
    'onb3c': '',
    'onbBody1': 'Покупайте в кафе, ресторанах, салонах и других местах — получайте особые награды.',
    'onbBody2': 'Поднесите телефон к NFC-карте Qazan на кассе — баллы начислятся сразу.',
    'onbBody3': 'Тратьте баллы на скидки, подарки и приятные сюрпризы.',
    'aboutTab': 'О месте',
    'brandSubtitle': 'Платформа лояльности клиентов',
    'loginTagline': 'Копите баллы, пользуйтесь привилегиями и не пропускайте персональные акции.',
    'signInWithGoogle': 'Войти через Google',
    'signInWithApple': 'Войти через Apple',
    'continueWithGoogle': 'Продолжить с Google',
    'continueWithApple': 'Продолжить с Apple',
    'completeProfileTitle': 'Последний шаг',
    'completeProfileSub': 'Добавьте номер телефона, чтобы заведения могли вас найти.',
    'businessOnlyTitle': 'Это приложение для бизнеса',
    'businessOnlyBody': 'Войдите как владелец или кассир.',
    'phoneOrEmail': 'Телефон или эл. почта',
    'phoneOrEmailHint': '+994 50 123 45 67',
    'phoneOrEmailInvalid': 'Введите корректный телефон или эл. почту',
    'rewardUsedTitle': 'Подарок использован',
    'viewMyRewards': 'Мои подарки',
    'spendWaitingTitle': 'Касса',
    'spendWaitingBody': 'Кассир подтверждает подарок...',
    'spendFinished': 'Готово',
    'spendYourRewards': 'Ваши подарки',
    'spendUsedNow': 'Использовано',
    'nfcCancelled': 'Чтение отменено.',
    'nfcStartScan': 'Начать сканирование',
    'nfcIdleBody': 'Когда будете готовы, нажмите кнопку и поднесите телефон к карте на кассе.',
    'nfcHoldCard': 'Поднесите карту к задней стороне телефона',
    'nfcScanCard': 'Считать карту',
    'nfcNeedsAssign': 'Ещё не настроена',
    'nfcAssignAction': 'Настроить',
    'nfcAssignTitle': 'Что должна делать эта карта?',
    'nfcStampsPerTap': 'Печатей за касание',
    'nfcKindSpend': 'Списание',
    'nfcKindUnassigned': 'Не назначена',
    'nfcExplainStamp': 'Клиент получает печать в этой кампании.',
    'nfcExplainPoints': 'Клиент получает фиксированное число монет.',
    'nfcExplainSpend': 'Открывает окно клиента на кассе.',
    'nfcLabelHint': 'Касса 1',
    'statusActive': 'Активна',
    'statusLost': 'Утеряна',
    'statusRevoked': 'Отозвана',
    'statusSuspended': 'Приостановлено',
    'statusPending': 'Ожидает',
    'statusApproved': 'Одобрено',
    'statusRejected': 'Отклонено',
    'nfcResCooldown': 'Слишком рано',
    'nfcResDailyCap': 'Дневной лимит',
    'nfcResOutOfRange': 'Вдали от заведения',
    'nfcResBadCard': 'Неизвестная карта',
    'nfcResOther': 'Отклонено',
    'cashierCards': 'Карты',
    'cashierRewards': 'Подарки',
    'cashierNoRewardsLeft': 'Подарков для использования не осталось.',
    'markUsed': 'Использован',
    'cashierWindow': 'Касса',
    'cashierAtTill': 'Ожидают на кассе',
    'manualTitle': 'Добавить вручную',
    'manualTab': 'Вручную',
    'manualHint': 'Если карту нельзя считать, найдите клиента по номеру.',
    'manualFind': 'Найти клиента',
    'manualNotFound': 'Клиент с таким номером не найден',
    'manualAdd': 'Добавить',
    'manualDone': 'добавлено',
    'manualPickProgram': 'Выберите кампанию',
    'manualBadAmount': 'Проверьте значение',
    'staffTitle': 'Кассиры',
    'staffAdd': 'Добавить кассира',
    'staffEmpty': 'Кассиров пока нет',
    'staffEmptyHint': 'Кассир видит только кассу.',
    'staffRemoveTitle': 'Удалить кассира?',
    'analyticsTitle': 'Отчёты',
    'daysWord': 'дн.',
    'anNewCustomers': 'Новые клиенты',
    'anActiveCustomers': 'Активные клиенты',
    'anReturning': 'Вернувшиеся',
    'anStamps': 'Печати',
    'anRewards': 'Подарки',
    'anCoinsEarned': 'Начислено монет',
    'anCoinsSpent': 'Потрачено монет',
    'anNfcAccepted': 'Принятые касания',
    'anNfcRejected': 'Отклонённые касания',
    'anDailyTrend': 'Динамика по дням',
    'anPrograms': 'Результаты кампаний',
    'anNoPrograms': 'Кампаний пока нет',
    'anMembers': 'Участники',
    'anCompleted': 'Завершено',
    'anRedeemed': 'Использовано',
    'notifyTitle': 'Уведомить клиентов',
    'notifyHint': 'Отправляется держателям карт после одобрения администратором.',
    'notifySend': 'Отправить на одобрение',
    'notifySubmitted': 'Отправлено на одобрение',
    'notifyMine': 'Мои отправки',
    'programExpiry': 'Дата окончания',
    'programNoExpiry': 'Без срока',
    'companyPendingTitle': 'Ваш бизнес ожидает одобрения',
    'companyPendingBody': 'До одобрения клиенты его не видят, карты не работают.',
    'companySuspendedTitle': 'Ваш бизнес приостановлен',
    'companySuspendedBody': 'Обратитесь в поддержку.',
    'companySuspend': 'Приостановить',
    'companyApprove': 'Одобрить',
    'companyDetailTitle': 'Бизнес',
    'reasonLabel': 'Причина',
    'auditTitle': 'Журнал действий',
    'auditEmpty': 'Записей пока нет',
    'userDetailTitle': 'Пользователь',
    'resetPasswordAction': 'Сбросить пароль',
    'passwordResetDone': 'Пароль изменён',
    'lastLoginLabel': 'Последний вход',
    'createUserAction': 'Создать пользователя',
    'roleCashier': 'Кассир',
    'pendingCompaniesLabel': 'Бизнесы на одобрении',
    'pendingNotificationsLabel': 'Уведомления на одобрении',
    'activeUsers30dLabel': 'Активные (30 дней)',
    'new7dLabel': 'Новые пользователи / бизнесы (7 дней)',
    'signupsChartTitle': 'Регистрации',
    'coinsByCompanyTitle': 'Монеты по бизнесам (30 дней)',
    'grantsLabel': 'Ручные начисления',
    'rejectAction': 'Отклонить',
    'approveAction': 'Одобрить',
    'promoCompany': 'Бизнес',
    'promoNoCompany': 'Не привязано',
    'promoEndsAt': 'Дата окончания',
    'cardNotLoaded': 'Не удалось загрузить карту',
    'coinUnit': 'коинов',
    'couldNotOpenLink': 'Не удалось открыть',
    'nfcAlreadyCounted': 'Это касание уже засчитано',
    'favoriteSemantic': 'Избранное',
  },
  'tr': <String, String>{
    'networkError': 'Sunucuya ulaşılamadı. İnternetini kontrol et.',
    'phoneRequired': 'Telefon numaranı gir',
    'regPhoneTitle': 'Telefon numaranız',
    'regPhoneSub': 'Başlamak için numaranızı girin.',
    'phoneAlreadyRegistered': 'Bu numara zaten kayıtlı. Giriş yap.',
    'regVerifyTitle': 'Numaranı doğrula',
    'regVerifySub': 'Kodu şu numaraya gönderdik:',
    'regVerifyCode': 'Doğrulama kodu',
    'regDetailsTitle': 'Kendin hakkında',
    'firstName': 'Ad',
    'lastName': 'Soyad',
    'regPasswordTitle': 'Şifre oluştur',
    'regPasswordSub': 'Sonraki girişlerde kullanacaksın.',
    'birthDateLabel': 'Doğum tarihi',
    'birthDateRequired': 'Doğum tarihini seç',
    'socialSignInFailed': 'Giriş yapılamadı. Tekrar dene.',
    'orContinueWith': 'veya',
    'onb1a': 'Sevdiğin yerlerden ',
    'onb1b': 'kazan',
    'onb1c': '',
    'onb2a': 'Kartını ',
    'onb2b': 'NFC',
    'onb2c': ' ile okut',
    'onb3a': 'Ödüllerini topla ve kullan',
    'onb3b': '',
    'onb3c': '',
    'onbBody1': 'Kafe, restoran, salon ve daha birçok mekânda alışveriş yap, özel ödüller kazan.',
    'onbBody2': 'Telefonunu kasadaki Qazan NFC kartına yaklaştır, puanların anında yazılsın.',
    'onbBody3': 'Topladığın puanlarla özel indirimler, hediyeler ve sürpriz avantajlardan yararlan.',
    'aboutTab': 'Hakkında',
    'brandSubtitle': 'Müşteri Sadakat Platformu',
    'loginTagline': 'Puan kazanın, özel ödüller ve kampanyalardan yararlanın.',
    'signInWithGoogle': 'Google ile giriş yap',
    'signInWithApple': 'Apple ile giriş yap',
    'continueWithGoogle': 'Google ile devam et',
    'continueWithApple': 'Apple ile devam et',
    'completeProfileTitle': 'Son bir adım',
    'completeProfileSub': 'Mekanların seni bulabilmesi için telefon numaranı ekle.',
    'businessOnlyTitle': 'Bu uygulama işletmeler içindir',
    'businessOnlyBody': 'İşletme sahibi veya kasiyer hesabıyla giriş yap.',
    'phoneOrEmail': 'Telefon veya e-posta',
    'phoneOrEmailHint': '+90 532 123 45 67',
    'phoneOrEmailInvalid': 'Geçerli bir telefon veya e-posta yaz',
    'rewardUsedTitle': 'Hediyen kullanıldı',
    'viewMyRewards': 'Hediyelerim',
    'spendWaitingTitle': 'Kasa',
    'spendWaitingBody': 'Kasiyer hediyeni onaylıyor...',
    'spendFinished': 'Tamamlandı',
    'spendYourRewards': 'Hediyelerin',
    'spendUsedNow': 'Kullanıldı',
    'nfcCancelled': 'Okuma iptal edildi.',
    'nfcStartScan': 'Taramayı başlat',
    'nfcIdleBody': 'Hazır olduğunda düğmeye bas ve telefonu kasadaki karta yaklaştır.',
    'nfcHoldCard': 'Kartı telefonun arkasına yaklaştır',
    'nfcScanCard': 'Kartı okut',
    'nfcNeedsAssign': 'Henüz atanmadı',
    'nfcAssignAction': 'Ata',
    'nfcAssignTitle': 'Bu kart ne yapsın?',
    'nfcStampsPerTap': 'Okutma başına damga',
    'nfcKindSpend': 'Harcama',
    'nfcKindUnassigned': 'Atanmamış',
    'nfcExplainStamp': 'Müşteri bu kampanyadan damga kazanır.',
    'nfcExplainPoints': 'Müşteri sabit coin kazanır.',
    'nfcExplainSpend': 'Müşterinin penceresi kasada açılır.',
    'nfcLabelHint': 'Kasa 1',
    'statusActive': 'Aktif',
    'statusLost': 'Kayıp',
    'statusRevoked': 'İptal edildi',
    'statusSuspended': 'Askıda',
    'statusPending': 'Bekliyor',
    'statusApproved': 'Onaylandı',
    'statusRejected': 'Reddedildi',
    'nfcResCooldown': 'Çok erken okutuldu',
    'nfcResDailyCap': 'Günlük limit',
    'nfcResOutOfRange': 'Mekandan uzak',
    'nfcResBadCard': 'Tanınmayan kart',
    'nfcResOther': 'Reddedildi',
    'cashierCards': 'Kartları',
    'cashierRewards': 'Hediyeleri',
    'cashierNoRewardsLeft': 'Kullanılacak hediye kalmadı.',
    'markUsed': 'Kullanıldı',
    'cashierWindow': 'Kasa',
    'cashierAtTill': 'Kasada bekleyenler',
    'manualTitle': 'Elle ekle',
    'manualTab': 'Elle',
    'manualHint': 'Kart okutulamıyorsa müşteriyi numarasıyla bul.',
    'manualFind': 'Müşteriyi bul',
    'manualNotFound': 'Bu numarayla müşteri yok',
    'manualAdd': 'Ekle',
    'manualDone': 'eklendi',
    'manualPickProgram': 'Kampanya seç',
    'manualBadAmount': 'Değeri kontrol et',
    'staffTitle': 'Kasiyerler',
    'staffAdd': 'Kasiyer ekle',
    'staffEmpty': 'Henüz kasiyer yok',
    'staffEmptyHint': 'Kasiyer yalnızca kasa ekranını görür.',
    'staffRemoveTitle': 'Kasiyer silinsin mi?',
    'analyticsTitle': 'Raporlar',
    'daysWord': 'gün',
    'anNewCustomers': 'Yeni müşteri',
    'anActiveCustomers': 'Aktif müşteri',
    'anReturning': 'Geri gelen',
    'anStamps': 'Damga',
    'anRewards': 'Hediye',
    'anCoinsEarned': 'Kazanılan coin',
    'anCoinsSpent': 'Harcanan coin',
    'anNfcAccepted': 'Kabul edilen okutma',
    'anNfcRejected': 'Reddedilen okutma',
    'anDailyTrend': 'Günlük gidişat',
    'anPrograms': 'Kampanya sonuçları',
    'anNoPrograms': 'Henüz kampanya yok',
    'anMembers': 'Üye',
    'anCompleted': 'Tamamlanan',
    'anRedeemed': 'Kullanılan',
    'notifyTitle': 'Müşterilere bildirim',
    'notifyHint': 'Kart sahibi müşterilerine yönetici onayından sonra gider.',
    'notifySend': 'Onaya gönder',
    'notifySubmitted': 'Onaya gönderildi',
    'notifyMine': 'Gönderdiklerim',
    'programExpiry': 'Bitiş tarihi',
    'programNoExpiry': 'Süresiz',
    'companyPendingTitle': 'İşletmen onay bekliyor',
    'companyPendingBody': 'Onaylanana kadar müşteriler göremez ve kartlar çalışmaz.',
    'companySuspendedTitle': 'İşletmen askıya alındı',
    'companySuspendedBody': 'Ayrıntı için destekle iletişime geç.',
    'companySuspend': 'Askıya al',
    'companyApprove': 'Onayla',
    'companyDetailTitle': 'İşletme',
    'reasonLabel': 'Sebep',
    'auditTitle': 'İşlem günlüğü',
    'auditEmpty': 'Henüz kayıt yok',
    'userDetailTitle': 'Kullanıcı',
    'resetPasswordAction': 'Şifreyi sıfırla',
    'passwordResetDone': 'Şifre değiştirildi',
    'lastLoginLabel': 'Son giriş',
    'createUserAction': 'Kullanıcı oluştur',
    'roleCashier': 'Kasiyer',
    'pendingCompaniesLabel': 'Onay bekleyen işletme',
    'pendingNotificationsLabel': 'Onay bekleyen bildirim',
    'activeUsers30dLabel': 'Aktif (30 gün)',
    'new7dLabel': 'Yeni kullanıcı / işletme (7 gün)',
    'signupsChartTitle': 'Kayıtlar',
    'coinsByCompanyTitle': 'İşletmelere göre coin (30 gün)',
    'grantsLabel': 'Elle verilen',
    'rejectAction': 'Reddet',
    'approveAction': 'Onayla',
    'promoCompany': 'İşletme',
    'promoNoCompany': 'Bağlı değil',
    'promoEndsAt': 'Bitiş tarihi',
    'cardNotLoaded': 'Kart yüklenemedi',
    'coinUnit': 'coin',
    'couldNotOpenLink': 'Açılamadı',
    'nfcAlreadyCounted': 'Bu okutma zaten kaydedildi',
    'favoriteSemantic': 'Favori',
  },
};
