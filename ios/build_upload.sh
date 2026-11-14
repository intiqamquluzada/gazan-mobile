#!/bin/bash
# Build, sign and upload Qazan to App Store Connect (TestFlight).
# Usage:  ./ios/build_upload.sh /path/to/AuthKey_K53J7KTJ55.p8
# Run from the gazan-mobile folder on a Mac with Xcode and Flutter installed.
set -euo pipefail

KEY_PATH="${1:?Give the path of the AuthKey_K53J7KTJ55.p8 file}"
KEY_ID="K53J7KTJ55"
ISSUER_ID="68accc73-9225-4e19-a192-14158159bdcd"
AUTH=(-allowProvisioningUpdates
      -authenticationKeyPath "$KEY_PATH"
      -authenticationKeyID "$KEY_ID"
      -authenticationKeyIssuerID "$ISSUER_ID")

flutter clean
flutter pub get
(cd ios && pod install --repo-update)

# Release build with the production API (https://api.qazan.app is the default).
flutter build ios --release --config-only

xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=iOS' -archivePath build/ios/Qazan.xcarchive \
  "${AUTH[@]}" archive

xcodebuild -exportArchive -archivePath build/ios/Qazan.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist -exportPath build/ios/export \
  "${AUTH[@]}"

echo "Uploaded. The build appears in App Store Connect > TestFlight in 10-30 minutes."
