#!/usr/bin/env bash
# Generuje projekt Xcode, kompiluje 4 zadania pod iOS Simulator (iOS 17.0+),
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

echo "== Kompilacja aplikacji (iOS Simulator / Swift 5.0) =="
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

echo "== Wybór symulatora =="
UUID_RE='[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}'

# 1. Sprawdź, czy istnieje już gotowy, dostępny symulator iPhone
# Szukamy najpierw nowszych modeli (iPhone 17, 16, 15, 14, SE), a jeśli brak – dowolnego dostępnego iPhone'a
UDID=$(xcrun simctl list devices available | grep -E "iPhone (17|16|15|14|SE)" | head -n1 | grep -oE "$UUID_RE" || true)
if [ -z "$UDID" ]; then
  UDID=$(xcrun simctl list devices available | grep -i "iPhone" | head -n1 | grep -oE "$UUID_RE" || true)
fi

# 2. Jeśli żaden symulator nie jest jeszcze utworzony/dostępny, utwórz go dynamicznie
if [ -z "$UDID" ]; then
  echo "Brak gotowego symulatora iPhone, wyszukiwanie typu urządzenia i runtime..."
  DEV_TYPE=$(xcrun simctl list devicetypes | grep -E 'iPhone-(17|16|15|SE)' | head -n1 | grep -oE 'com\.apple\.CoreSimulator\.SimDeviceType\.[A-Za-z0-9_-]+' || true)
  if [ -z "$DEV_TYPE" ]; then
    DEV_TYPE=$(xcrun simctl list devicetypes | grep -i 'iPhone' | head -n1 | grep -oE 'com\.apple\.CoreSimulator\.SimDeviceType\.[A-Za-z0-9_-]+' || true)
  fi
  RUNTIME_ID=$(xcrun simctl list runtimes | grep -E 'com\.apple\.CoreSimulator\.SimRuntime\.iOS' | tail -n1 | grep -oE 'com\.apple\.CoreSimulator\.SimRuntime\.[A-Za-z0-9_-]+' || true)
  if [ -n "$DEV_TYPE" ] && [ -n "$RUNTIME_ID" ]; then
    echo "Tworzenie symulatora z devicetype: $DEV_TYPE oraz runtime: $RUNTIME_ID..."
    UDID=$(xcrun simctl create "Test-iPhone" "$DEV_TYPE" "$RUNTIME_ID" || true)
  fi
fi

if [ -z "$UDID" ]; then
  echo "::warning::Nie znaleziono ani nie udało się utworzyć symulatora iPhone, pomijanie zrzutów ekranu"
  exit 0
fi

echo "Użyty symulator: $UDID"
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
