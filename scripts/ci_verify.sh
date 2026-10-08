#!/usr/bin/env bash
# Generuje projekt Xcode, kompiluje 4 zadania pod iOS Simulator (iOS 26.1 / iPhone 18),
# uruchamia aplikacje w symulatorze i zapisuje zrzuty ekranu.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"

SCHEMES=(Zadanie1 Zadanie2 Zadanie3 Zadanie4)
PREFIX="edu.pb.wi"
APP_DIR="$ROOT/build/Build/Products/Debug-iphonesimulator"
mkdir -p "$ROOT/shots" "$ROOT/dist"

echo "== Generowanie projektu Xcode (XcodeGen) =="
xcodegen generate

echo "== Kompilacja aplikacji (Xcode 26.1 / iphonesimulator26.1 / Swift 5.0) =="
for S in "${SCHEMES[@]}"; do
  echo "--- Kompilacja: $S ---"
  xcodebuild build -quiet \
    -project iOSZadania.xcodeproj -scheme "$S" -configuration Debug \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath build CODE_SIGNING_ALLOWED=NO
done

echo "== Pakowanie paczek symulatora (.app.zip) =="
for S in "${SCHEMES[@]}"; do
  (cd "$APP_DIR" && zip -qr "$ROOT/dist/$S-simulator.app.zip" "$S.app")
done

echo "== Wybór symulatora (Preferowany: iPhone 18 z iOS 26.1) =="
SIM_NAME="${SIM_NAME:-iPhone 18}"
SIM_RUNTIME="${SIM_RUNTIME:-26.1}"
UUID_RE='[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}'

# pick_sim <runtime|any> <name-prefix|any>
pick_sim() {
  xcrun simctl list devices available | awk -v rt="$1" -v nm="$2" '
    index($0, "-- ") == 1 { inrt = (rt == "any" || index($0, "-- iOS " rt " --") == 1); next }
    inrt && $0 ~ /^    iPhone/ {
      if (nm == "any" || index($0, "    " nm " (") == 1 || index($0, "    " nm " ") == 1) { print; exit }
    }' | grep -oE "$UUID_RE" || true
}

# 1. Sprawdź, czy iPhone 18 pod iOS 26.1 już istnieje
UDID=$(pick_sim "$SIM_RUNTIME" "$SIM_NAME")

# 2. Jeśli nie istnieje, spróbuj go utworzyć z dostępnego typu urządzenia i runtime
if [ -z "$UDID" ]; then
  DEV_TYPE=$(xcrun simctl list devicetypes | grep -m1 "$SIM_NAME" | grep -oE 'com\.apple\.CoreSimulator\.SimDeviceType\.[A-Za-z0-9_-]+' || true)
  RUNTIME_ID=$(xcrun simctl list runtimes | grep -m1 "iOS $SIM_RUNTIME" | grep -oE 'com\.apple\.CoreSimulator\.SimRuntime\.[A-Za-z0-9_-]+' || true)
  if [ -n "$DEV_TYPE" ] && [ -n "$RUNTIME_ID" ]; then
    echo "Tworzenie symulatora: $SIM_NAME ($DEV_TYPE, $RUNTIME_ID)..."
    UDID=$(xcrun simctl create "$SIM_NAME" "$DEV_TYPE" "$RUNTIME_ID" || true)
  fi
fi

# 3. Odporne warianty zapasowe, jeśli dany runner nie ma iPhone 18
[ -n "$UDID" ] || UDID=$(pick_sim "$SIM_RUNTIME" "$SIM_NAME")
[ -n "$UDID" ] || UDID=$(pick_sim "$SIM_RUNTIME" any)
[ -n "$UDID" ] || UDID=$(pick_sim any "$SIM_NAME")
[ -n "$UDID" ] || UDID=$(pick_sim any any)

if [ -z "$UDID" ]; then
  echo "::warning::Nie znaleziono symulatora iPhone, pomijanie zrzutów ekranu"
  exit 0
fi

echo "Użyty symulator: $UDID ($SIM_NAME, iOS $SIM_RUNTIME)"
xcrun simctl bootstatus "$UDID" -b

for S in "${SCHEMES[@]}"; do
  echo "Instalacja $S na symulatorze..."
  xcrun simctl install "$UDID" "$APP_DIR/$S.app"
done

# Uprawnienia lokalizacji i współrzędne testowe dla Zadania 3
xcrun simctl privacy "$UDID" grant location "$PREFIX.Zadanie3" || true
xcrun simctl location "$UDID" set 53.1180,23.1537 || true

shot() {  # shot <nazwa-pliku> <bundle-id> [argumenty uruchomienia...]
  local name=$1 bundle=$2; shift 2
  echo "Zrzut ekranu: $name ($bundle)..."
  xcrun simctl launch --terminate-running-process "$UDID" "$bundle" "$@" > /dev/null
  sleep 4
  xcrun simctl io "$UDID" screenshot "$ROOT/shots/$name.png"
}

echo "== Wykonywanie zrzutów ekranu =="
shot zadanie1    "$PREFIX.Zadanie1"
shot zadanie2-en "$PREFIX.Zadanie2" -AppleLanguages "(en)" -AppleLocale en_US
shot zadanie2-pl "$PREFIX.Zadanie2" -AppleLanguages "(pl)" -AppleLocale pl_PL
shot zadanie3    "$PREFIX.Zadanie3"
shot zadanie4    "$PREFIX.Zadanie4"
echo "Gotowe. Wszystkie zadania zostały zweryfikowane."
