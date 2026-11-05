#!/bin/zsh
# Builds "Lid Awake.app" into ./build. Needs the Xcode command line tools (xcode-select --install).
set -e
cd "${0:A:h}"
APP="build/Lid Awake.app"
VERSION=$(grep -o 'appVersion = "[^"]*"' Sources/main.swift | cut -d'"' -f2)
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O -target arm64-apple-macos13 -o build/LidAwake-arm64 Sources/*.swift
swiftc -O -target x86_64-apple-macos13 -o build/LidAwake-x86_64 Sources/*.swift
lipo -create build/LidAwake-arm64 build/LidAwake-x86_64 -output "$APP/Contents/MacOS/LidAwake"
rm build/LidAwake-arm64 build/LidAwake-x86_64
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
sed "s/__VERSION__/$VERSION/" Resources/Info.plist > "$APP/Contents/Info.plist"
codesign --force -s - "$APP"
(cd build && rm -f Lid-Awake-macOS.zip && ditto -c -k --keepParent "Lid Awake.app" Lid-Awake-macOS.zip)
echo "built $APP ($VERSION) and build/Lid-Awake-macOS.zip"
