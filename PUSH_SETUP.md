# Telefon bildirimleri (FCM) — kurulum

Kod hazır. Firebase ayarları eklenene kadar uygulama normal çalışır, push
sadece kapalı kalır (uygulama içi bildirim kutusu her zaman çalışır).

## Kodda olanlar

**Mobil**
- `firebase_core`, `firebase_messaging`, `flutter_local_notifications`.
- `lib/core/push/push_service.dart`: başlatma (`main.dart`), girişte izin isteme
  ve cihaz token'ını backend'e kaydetme, çıkışta silme, uygulama açıkken
  bildirimi gösterme, bildirime dokununca `route` ekranını açma.
- Android: `POST_NOTIFICATIONS` izni, `qazan_default` kanalı, minSdk 24.
  Google Services eklentisi yalnızca `android/app/google-services.json`
  varsa uygulanır.
- iOS: `aps-environment` entitlement, `UIBackgroundModes/remote-notification`.

**Backend**
- `PushSender`: FCM HTTP v1, servis hesabıyla. İşlem commit olduktan sonra
  arka planda gönderir; Firebase'in "kayıtlı değil" dediği token'ları siler.
- Kimlere gider: admin duyurusu (herkes), kişiye özel bildirimler, işletmenin
  müşterilerine bildirimi (kart sahipleri), müşteri SPEND kartına dokununca
  işletme sahibi ve kasiyerlere "Müşteri kasada bekliyor".

## Senin yapacakların

1. https://console.firebase.google.com → **Proje ekle** → "Qazan".
2. **Android uygulaması ekle**: paket adı `az.qazan.app` →
   `google-services.json` indir → `gazan-mobile/android/app/` içine koy.
3. **iPhone** (Apple Developer hesabı gerekir): iOS uygulaması ekle, paket
   `az.qazan.app` → `GoogleService-Info.plist` indir → Xcode ile
   `ios/Runner`'a ekle. Apple Developer → Keys → **APNs Auth Key (.p8)** →
   Firebase → Proje ayarları → Cloud Messaging → iOS'a yükle. Xcode'da
   Push Notifications yeteneğini aç.
4. **Backend için servis hesabı**: Firebase → Proje ayarları → Hizmet
   hesapları → **Yeni özel anahtar oluştur** → JSON indir. Git'e koyma.
   Sunucuda örneğin `/etc/qazan/fcm.json` (sahibi `qazan`, izin 600) ve
   `/etc/qazan/qazan.env` içine:
   ```
   FCM_ENABLED=true
   FCM_CREDENTIALS_FILE=/etc/qazan/fcm.json
   ```
   Docker kurulumunda `deploy/.env` içine `FCM_ENABLED=true` ve
   `FCM_CREDENTIALS_JSON=<tek satır JSON>`.

Dosya kullanmak istemezsen APK'yı şu değerlerle de derleyebilirsin
(Firebase → Proje ayarları → Android uygulaması):
`--dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=...
--dart-define=FIREBASE_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...`

## Test
1. Yeni APK'yı kur, giriş yap, bildirim iznine **İzin ver** de.
2. Sunucuda `device_tokens` tablosunda bir satır görünmeli.
3. Admin → Bildirimler → gönder: telefonun bildirim çubuğunda görünmeli.
   Backend logunda `[push] "..." delivered to 1/1 device(s)` satırı olmalı.
