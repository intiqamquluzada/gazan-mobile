# Köhnə QR ekranları (istifadə olunmur)

NFC-yə keçiddən sonra bu iki ekran UI-dan çıxarıldı. Fayllar burada saxlanılır
(`.bak` uzantısı ilə, ki Dart analizə/derləməyə girməsin) və `qr_flutter` +
`mobile_scanner` paketləri pubspec-dən çıxarıldı — onlar APK-ya təxminən
10+ MB native kod əlavə edirdi.

Geri qaytarmaq üçün:
1. `flutter pub add qr_flutter mobile_scanner`
2. faylları `lib/features/qr/presentation/` altına `.dart` adı ilə qaytar
3. `app_router.dart`-a `/qr`, `/qr/show`, `/business/scan` route-larını əlavə et.

Backend tərəfdəki QR axını (ScanController) toxunulmayıb.
