// Friendly titles / bodies for failed screens and empty business states.
// Same contract as strings.dart: missing translations fall back to the
// Azerbaijani text in the getter.
import 'strings.dart';

extension ErrorStrings on S {
  String _r(String key, String az) => _errors[lang]?[key] ?? az;

  String get errOfflineTitle =>
      _r('errOfflineTitle', 'İnternet bağlantısı yoxdur');
  String get errOfflineBody => _r('errOfflineBody',
      'Bağlantını yoxla və yenidən cəhd et. Məlumatların itməyib.');
  String get errServerTitle => _r('errServerTitle', 'Bir az problem yarandı');
  String get errServerBody => _r('errServerBody',
      'Bizim tərəfdə gözlənilməz problem oldu. Bir az sonra yenidən cəhd et.');
  String get errLoadTitle => _r('errLoadTitle', 'Məlumatı yükləyə bilmədik');
  String get errNotFoundTitle =>
      _r('errNotFoundTitle', 'Bu məlumat artıq yoxdur');
  String get errNotFoundBody => _r('errNotFoundBody',
      'Ola bilsin, silinib və ya dəyişdirilib. Geri qayıdıb yenidən yoxla.');
  String get errNoAccessTitle =>
      _r('errNoAccessTitle', 'Bu bölmə sənin üçün bağlıdır');
  String get errNoAccessBody =>
      _r('errNoAccessBody', 'Bu səhifəyə baxmaq üçün icazən yoxdur.');
  String get errGenericBody =>
      _r('errGenericBody', 'Nəsə alınmadı. Bir az sonra yenidən cəhd et.');

  String get bizSetupTitle => _r('bizSetupTitle', 'Biznes profilini yarat');
  String get bizSetupBody => _r('bizSetupBody',
      'Adını, ünvanını və loqonu əlavə et — sonra müştərilər səni tapıb xal toplamağa başlaya biləcək.');
  String get bizSetupAction => _r('bizSetupAction', 'Profili doldur');
}

const Map<String, Map<String, String>> _errors = <String, Map<String, String>>{
  'en': <String, String>{
    'errOfflineTitle': 'No internet connection',
    'errOfflineBody':
        "Check your connection and try again. Nothing's been lost.",
    'errServerTitle': 'Something went wrong',
    'errServerBody':
        'We hit an unexpected problem on our side. Please try again in a moment.',
    'errLoadTitle': "We couldn't load this",
    'errNotFoundTitle': 'This is no longer available',
    'errNotFoundBody':
        'It may have been removed or changed. Go back and check again.',
    'errNoAccessTitle': "This section isn't available to you",
    'errNoAccessBody': "You don't have permission to view this page.",
    'errGenericBody': "Something didn't work. Please try again in a moment.",
    'bizSetupTitle': 'Set up your business profile',
    'bizSetupBody':
        'Add your name, address and logo — then customers can find you and start collecting points.',
    'bizSetupAction': 'Fill in profile',
  },
  'ru': <String, String>{
    'errOfflineTitle': 'Нет подключения к интернету',
    'errOfflineBody':
        'Проверьте подключение и попробуйте снова. Ваши данные не потерялись.',
    'errServerTitle': 'Что-то пошло не так',
    'errServerBody':
        'У нас возникла неожиданная проблема. Попробуйте ещё раз чуть позже.',
    'errLoadTitle': 'Не удалось загрузить',
    'errNotFoundTitle': 'Это больше недоступно',
    'errNotFoundBody':
        'Возможно, это удалили или изменили. Вернитесь назад и проверьте снова.',
    'errNoAccessTitle': 'Этот раздел вам недоступен',
    'errNoAccessBody': 'У вас нет прав на просмотр этой страницы.',
    'errGenericBody': 'Что-то не сработало. Попробуйте ещё раз чуть позже.',
    'bizSetupTitle': 'Создайте профиль бизнеса',
    'bizSetupBody':
        'Добавьте название, адрес и логотип — тогда клиенты смогут найти вас и начать копить баллы.',
    'bizSetupAction': 'Заполнить профиль',
  },
  'tr': <String, String>{
    'errOfflineTitle': 'İnternet bağlantısı yok',
    'errOfflineBody':
        'Bağlantını kontrol edip tekrar dene. Bilgilerin kaybolmadı.',
    'errServerTitle': 'Bir sorun oluştu',
    'errServerBody':
        'Bizim tarafta beklenmedik bir sorun oldu. Biraz sonra tekrar dene.',
    'errLoadTitle': 'Bilgiler yüklenemedi',
    'errNotFoundTitle': 'Bu artık mevcut değil',
    'errNotFoundBody':
        'Silinmiş ya da değiştirilmiş olabilir. Geri dönüp tekrar kontrol et.',
    'errNoAccessTitle': 'Bu bölüm sana kapalı',
    'errNoAccessBody': 'Bu sayfayı görüntüleme yetkin yok.',
    'errGenericBody': 'Bir şeyler ters gitti. Biraz sonra tekrar dene.',
    'bizSetupTitle': 'İşletme profilini oluştur',
    'bizSetupBody':
        'Adını, adresini ve logonu ekle — sonra müşteriler seni bulup puan toplamaya başlayabilir.',
    'bizSetupAction': 'Profili doldur',
  },
};
