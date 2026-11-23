// Profile photo actions (change / remove). Same contract as strings.dart: a
// missing translation falls back to the Azerbaijani text in the getter.
import 'strings.dart';

extension AvatarStrings on S {
  String _a(String key, String az) => _avatar[lang]?[key] ?? az;

  String get avatarTitle => _a('avatarTitle', 'Profil şəkli');
  String get avatarUpload => _a('avatarUpload', 'Yeni şəkil yüklə');
  String get avatarUploadSub =>
      _a('avatarUploadSub', 'Qalereyadan şəkil seç');
  String get avatarRemove => _a('avatarRemove', 'Şəkli sil');
  String get avatarRemoveSub =>
      _a('avatarRemoveSub', 'Baş hərflər göstəriləcək');
  String get avatarUpdated => _a('avatarUpdated', 'Profil şəkli yeniləndi');
  String get avatarRemoved => _a('avatarRemoved', 'Profil şəkli silindi');
  String get avatarFailed =>
      _a('avatarFailed', 'Şəkil yüklənmədi. Yenidən cəhd et.');
  String get avatarTooLarge =>
      _a('avatarTooLarge', 'Şəkil çox böyükdür (maks. 5 MB).');
}

const Map<String, Map<String, String>> _avatar = <String, Map<String, String>>{
  'en': <String, String>{
    'avatarTitle': 'Profile photo',
    'avatarUpload': 'Upload new photo',
    'avatarUploadSub': 'Choose a photo from your gallery',
    'avatarRemove': 'Remove photo',
    'avatarRemoveSub': 'Your initials will be shown',
    'avatarUpdated': 'Profile photo updated',
    'avatarRemoved': 'Profile photo removed',
    'avatarFailed': 'Could not upload the photo. Please try again.',
    'avatarTooLarge': 'The photo is too large (max 5 MB).',
  },
  'ru': <String, String>{
    'avatarTitle': 'Фото профиля',
    'avatarUpload': 'Загрузить новое фото',
    'avatarUploadSub': 'Выберите фото из галереи',
    'avatarRemove': 'Удалить фото',
    'avatarRemoveSub': 'Будут показаны ваши инициалы',
    'avatarUpdated': 'Фото профиля обновлено',
    'avatarRemoved': 'Фото профиля удалено',
    'avatarFailed': 'Не удалось загрузить фото. Попробуйте ещё раз.',
    'avatarTooLarge': 'Фото слишком большое (макс. 5 МБ).',
  },
  'tr': <String, String>{
    'avatarTitle': 'Profil fotoğrafı',
    'avatarUpload': 'Yeni fotoğraf yükle',
    'avatarUploadSub': 'Galeriden bir fotoğraf seç',
    'avatarRemove': 'Fotoğrafı kaldır',
    'avatarRemoveSub': 'Baş harflerin gösterilecek',
    'avatarUpdated': 'Profil fotoğrafı güncellendi',
    'avatarRemoved': 'Profil fotoğrafı kaldırıldı',
    'avatarFailed': 'Fotoğraf yüklenemedi. Tekrar dene.',
    'avatarTooLarge': 'Fotoğraf çok büyük (en fazla 5 MB).',
  },
};
