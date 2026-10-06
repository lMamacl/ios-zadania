# iOS assignments (Zadanie 1-4)

SwiftUI sources for the four assignments plus a GitHub Actions setup that builds them without a Mac.
The `.xcodeproj` is not stored in git: XcodeGen generates it from `project.yml`.

> **Aktualny stan projektu:** Skonfigurowany na ten moment pod **Zadanie 1** (w `project.yml` oraz `scripts/ci_verify.sh`). Źródła zadań 2–4 znajdują się w repozytorium — aby je aktywować w kolejnych etapach, wystarczy odkomentować je w `project.yml` oraz w `scripts/ci_verify.sh`.

## Workflow

1. Create the repository yourself, copy these files in, push to `main`.
2. Actions tab -> **Build iOS apps** (runs on push to `main`, or press *Run workflow*).
3. When it is green, download the artifacts:
   - `xcode-project` - ready to open in Xcode (contains `iOSZadania.xcodeproj` with all four schemes)
   - `screenshots` - every app launched in a simulator (Zadanie 2 in English and Polish)
   - `simulator-apps` - `ZadanieN-simulator.app.zip`, for Appetize.io
4. If it is red, open the failed step, copy the compiler error and fix it (or send it to the AI that wrote the code).
5. In the lab: unzip `xcode-project`, open `iOSZadania.xcodeproj`, pick a scheme (Zadanie1..4) and an iPhone simulator, press Run.

## Before you present

- **Zadanie 2 logos are placeholders.** Replace `Zadanie2/Assets.xcassets/wi-en.imageset/wi-en.png` and
  `.../wi-pl.imageset/wi-pl.png` with the real faculty logos (keep the file names).
- **Xcode version.** The PDFs show iPhone 16 Pro / iOS 18.0, so the lab probably has Xcode 16. Check
  Xcode -> About Xcode. If it is older than 16, lower `xcodeVersion` in `project.yml`. The CI picks Xcode 16.x
  when the runner still has it, otherwise its default Xcode (see the warning in the first step).
- **Zadanie 1:** `myName` in `Zadanie1/ContentView.swift` is the name that triggers "We have the same name".
- **Zadanie 3:** the second view turns random only after you pressed **Yes** in the shake dialog
  (variable `wasShaken`). If your instructor expects "any shake", set `wasShaken = true` in the shake handler instead.
- **Zadanie 4:** the UI is in Polish; data is kept in memory only.

## Simulator tips

- Shake: Device -> Shake (Ctrl+Cmd+Z)
- Pinch: hold Option and drag
- Location: Features -> Location -> Apple / Custom Location (otherwise Zadanie 3 shows an error instead of coordinates)
- Polish version of Zadanie 2: Product -> Scheme -> Edit Scheme -> Run -> Options -> App Language -> Polish
  (or change the language in the simulator's Settings)

## Appetize.io (optional, mainly for Zadanie 3)

Upload `Zadanie3-simulator.app.zip` at appetize.io. The free plan is very limited (short sessions, few minutes per month),
so use it only where interaction matters. Check on Appetize which shake / location / language controls it offers.

## Run the check yourself on a Mac

`brew install xcodegen && bash scripts/ci_verify.sh` does the same as CI (generate, build, run, screenshots).

## Not verified yet

The code has not been compiled by anyone yet. The first CI run is the real test, so run it well before the lab.
Gesture interplay in Zadanie 3 (tap counts vs long press vs drag) should be tried by hand once.
