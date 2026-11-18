# VECTORCALC

An offline engineering and scientific calculator. Retro-clean, minimal, and
built for people who actually work in engineering units.

- **No accounts, no analytics, no network calls.** The app never opens a socket.
- **One codebase** — Android, iOS, web, and desktop (Electron wrapper).
- **Exact results** — fractions and integers are kept exact with `BigInt`
  rationals, so `1/3 + 1/6` really is `1/2`, and `S⇔D` flips between forms.
- **Engineering first** — SI prefixes, engineering notation, physical constants,
  DMS entry, angle modes, and an ES PLUS–style keypad.

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

### Input
- ES PLUS–style 8×5 keypad with `SHIFT` and `ALPHA` layers
- Horizontally scrollable function strip for the less-used functions
- Full physical-keyboard support on desktop and web
- Cursor movement and mid-expression editing

---

## Keyboard shortcuts (desktop / web)

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
  gen_icons.dart    generates launcher icons (incl. desktop .ico)
desktop/
  main.js           Electron shell with a loopback-only static server
  package.json      electron-builder config
  scripts/sync-web.js
```

The engine has **no Flutter dependency**, which is why it can be tested directly
and reused later (CLI, server, another UI).

---

## Building

Prerequisites: Flutter 3.24+ (Dart 3.5+), Android SDK for Android builds,
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

Application id `com.vectorcalc.app`. Release builds are currently signed with
the debug keystore so they install directly; replace the signing config in
`android/app/build.gradle.kts` before publishing to a store.

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

iOS cannot be compiled on Windows. Push to GitHub and run the **iOS** workflow
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

### Desktop (Windows / Linux / macOS)

The desktop build wraps the web build in Electron, so there is no Visual Studio
or Xcode requirement.

```bash
flutter build web --release
cd desktop
npm install
npm run start        # run it
npm run dist         # Windows installer + portable .exe in desktop/dist
npm run dist:linux   # AppImage
```

`npm run sync` copies `build/web` into `desktop/web`; `main.js` serves that
folder from `127.0.0.1` on a random port and blocks all other navigation. The
only network interface is a loopback socket to the app's own assets — nothing
leaves the machine.

### Platform folders

Only `android/`, `ios/`, and `web/` are checked in. The native `windows/`,
`macos/`, and `linux/` runners were removed because desktop ships through
Electron and none of them could be built on this machine. If you ever want the
native targets back:

```bash
flutter create --platforms=windows,macos,linux .
```

The native Windows target additionally needs the Visual Studio C++ workload.

Icons for all platforms come from one source:

```bash
dart run tool/gen_icons.dart      # assets/icon + desktop/build-resources
dart run flutter_launcher_icons   # Android, iOS, web
```

---

## Notes and limits

- Complex numbers, equation solving, matrices, and calculus (`∫`, `d/dx`, `Σ`)
  are **not** in this version. They are the next milestone, not a hidden flag.
- `1/0` is reported as `Math ERROR`, matching Casio behaviour.
- Trig results are snapped to exact integers when they land within `1e-14`, so
  `sin(30)` displays `0.5` rather than `0.49999999999999994`.
- History and variables persist through `shared_preferences`; everything else is
  in-memory state.
- There is exactly one plugin dependency (`shared_preferences`). Everything
  else is pure Dart.

---

## License

MIT.
