# Changelog

All notable changes to VECTORCALC are documented here. This project follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-11-18

First public release.

### Added

- Exact rational arithmetic (`BigInt`) with `S⇔D` exact/decimal toggle and
  mixed-fraction display
- Engineering display: NORM/FIX/SCI, engineering notation, SI prefixes, DMS
- Full scientific keypad with SHIFT/ALPHA layers and physical-keyboard support
- Variables `A`–`F`, `X`, `Y`, `M`; 100-entry persistent history; 25 constants
- Modes: CMPLX, STAT (with regression), BASE-N, EQN, MATRIX, TABLE, VECTOR
- Five themes with bright/night variants
- Android and web builds, plus an iOS build via GitHub Actions
- iOS support via GitHub Actions macOS runner

### Privacy

- No accounts, analytics, ads, telemetry, or network access
- Android release manifest does not request `INTERNET`
- All state stored locally and removed with app data / uninstall

[1.0.0]: https://github.com/saxshamdev/vectorcalc/releases/tag/v1.0.0
