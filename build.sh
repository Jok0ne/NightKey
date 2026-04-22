#!/bin/bash
# build.sh — baut NightKey als .app Bundle und installiert es nach /Applications.
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="NightKey"
BUILD_DIR=".build/release"
APP_BUNDLE="build/${APP_NAME}.app"
INSTALL_PATH="/Applications/${APP_NAME}.app"

echo "==> Building ${APP_NAME} (release)..."
swift build -c release

echo "==> Generating icon..."
if [[ ! -f "Resources/NightKey.icns" ]]; then
    ./make-iconset.sh
fi

echo "==> Creating .app bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp "Resources/NightKey.icns" "${APP_BUNDLE}/Contents/Resources/NightKey.icns"

cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>NightKey</string>
    <key>CFBundleIdentifier</key>
    <string>io.zerone.nightkey</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Built by Zerone ⍟</string>
</dict>
</plist>
EOF

echo "==> Installing to ${INSTALL_PATH}..."
rm -rf "${INSTALL_PATH}"
cp -R "${APP_BUNDLE}" "${INSTALL_PATH}"

echo "==> Done."
echo "    open ${INSTALL_PATH}"
