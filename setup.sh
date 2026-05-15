#!/usr/bin/env bash
# Qazan — bir dəfəlik setup skripti.
# İstifadə: chmod +x setup.sh && ./setup.sh

set -e
cd "$(dirname "$0")"

echo "▸ Flutter yoxlanılır..."
if ! command -v flutter >/dev/null 2>&1; then
  cat <<'EOF'
✗ Flutter tapılmadı.
  Quraşdır: https://docs.flutter.dev/get-started/install/macos
  Sonra terminalı yenidən aç və skripti yenidən işə sal.
EOF
  exit 1
fi
flutter --version | head -1

echo "▸ Platform qovluqları yaradılır (android, ios, macos, web)..."
flutter create . \
  --platforms=android,ios,macos,web \
  --org az.qazan \
  --project-name qazan \
  --overwrite=false >/dev/null

echo "▸ iOS Info.plist-ə kamera icazəsi əlavə olunur..."
PLIST="ios/Runner/Info.plist"
if [ -f "$PLIST" ] && ! grep -q NSCameraUsageDescription "$PLIST"; then
  /usr/libexec/PlistBuddy -c \
    "Add :NSCameraUsageDescription string 'Müştərinin QR kodunu skan etmək üçün kameraya icazə lazımdır.'" \
    "$PLIST" 2>/dev/null || true
fi

echo "▸ Asılılıqlar yüklənir..."
flutter pub get

echo "▸ Kod analizi (xəta varsa göstər)..."
flutter analyze --no-fatal-infos --no-fatal-warnings || true

echo
echo "▸ Mövcud cihazlar:"
flutter devices

cat <<'EOF'

✓ Hazırdır!

İşə salmaq:
  flutter run                        # default cihazda
  flutter run -d chrome              # brauzerdə (sürətli, QR skaner məhdud)
  flutter run -d macos               # macOS desktop
  open -a Simulator && flutter run   # iPhone simulyatorda
EOF
