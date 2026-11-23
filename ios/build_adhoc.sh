#!/bin/bash
# Build an ad-hoc Qazan for the registered test iPhones and package an
# install page (Safari → "Yüklə" → installs, no TestFlight needed).
# Usage:  ./ios/build_adhoc.sh /path/to/AuthKey_K53J7KTJ55.p8 [--reuse-archive]
# Output: build/ios/qazan-install.tgz — copy it to the server and run
#         qazan-install-publish there. Install URL: https://api.qazan.app/install/
# New test phone? Register its UDID in the Apple Developer account first,
# then rebuild: the ad-hoc profile only covers registered devices.
set -euo pipefail
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

KEY_PATH="${1:?Give the path of the AuthKey_K53J7KTJ55.p8 file}"
REUSE="${2:-}"
BASE_URL="https://api.qazan.app/install"
AUTH=(-allowProvisioningUpdates
      -authenticationKeyPath "$KEY_PATH"
      -authenticationKeyID K53J7KTJ55
      -authenticationKeyIssuerID 68accc73-9225-4e19-a192-14158159bdcd)
ARCHIVE=build/ios/Qazan.xcarchive

if [ "$REUSE" != "--reuse-archive" ] || [ ! -d "$ARCHIVE" ]; then
  flutter pub get
  (cd ios && pod install)
  flutter build ios --release --config-only
  xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
    -destination 'generic/platform=iOS' -archivePath "$ARCHIVE" "${AUTH[@]}" -quiet archive
fi

rm -rf build/ios/adhoc
xcodebuild -exportArchive -archivePath "$ARCHIVE" \
  -exportOptionsPlist ios/ExportOptions-AdHoc.plist -exportPath build/ios/adhoc "${AUTH[@]}" -quiet

INFO="$ARCHIVE/Products/Applications/Runner.app/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO")
BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO")
DATE=$(date +%Y-%m-%d)

PKG=build/ios/install-package
rm -rf "$PKG" && mkdir -p "$PKG"
cp build/ios/adhoc/qazan.ipa "$PKG/"
# The manifest shows this title in the iOS "Install?" prompt.
sed 's#<string>Runner</string>#<string>Qazan</string>#' build/ios/adhoc/manifest.plist > "$PKG/manifest.plist"
sips -Z 57  assets/branding/app_icon.png --out "$PKG/icon-57.png"  >/dev/null
sips -Z 512 assets/branding/app_icon.png --out "$PKG/icon-512.png" >/dev/null
sed -e "s#__VERSION__#$VERSION#" -e "s#__BUILD__#$BUILD#" -e "s#__DATE__#$DATE#" \
    -e "s#__MANIFEST_URL__#$BASE_URL/manifest.plist#" ios/adhoc/index.html > "$PKG/index.html"
printf '{"version":"%s","build":"%s","date":"%s","page":"%s/","manifest":"%s/manifest.plist"}\n' \
  "$VERSION" "$BUILD" "$DATE" "$BASE_URL" "$BASE_URL" > "$PKG/latest.json"

tar czf build/ios/qazan-install.tgz -C "$PKG" .
echo "Ready: build/ios/qazan-install.tgz ($VERSION, build $BUILD)"
