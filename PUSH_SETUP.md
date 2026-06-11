# Telefon push bildirişləri (FCM) — quraşdırma

Kod tərəfi HAZIRDIR — yalnız Firebase layihəsi və konfiq faylları lazımdır.
Onlar əlavə olunana qədər tətbiq normal işləyir, push sadəcə **deaktiv** qalır
(heç nə çökmür).

## Artıq kodda olan (mənim etdiyim)

**Mobile:**
- `firebase_core` + `firebase_messaging` paketləri (`pubspec.yaml`).
- `lib/core/push/push_service.dart` — Firebase init + token alma + qeydiyyat
  (Firebase yoxdursa səssiz no-op).
- `lib/core/push/push_repository.dart` — `/api/v1/push/tokens` çağırışları.
- Auth axınına bağlandı: login/restore-dan sonra token qeydiyyatdan keçir,
  çıxışda silinir (`auth_controller.dart`).

**Backend:**
- `device_tokens` cədvəli (`V13`) + `push` modulu (token register/unregister:
  `POST`/`DELETE /api/v1/push/tokens`).
- `NotificationService` artıq hər bildiriş yaradılanda `PushService`-ə fan-out
  edir (broadcast → bütün cihazlar, targeted → istifadəçinin cihazları).
- `PushSender` — `qazan.push.fcm.enabled=false` (default) olduqda loglayır;
  real FCM göndərişi `deliverViaFcm()`-də implementasiya gözləyir.

## Sənin etməli olduğun

### 1. Firebase layihəsi (pulsuz)
1. https://console.firebase.google.com → **Add project** → "Qazan".
2. FlutterFire CLI ilə avtomatik konfiqurasiya (ən asanı):
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<firebase-project-id>
   ```
   Bu, `lib/firebase_options.dart` yaradır və Android/iOS konfiqini qurur.
   Sonra `push_service.dart`-da `Firebase.initializeApp()` →
   `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
   et.

### 2. Android
- `flutterfire configure` `android/app/google-services.json` qoyur.
- `android/settings.gradle.kts`-ə Google Services plugin:
  `id("com.google.gms.google-services") version "4.4.2" apply false`
- `android/app/build.gradle.kts` plugins blokuna:
  `id("com.google.gms.google-services")`

### 3. iOS (Apple Developer hesabı lazımdır)
- `flutterfire configure` `ios/Runner/GoogleService-Info.plist` qoyur.
- Apple Developer → Keys → **APNs Auth Key** (.p8) yarat → Firebase Console →
  Project Settings → Cloud Messaging → iOS app → APNs key yüklə.
- Xcode → Runner → Signing & Capabilities → **Push Notifications** +
  **Background Modes › Remote notifications** əlavə et.

### 4. Backend FCM göndərişi
1. Firebase Console → Project Settings → Service accounts → **Generate new
   private key** → JSON yüklə (serverdə təhlükəsiz saxla, git-ə qoyma).
2. `application.yml`:
   ```yaml
   qazan:
     push:
       fcm:
         enabled: true
         project-id: <firebase-project-id>
         credentials: /opt/qazan/secrets/fcm-service-account.json
   ```
3. `gazan-backend/build.gradle` dependency:
   `implementation 'com.google.auth:google-auth-library-oauth2-http:1.30.1'`
4. `PushSender.deliverViaFcm()`-i implementasiya et (JavaDoc-da addımlar var):
   service-account-dan OAuth2 token al → hər token üçün
   `POST https://fcm.googleapis.com/v1/projects/<id>/messages:send`.

### 5. Web (istəyə bağlı)
- `web/firebase-messaging-sw.js` service worker + VAPID açarı (`getToken`).
- HTTPS şərtdir (mövcud HTTP prod-da web push işləməz — bax STORE_RELEASE.md).

## Test
1. Firebase config faylları yerində + `flutter run` (real cihaz, emulyator yox).
2. Login ol → `device_tokens`-da bir sətir görünməlidir.
3. Admin paneldən bildiriş göndər → telefonun bildiriş zonasında görünməlidir.
