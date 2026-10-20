#!/usr/bin/env bash
# Build Banana Stats (Debug) and install it on the first paired iPhone.
#
#   ./push.sh                 # 3DAR team (93K49S8Q8U), bundle com.3dar.bananastats
#   TEAM_ID=ABCDE12345 BUNDLE_PREFIX=com.yourname ./push.sh   # your own Apple team
#   ./push.sh 00008150-...    # explicit device UDID (xcrun devicectl list devices)
#
# Needs: Xcode (with your Apple ID signed in under Settings > Accounts),
# xcodegen (brew install xcodegen), the iPhone plugged in, unlocked and trusted.
set -euo pipefail
cd "$(dirname "$0")"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
UDID="${1:-$(xcrun devicectl list devices 2>/dev/null | grep -v simulated | grep -oE "[0-9A-F]{8}-[0-9A-F]{16}" | head -1)}"
[[ -n "$UDID" ]] || { echo "No paired iPhone (plug it in, unlock it, tap Trust)"; exit 1; }
xcodegen generate --quiet
OVERRIDES=()
[[ -n "${TEAM_ID:-}" ]] && OVERRIDES+=("DEVELOPMENT_TEAM=$TEAM_ID")
[[ -n "${BUNDLE_PREFIX:-}" ]] && OVERRIDES+=("BUNDLE_PREFIX=$BUNDLE_PREFIX")
BUNDLE_ID="${BUNDLE_PREFIX:-com.3dar}.bananastats"
AUTH=(); if [[ -n "${ASC_KEY_ID:-}" ]]; then AUTH=(-authenticationKeyPath "${ASC_KEY_PATH/#\$HOME/$HOME}" -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID"); fi
xcodebuild -project BananaStats.xcodeproj -scheme BananaStats -configuration Debug -destination "generic/platform=iOS" \
  -derivedDataPath build -allowProvisioningUpdates ${AUTH[@]+"${AUTH[@]}"} ${OVERRIDES[@]+"${OVERRIDES[@]}"} build | grep -E "error|warning: .*sign|BUILD" || true
APP=build/Build/Products/Debug-iphoneos/BananaStats.app
[[ -d "$APP" ]] || { echo "build failed"; exit 1; }
xcrun devicectl device install app --device "$UDID" "$APP"
xcrun devicectl device process launch --device "$UDID" "$BUNDLE_ID" || true
echo "Installed $BUNDLE_ID. Add the widget: long-press the Home Screen > Edit > Add Widget > search 'Banana'."
