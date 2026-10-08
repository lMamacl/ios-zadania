# Zadania laboratoryjne iOS (Zadanie 1–4)

Kompletny zestaw rozwiązań czterech zadań laboratoryjnych w SwiftUI wraz z automatyzacją budowania i testowania w GitHub Actions bez konieczności posiadania lokalnie komputera Mac.
Plik projektu `.xcodeproj` jest generowany automatycznie przy użyciu narzędzia **XcodeGen** na podstawie specyfikacji `project.yml`.

---

## 🛠 Wymagania środowiskowe projektu

Projekt został dostosowany i skonfigurowany pod następujące środowisko:
* **Wersja Xcode:** Xcode 26.1
* **Docelowy system (Deployment Target):** iOS 26.1 (`IPHONEOS_DEPLOYMENT_TARGET = 26.1`)
* **Wersja SDK:** iOS 26.1 (`iphonesimulator26.1`)
* **Symulator domyślny:** `iPhone 18` z systemem iOS 26.1
* **Tryb języka Swift:** `SWIFT_VERSION = 5.0` (kompilator Swift 6.2 działający w trybie wstecznej zgodności ze Swift 5)
* **Wszystkie zadania aktywne:** Zadania 1, 2, 3 oraz 4 są włączone do kompilacji w `project.yml` oraz weryfikowane w skrypcie `scripts/ci_verify.sh`.

---

## 📱 Przegląd zaimplementowanych zadań

Wszystkie aplikacje posiadają interfejs w języku polskim:

### Zadanie 1 – Wprowadzenie do iOS i SwiftUI
* Pola tekstowe na imię i nazwisko z automatyczną aktualizacją powitania na bieżąco (`onChange`).
* Reakcja na wpisanie wybranego imienia (`mojeImie = "Maciej"`) – wyświetlenie komunikatu `"...! Mamy to samo imię"`.
* Przycisk przechodzący do drugiego widoku (`DrugiWidok`) ze stylem (zielone tło, zaokrąglone rogi, odstępy 10 px).
* Dwukierunkowe przekazywanie i edycja nazwiska za pomocą mechanizmu `@Binding` – zmiana w drugim widoku natychmiast aktualizuje powitanie w pierwszym widoku.

### Zadanie 2 – Umiędzynarodowienie (i18n / l10n)
* Wyświetlanie logo wydziału (`wi-en` lub `wi-pl`) pobieranego dynamicznie w zależności od języka systemu (`NSLocalizedString("Filename", ...)`).
* Obsługa języka polskiego i angielskiego za pomocą plików `Localizable.strings` w `en.lproj` oraz `pl.lproj`.
* Przycisk otwierający okno dialogowe (Alert) ze zlokalizowaną liczbą kierunków studiów (parametr `%i` formatowany z wartością `4`).

### Zadanie 3 – Gesty, potrząśnięcie i geolokalizacja
* Obsługa gestów: pojedyncze tapnięcie, podwójne tapnięcie, potrójne tapnięcie (rozwiązywane priorytetowo), długie przytrzymanie, gest uszczypnięcia (pinch / `MagnifyGesture`) oraz przesunięcie (drag / swipe).
* Reakcja na potrząśnięcie telefonem (`motionShake`) – wyświetlenie okna `confirmationDialog` z pytaniem o zmianę koloru tła (przyciski *Tak*, *Nie*, *Anuluj*).
* Drugi widok (`DrugiWidok`):
  * Domyślnie białe tło (chyba że w pierwszym widoku zatwierdzono losowy kolor).
  * Potrząśnięcie w drugim widoku bezpośrednio losuje nowy kolor (bez pytania).
  * Przycisk *Pobierz lokalizację* odpytujący `CLLocationManager` i pobierający adres przez geokodowanie odwrotne (`CLGeocoder`).

### Zadanie 4 – CRUD (Aplikacja zarządzania danymi osób)
* **Lista osób (Read):** Przegląd rekordów z wyszukiwaniem i usuwaniem (swipe-to-delete).
* **Szczegóły (Read):** Pełny podgląd danych kontaktowych i osobowych.
* **Dodawanie i edycja (Create / Update):** Formularz z precyzyjną walidacją.
* **Usuwanie (Delete):** Potwierdzenie usunięcia w dedykowanym oknie dialogowym.
* **Kompleksowa walidacja:** Sprawdzanie wymaganych pól (imię, nazwisko, format e-mail, poprawność numeru telefonu, data urodzenia niewybiegająca w przyszłość). Komunikaty błędów widoczne pod polami oraz w zbiorczym alercie.
* Przechowywanie danych w pamięci (`PersonStore` z `@Published` i `@MainActor`).

---

## 🚀 Workflow GitHub Actions (Automatyczna kompilacja bez Maca)

1. Po wypchnięciu zmian do gałęzi `main` uruchamia się workflow `.github/workflows/ios.yml` na maszynie `macos-26`.
2. Akcja:
   * Wybiera środowisko Xcode 26.1.
   * Instaluje narzędzie XcodeGen (`brew install xcodegen`).
   * Uruchamia skrypt `scripts/ci_verify.sh`, który:
     * Generuje projekt `iOSZadania.xcodeproj`.
     * Kompiluje wszystkie 4 schematy (`Zadanie1`, `Zadanie2`, `Zadanie3`, `Zadanie4`).
     * Pakuje skompilowane binarki `.app.zip`.
     * Uruchamia symulator **iPhone 18** (iOS 26.1).
     * Nadaje uprawnienia lokalizacyjne dla Zadania 3.
     * Wykonuje zrzuty ekranu dla każdej aplikacji (dla Zadania 2 w języku angielskim i polskim).
3. Po zakończeniu zadania w zakładce **Actions** dostępne są artefakty do pobrania:
   * `xcode-project` – kompletny projekt Xcode, gotowy do otwarcia na zajęciach laboratoryjnych.
   * `screenshots` – zrzuty ekranu potwierdzające poprawne działanie wszystkich aplikacji.
   * `simulator-apps` – paczki `.app.zip` (przydatne np. do testów online w Appetize.io).

---

## 💻 Uruchomienie lokalne na komputerze Mac

Jeśli masz dostęp do Maca z Xcode:
```bash
# 1. Instalacja XcodeGen (jeśli nie posiadasz)
brew install xcodegen

# 2. Wygenerowanie projektu Xcode
xcodegen generate

# 3. Uruchomienie pełnej weryfikacji i zrzutów ekranu
bash scripts/ci_verify.sh

# 4. Otwarcie projektu w Xcode
open iOSZadania.xcodeproj
```

---

## 💡 Wskazówki do prezentacji na zajęciach laboratoryjnych

* **Podmiana logotypów w Zadaniu 2:** W katalogu `Zadanie2/Assets.xcassets` umieszczone są grafiki wydziału `wi-en` oraz `wi-pl`.
* **Symulator – gest potrząśnięcia:** W menu symulatora wybierz `Device` -> `Shake` (skrót `Ctrl + Cmd + Z`).
* **Symulator – gest pinch:** Przytrzymaj klawisz `Option` (`Alt`) i przeciągnij kursorem.
* **Symulator – lokalizacja:** W menu symulatora wybierz `Features` -> `Location` -> `Apple` lub `Custom Location`, aby symulator podawał współrzędne GPS.
* **Symulator – język polski w Zadaniu 2:** W Xcode wejdź w `Product` -> `Scheme` -> `Edit Scheme...` -> `Run` -> `Options` -> `App Language: Polish` (lub zmień język w Ustawieniach symulatora).
