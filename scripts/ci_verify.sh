#!/usr/bin/env bash
# Generates the Xcode project, builds all four apps for the iOS Simulator,
# launches them and saves screenshots. Works on CI and on any Mac with Xcode + XcodeGen.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"

# Na razie aktywne tylko Zadanie 1 (odkomentuj kolejne, gdy będziesz gotowy):
SCHEMES=(Zadanie1)
# SCHEMES=(Zadanie1 Zadanie2 Zadanie3 Zadanie4)
PREFIX="edu.pb.wi"
APP_DIR="$ROOT/build/Build/Products/Debug-iphonesimulator"
mkdir -p "$ROOT/shots" "$ROOT/dist"

echo "== Generating Xcode project =="
xcodegen generate

echo "== Building =="
for S in "${SCHEMES[@]}"; do
  echo "--- $S ---"
  xcodebuild build -quiet \
    -project iOSZadania.xcodeproj -scheme "$S" -configuration Debug \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath build CODE_SIGNING_ALLOWED=NO
done

echo "== Packaging simulator builds =="
for S in "${SCHEMES[@]}"; do
  (cd "$APP_DIR" && zip -qr "$ROOT/dist/$S-simulator.app.zip" "$S.app")
done

echo "== Picking a simulator =="
UUID_RE='[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}'
UDID=$(xcrun simctl list devices available | grep -m1 "iPhone 16 Pro (" | grep -oE "$UUID_RE" || true)
if [ -z "$UDID" ]; then
  UDID=$(xcrun simctl list devices available | grep -m1 "iPhone" | grep -oE "$UUID_RE" || true)
fi
if [ -z "$UDID" ]; then
  echo "::warning::No iPhone simulator found, skipping screenshots"
  exit 0
fi
echo "Using simulator $UDID"
xcrun simctl bootstatus "$UDID" -b

for S in "${SCHEMES[@]}"; do
  xcrun simctl install "$UDID" "$APP_DIR/$S.app"
done

# Uprawnienia lokalizacji dla Zadania 3 (odkomentuj, gdy aktywujesz Zadanie 3):
# xcrun simctl privacy "$UDID" grant location "$PREFIX.Zadanie3" || true
# xcrun simctl location "$UDID" set 37.33182,-122.03118 || true

shot() {  # shot <file-name> <bundle-id> [launch args...]
  local name=$1 bundle=$2; shift 2
  xcrun simctl launch --terminate-running-process "$UDID" "$bundle" "$@" > /dev/null
  sleep 4
  xcrun simctl io "$UDID" screenshot "$ROOT/shots/$name.png"
}

echo "== Screenshots =="
shot zadanie1    "$PREFIX.Zadanie1"
# shot zadanie2-en "$PREFIX.Zadanie2" -AppleLanguages "(en)" -AppleLocale en_US
# shot zadanie2-pl "$PREFIX.Zadanie2" -AppleLanguages "(pl)" -AppleLocale pl_PL
# shot zadanie3    "$PREFIX.Zadanie3"
# shot zadanie4    "$PREFIX.Zadanie4"
echo "Done."
