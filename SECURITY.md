# Security Policy

## Supported versions

| Version | Supported |
| --- | --- |
| 1.0.x | ✅ |
| < 1.0 | ❌ |

Only the latest release receives fixes. Updates are published on the
[Releases page](https://github.com/saxshamdev/vectorcalc/releases).

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Use GitHub's private vulnerability reporting:

1. Go to <https://github.com/saxshamdev/vectorcalc/security/advisories/new>
2. Describe the issue, the affected version and platform, and how to reproduce it
3. If you can, include a proof of concept or a patch suggestion

You can expect an acknowledgement within **72 hours** and a status update within
**7 days**. Please give us a reasonable window to ship a fix before any public
disclosure; we will credit you in the advisory and release notes unless you ask
us not to.

This is a volunteer project, so these timelines are best-effort rather than a
contractual guarantee.

## What is in scope

- The Flutter application code in `lib/`
- The Android and iOS platform configuration
- The Electron desktop wrapper in `desktop/`
- The release artifacts published on GitHub

Out of scope: third-party dependencies (report those upstream), issues that
require an already-compromised device, and social-engineering attacks.

## How releases are built

- Release binaries are built from the source in this repository at the tagged
  commit, on the maintainer's machine, and uploaded by hand to GitHub Releases.
- The Android APK is signed with the project's own release key, never a debug
  key. CI artifacts (GitHub Actions → *Artifacts*) are **debug-signed builds for
  testing only** and must not be redistributed as official releases.
- Each release ships a `SHA256SUMS.txt` file covering every uploaded asset.

### Verify a download

Windows (PowerShell):

```powershell
Get-FileHash .\VECTORCALC-1.0.0-android.apk -Algorithm SHA256
```

Linux / macOS:

```bash
sha256sum -c SHA256SUMS.txt
```

Compare the output with the value in `SHA256SUMS.txt` from the same release.

### Android signing certificate

To confirm an APK is signed by this project:

```bash
apksigner verify --print-certs VECTORCALC-1.0.0-android.apk
```

The certificate's SHA-256 fingerprint is published in each release's notes.
A mismatch means the file did not come from this project.

## Security design

- No network access: the app has no HTTP client, and the Android release
  manifest does not request the `INTERNET` permission.
- No third-party SDKs for analytics, ads, crash reporting, or attribution.
- All user data stays in app-private local storage (see [PRIVACY.md](PRIVACY.md)).
- The desktop wrapper serves bundled assets over a loopback-only socket and
  blocks navigation to any other origin.
- The expression engine is a hand-written lexer/parser/evaluator with explicit
  depth and size limits; it does not use `eval` or reflection.
