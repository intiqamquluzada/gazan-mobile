#!/bin/bash
# Build a signed release of Qazan and install it straight onto a paired
# iPhone — over Wi-Fi once the phone has been paired with this Mac by cable.
# The app talks to the production API (https://api.qazan.app).
#
# Usage:  ./ios/install_device.sh /path/to/AuthKey_K53J7KTJ55.p8 [device]
#   device: name or UDID from `xcrun devicectl list devices` (default: first
#           connected physical iPhone).
# Run from the gazan-mobile folder.
set -euo pipefail
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

KEY_PATH="${1:?Give the path of the AuthKey_K53J7KTJ55.p8 file}"
DEVICE="${2:-}"
if [ -z "$DEVICE" ]; then
  DEVICE=$(xcrun devicectl list devices 2>/dev/null \
    | awk '/physical/ && /connected/ && !/unavailable/ {for (i=1;i<=NF;i++) if ($i ~ /^[0-9A-F]{8}-[0-9A-F]{16}$/) {print $i; exit}}')
fi
[ -n "$DEVICE" ] || { echo "No connected iPhone. Unlock it and keep it on the same Wi-Fi."; exit 1; }

# A stale build dir leaves unsigned frameworks behind (install fails with
# "integrity could not be verified"), so always start clean.
rm -rf build/ios/device-dd
flutter build ios --release --config-only
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'generic/platform=iOS' -derivedDataPath build/ios/device-dd \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$KEY_PATH" -authenticationKeyID K53J7KTJ55 \
  -authenticationKeyIssuerID 68accc73-9225-4e19-a192-14158159bdcd \
  -quiet build

xcrun devicectl device install app --device "$DEVICE" \
  build/ios/device-dd/Build/Products/Release-iphoneos/Runner.app
echo "Installed on $DEVICE."
