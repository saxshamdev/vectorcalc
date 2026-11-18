# Contributing

Thanks for considering a contribution. VECTORCALC is a small, dependency-light
Flutter app, and it is meant to stay that way.

## Before you start

- For anything larger than a bug fix, open an issue first so we can agree on the
  approach.
- Security issues go through the private channel in [SECURITY.md](SECURITY.md),
  not the public issue tracker.
- By contributing you agree that your work is licensed under the MIT License.

## Ground rules

- **No network, telemetry, or tracking code.** This is a privacy-first app; pull
  requests that add analytics, ads, crash reporting, or remote calls will not be
  merged.
- **Keep the engine pure.** `lib/core/` must not import Flutter. It is plain Dart
  so it can be tested and reused.
- **One plugin only.** `shared_preferences` is the sole plugin dependency; new
  plugins need a strong justification.
- **Match the design.** Square corners, hairline borders, no blur, no decorative
  animation. Use the existing `widgets.dart` primitives instead of raw Material
  widgets where possible.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome     # or: -d windows, -d android
```

Before opening a pull request:

```bash
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib test tool
```

## Commit messages

Short imperative subject lines, for example:

```
Fix DMS parsing for negative angles
Add cubic root approximation note to README
```

## Reporting bugs

Use the bug report template and include the app version, platform, exact
expression, and steps to reproduce. Screenshots help; please redact anything
personal.
