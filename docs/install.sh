#!/bin/sh
# Lid Awake installer.
#   curl -fsSL https://make-become.github.io/lid-awake/install.sh | sh
# Downloads the latest release into /Applications (or ~/Applications when that is not
# writable), clears the download quarantine (the app is open source but not notarised
# by Apple), and opens it. Touches nothing else: the one permission the app needs is
# asked for by the app itself, in macOS's own password dialog, the first time you switch it on.
set -eu

REPO="make-become/lid-awake"
if [ -n "${LID_AWAKE_DEST:-}" ]; then DEST="$LID_AWAKE_DEST"
elif [ -w /Applications ]; then DEST=/Applications
else DEST="$HOME/Applications"; fi
APP="$DEST/Lid Awake.app"
URL="https://github.com/$REPO/releases/latest/download/Lid-Awake-macOS.zip"

[ "$(uname -s)" = Darwin ] || { echo "Lid Awake runs on macOS only."; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "→ Downloading $URL"
curl -fsSL "$URL" -o "$TMP/lid-awake.zip"
ditto -x -k "$TMP/lid-awake.zip" "$TMP"
[ -d "$TMP/Lid Awake.app" ] || { echo "The download did not contain Lid Awake.app"; exit 1; }

echo "→ Installing into $DEST"
mkdir -p "$DEST"
# Quit a running copy so it can be replaced (quitting turns the switch off).
pkill -x LidAwake 2>/dev/null || true
sleep 1
rm -rf "$APP"
ditto "$TMP/Lid Awake.app" "$APP"
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

echo "→ Opening Lid Awake"
open "$APP"
echo "✓ Installed: $APP"
echo "  Its icon is in the menu bar (a laptop). Click it and choose \"Stay on with the lid closed\"."
