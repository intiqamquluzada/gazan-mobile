# Qazan — App Store & Play Store hazırlıq bələdçisi

Bu sənəd tətbiqi mağazalara çıxarmaq üçün konfiqurasiyanı və qalan manual
addımları izah edir.

## Tətbiq kimliyi (artıq tənzimləndi)

| Sahə | Dəyər |
|------|-------|
| Bundle ID (iOS) / Application ID (Android) | `az.qazan.app` |
| Tətbiq adı (göstərilən) | **Qazan** |
| Versiya | `1.0.0+1` (`pubspec.yaml`) — `versionName=1.0.0`, `versionCode=1` |
| Min Android SDK | 23 (Android 6.0) |

`com.example.qazan` → `az.qazan.app` dəyişdirildi (Android `namespace` +
`applicationId`, iOS `PRODUCT_BUNDLE_IDENTIFIER`, Kotlin `MainActivity`
paketi). **Diqqət:** bundle ID dərc olunandan sonra DƏYİŞDİRİLƏ BİLMƏZ.

## Loqo / ikon (artıq tənzimləndi)

- Tətbiq-içi animasyonlu brend marka: `lib/core/widgets/qazan_logo.dart`
  (splash, login, rol seçimi ekranlarında).
- Launcher ikonları `assets/branding/app_icon*.png`-dən generasiya olunur
  (`flutter_launcher_icons`). Yenidən generasiya:
  ```
  flutter pub get
  dart run flutter_launcher_icons
  ```
  Android adaptiv ikon (foreground + gradient background) + iOS + web daxil.

## İmzalama (Android) — keystore

Release imzalama `android/key.properties`-dən oxunur (git-ignored).
Upload keystore: `android/upload-keystore.jks` (git-ignored).

> **TƏHLÜKƏSİZLİK:** `upload-keystore.jks` və `key.properties` git-ə DAXİL
> EDİLMİR. Hər ikisini təhlükəsiz yerdə **backup** et — keystore itsə yeni
> upload key üçün Google-a müraciət etməli olacaqsan.
>
> Hazırkı parol: `Qazan2026!` (alias `upload`). Dərc etməzdən əvvəl dəyişməyi
> tövsiyə edirik: `keytool -storepasswd` / `-keypasswd`, sonra `key.properties`.

Release build:
```
flutter build appbundle --release   # Play Store üçün .aab
flutter build apk --release         # birbaşa paylaşım üçün .apk
```
`key.properties` yoxdursa, build debug açarla imzalanır (lokal sınaq üçün).

## İmzalama (iOS)

Xcode-da: Runner → Signing & Capabilities → öz Apple Developer komandanı seç
(avtomatik imzalama). `az.qazan.app` App Store Connect-də qeydiyyatdan keçməlidir.
```
flutter build ipa --release
```

## İcazələr (artıq tənzimləndi)

- **Android** (`AndroidManifest.xml`): INTERNET, CAMERA.
- **iOS** (`Info.plist`): `NSCameraUsageDescription`,
  `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`
  (image_picker üçün zəruri — yoxdursa App Store rədd edir / çökür).

## ⚠️ Dərc etməzdən əvvəl QALAN manual addımlar

1. **HTTPS** — backend hazırda HTTP-dir (`http://209.97.135.206`). Buna görə
   `usesCleartextTraffic=true` (Android) və `NSAllowsArbitraryLoads=true` (iOS)
   açıqdır. Apple App Review bunu sorğulaya bilər. **iOS submission-dan əvvəl
   domen + HTTPS qurulmalıdır** (HANDOVER-də gözləyən iş). Sonra `AppConfig`
   `https://...` olmalı, ATS exception silinməlidir.
2. **Gizlilik siyasəti (Privacy Policy) URL** — hər iki mağaza tələb edir
   (tətbiq hesab + foto + kamera istifadə edir). Bir səhifə yarat.
3. **Hesabın silinməsi** — Apple, hesab yaradan tətbiqlərdə tətbiq-içi hesab
   silmə tələb edir. `DELETE /users/me` (backend) + profil ekranında düymə lazımdır.
4. **App Privacy / Data Safety formaları** — App Store Connect "App Privacy" və
   Play Console "Data safety": toplanan data (ad, e-poçt, foto, istifadə).
5. **Mağaza materialları** — ikon (avtomatik), ekran şəkilləri (telefon +
   tablet), təsvir, açar sözlər, kateqoriya (Lifestyle / Food & Drink).
6. **Yaş reytinqi** — content rating anketi (hər iki mağaza).

## Build yoxlama siyahısı

- [ ] `flutter build appbundle --release` uğurlu (Android)
- [ ] `flutter build ipa --release` uğurlu (iOS — macOS lazımdır)
- [ ] Real cihazda release build test (login, QR skan, foto yükləmə)
- [ ] Keystore + key.properties backup alındı
