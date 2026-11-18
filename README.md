# VECTORCALC

[![Latest release](https://img.shields.io/github/v/release/saxshamdev/vectorcalc?style=flat-square&label=download)](https://github.com/saxshamdev/vectorcalc/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![No data collected](https://img.shields.io/badge/privacy-no%20data%20collected-brightgreen?style=flat-square)](PRIVACY.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)

An offline engineering and scientific calculator. Retro-clean, minimal, and
built for people who actually work in engineering units.

- **No accounts, no analytics, no internet.** The app never opens a network connection.
- **One codebase** — Android, iOS, and web.
- **Exact results** — fractions and integers are kept exact with `BigInt`
  rationals, so `1/3 + 1/6` really is `1/2`, and `S⇔D` flips between forms.
- **Engineering first** — SI prefixes, engineering notation, physical constants,
  DMS entry, angle modes, and an ES PLUS–style keypad.

---

## Download

Get the latest build from
**[github.com/saxshamdev/vectorcalc/releases/latest](https://github.com/saxshamdev/vectorcalc/releases/latest)**.

| Platform | File | Size | Direct link |
| --- | --- | --- | --- |
| Android 7.0+ | Universal APK (arm64-v8a, armeabi-v7a, x86_64) | ~49 MB | [Download APK](https://github.com/saxshamdev/vectorcalc/releases/latest/download/VECTORCALC-1.0.0-android.apk) |
| iOS | Build from source or CI artifact (unsigned) | — | [Building → iOS](#ios) |
| Web | Self-host the static build | — | [Building → Web](#web) |

The APK is signed with this project's own release key, not a debug key. Every
release also publishes `SHA256SUMS.txt` and the signing certificate fingerprint.

### Verify your download

```bash
sha256sum -c SHA256SUMS.txt
```

Compare against `SHA256SUMS.txt` in the same release. See
[SECURITY.md](SECURITY.md) for the Android certificate fingerprint.

Android APK signing certificate (SHA-256):

```
ad55e8c971f87f417019258e9044b06778850fd019d0be6e1a23f426dd13acf4
```

---

## Privacy

**VECTORCALC collects nothing.** No accounts, no analytics, no ads, no
telemetry, no crash reporting, no network calls. The release Android manifest
does not even request the `INTERNET` permission. History, variables, and
settings are stored only in app-private local storage and disappear when you
clear the app's data or uninstall it.

Read the full [privacy policy](PRIVACY.md) and [security policy](SECURITY.md).

---

## Look and feel

Five themes, each with a **Bright** and **Night** variant:

| Theme | Mood |
| --- | --- |
| Amber | Warm phosphor terminal (default) |
| Phosphor | Classic green CRT |
| Beige | 80s lab hardware |
| Paper | Ink on warm stock |
| Graphite | Monochrome instrument |

Square corners, hairline borders, hard unblurred shadows, VT323 for digits,
Press Start 2P for the wordmark and status pills. Nothing glows, nothing
floats, nothing animates for decoration.

---

## Features

### Calculation
- `+ − × ÷ ^`, unary minus, implicit multiplication (`2(3+4)`, `2√9`, `3π`)
- Parentheses, postfix `!`, `%`, and DMS `°` `′` `″`
- Roots: `√`, `∛`, `root(x, n)`
- Trig and inverse trig in DEG / RAD / GRAD, plus hyperbolics
- `log` (base 10), `ln`, `log(base, x)`, `exp`
- Combinatorics: `nCr`, `nPr`, factorial
- Number theory: `gcd`, `lcm`, `mod`, `floor`, `ceil`, `round`, `int`, `frac`
- `abs`, `sign`, `min`, `max`, `hypot`, `atan2`, `rand`, `randint`
- `Ans` and `PreAns` chaining

### Engineering display
- NORM / FIX / SCI display modes
- Engineering notation with exponents in steps of three
- SI prefix rendering (`1.234k`, `4.2µ`, `8.1n`)
- Exact ⇄ decimal toggle (`S⇔D`) and mixed fractions (`2 1/3`)

### Memory and storage
- Variables `A`–`F`, `X`, `Y`, and independent memory `M`
- `M+`, `M−`, `MC`, `RCL`
- 100-entry persistent history, tap to recall
- 25 physical and mathematical constants with a searchable catalogue

### Modes

- **COMP** — general expression evaluation
- **CMPLX** — complex arithmetic in rectangular and polar form
- **STAT** — one-variable descriptive statistics and two-variable regression
- **BASE-N** — binary/octal/decimal/hex conversion and bitwise operations
- **EQN** — 2×2 and 3×3 linear systems, quadratics, and cubics (real or complex roots)
- **MATRIX** — 2×2 and 3×3 add, subtract, multiply, transpose, determinant, inverse
- **TABLE** — evaluate `f(x)` over a start/end/step range
- **VECTOR** — 2D/3D add, subtract, dot, cross, magnitude, and angle

### Input
- ES PLUS–style 8×5 keypad with `SHIFT` and `ALPHA` layers
- Horizontally scrollable function strip for the less-used functions
- Full physical-keyboard support on web
- Cursor movement and mid-expression editing

---

## Keyboard shortcuts (web)

| Key | Action |
| --- | --- |
| `0`–`9` `.` | Digits |
| `+ - * / ^` | Operators (`*` → `×`, `/` → `÷`) |
| `(` `)` | Parentheses |
| `Enter` | Evaluate |
| `Backspace` | Delete character |
| `Delete` | Clear entry |
| `Esc` | All clear |
| `←` `→` | Move cursor |

---

## Project layout

```
lib/
  core/           # pure Dart, no Flutter imports
    rational.dart   exact BigInt rationals
    num.dart        double + optional exact form
    lexer.dart      glyph normalisation and tokenising
    ast.dart        expression tree
    parser.dart     Pratt parser
    functions.dart  function library, constants, angle modes
    evaluator.dart  tree walker with variable/Ans bindings
    format.dart     display formatting (NORM/FIX/SCI, ENG, SI, fractions)
    engine.dart     public facade: evaluateExpression / previewExpression
  state/
    calc_state.dart # single ChangeNotifier: editing, history, settings, persistence
  theme/
    themes.dart     palettes, brightness modes, ThemeData
  ui/
    widgets.dart    KeyCap, PixelPanel, PixelSegmented, PixelSwitch
    keypad.dart     key matrix and SHIFT/ALPHA dispatch
    display_panel.dart
    calculator_screen.dart
    home_shell.dart
    history_page.dart
    variables_page.dart
    constants_page.dart
    settings_page.dart
test/
  engine_test.dart  engine, parser, formatting
  widget_test.dart  smoke test
tool/
  gen_icons.dart    generates launcher icons
```

The engine has **no Flutter dependency**, which is why it can be tested directly
and reused later (CLI, server, another UI).

---

## Building

Prerequisites: Flutter 3.47+ (Dart 3.13+), Android SDK for Android builds,
Xcode on macOS for iOS.

```bash
flutter pub get
flutter analyze
flutter test
```

### Android

```bash
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

Application id `com.vectorcalc.app`. When `android/key.properties` exists
(see `android/key.properties.example`), release builds are signed with the
project's own release key; the keystore and passwords are git-ignored and must
never be committed. Without that file Flutter falls back to the debug keystore,
which is fine for local testing but not for distribution.

CI builds in `.github/workflows/android.yml` are **debug-signed** because no
signing secrets are exposed to pull requests; treat those artifacts as test
builds, not releases.

The APK is a universal build (arm64-v8a, armeabi-v7a, x86_64), about 48 MB.
For a smaller download use `flutter build apk --split-per-abi` and ship the
`arm64-v8a` split.

#### Android toolchain note (AGP 9)

This project uses AGP 9.1 with **built-in Kotlin**:

```properties
# android/gradle.properties
android.builtInKotlin=true
```

Do not set it back to `false`. With `android.builtInKotlin=false` Flutter
applies the legacy Kotlin Gradle Plugin to plugin modules, and AGP 9's
legacy-DSL `bundleLibCompileToJar` task emits an empty `classes.jar` for them.
The build then fails with:

```
GeneratedPluginRegistrant.java: error: package io.flutter.plugins.sharedpreferences does not exist
```

`shared_preferences_android` is already migrated to built-in Kotlin, so the
modern path works for the app and its only plugin. Flutter 3.47+ is required
for `android.builtInKotlin=true`.

### iOS

iOS requires macOS with Xcode. Push to GitHub and run the **iOS** workflow
(`.github/workflows/ios.yml`), which produces an unsigned `Runner.app` artifact
on a macOS runner. Signing instructions are in the workflow header.

### Web

```bash
flutter build web --release
# build/web
```

Serve it over HTTP rather than opening `index.html` directly, so that the
CanvasKit assets and service worker load:

```bash
python -m http.server 8080 --directory build/web
```

### Platform folders

Only `android/`, `ios/`, and `web/` are checked in. The native `windows/`,
`macos/`, and `linux/` runners are not part of this project.

Icons for all platforms come from one source:

```bash
dart run tool/gen_icons.dart      # assets/icon
dart run flutter_launcher_icons   # Android, iOS, web
```

---

## Notes and limits

- Calculus (`∫`, `d/dx`, `Σ`) is not in this version. It is the next milestone,
  not a hidden flag.
- MATRIX and EQN work up to 3×3 / cubic; larger systems are out of scope for the
  keypad form factor.
- STAT input is a typed list of numbers rather than a dedicated spreadsheet
  editor.
- `1/0` is reported as `Math ERROR`, matching Casio behaviour.
- Trig results are snapped to exact integers when they land within `1e-14`, so
  `sin(30)` displays `0.5` rather than `0.49999999999999994`.
- History and variables persist through `shared_preferences`; everything else is
  in-memory state. Nothing is ever sent anywhere — see [PRIVACY.md](PRIVACY.md).
- There is exactly one plugin dependency (`shared_preferences`). Everything
  else is pure Dart.

---

## License

[MIT](LICENSE) © 2026 saxshamdev.

Third-party assets (fonts VT323 and Press Start 2P) are licensed under the SIL
Open Font License; see `assets/fonts/` for their license files.
