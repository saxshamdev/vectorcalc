# Privacy Policy

**VECTORCALC collects no data. It has no accounts, no analytics, no ads, no
telemetry, and no crash reporting. Nothing you type, calculate, or store ever
leaves your device.**

Last updated: 18 November 2026

---

## Summary

| Question | Answer |
| --- | --- |
| Do you collect personal data? | No. |
| Do you use analytics, ads, or trackers? | No. |
| Does the app need an internet connection? | No. It works fully offline. |
| Does the Android build request the `INTERNET` permission? | No. |
| Is data sent to a server? | Never. |
| Do you sell or share data? | We have no data to sell or share. |

---

## What the app stores (and where)

VECTORCALC keeps your calculator state so it is still there when you reopen the
app. This information is written to **local storage only**:

- the last expression and cursor position
- calculation history (up to 100 entries)
- variable values `A`–`F`, `X`, `Y`, `M`
- display and angle settings, theme, and brightness
- `Ans` and `PreAns`

Storage location by platform:

| Platform | Where the data lives |
| --- | --- |
| Android | App-private `SharedPreferences` (not readable by other apps) |
| iOS | App-private `NSUserDefaults` |
| Web | Your browser's `localStorage` for this site |
| Windows / Linux / macOS (Electron) | Chromium `localStorage` inside the app's user-data folder |

You can erase everything at any time by clearing the app's storage in your OS
settings (Android: *Settings → Apps → VECTORCALC → Storage → Clear data*;
browser: clear site data; desktop: delete the app's user-data folder) or by
uninstalling the app.

---

## Network activity

- The calculation engine (`lib/core/`) is pure Dart and has no networking code.
- The release Android manifest does **not** declare `android.permission.INTERNET`.
- The desktop app starts a tiny static file server bound to `127.0.0.1`
  (loopback only) so the Electron window can load its own bundled assets. It
  cannot be reached from other machines and serves nothing but the app's files.
- The web build is static files. If you host it yourself, your web server may
  keep ordinary access logs — that is under your control, not the app's.

## Downloads and this repository

Installing an update means downloading it from **GitHub Releases**. GitHub may
log standard request data (such as IP address and user agent) as part of
serving that download, under [GitHub's privacy
statement](https://docs.github.com/site-policy/privacy-policies/github-general-privacy-statement).
The app itself does not check for updates or contact GitHub at runtime.

Browsing this repository on GitHub is likewise governed by GitHub's policies.
Nothing about the app's use is ever reported back here.

## Permissions

VECTORCALC requests no runtime permissions: no camera, microphone, location,
contacts, storage, or network access. The only manifest entries are the
standard Flutter launcher/activity declarations.

## Children's privacy

Because no data is collected at all, the app is safe for all ages and complies
trivially with COPPA, GDPR, and similar regimes: there is no personal data to
process, transfer, or delete.

## Changes to this policy

If a future version ever adds a feature that touches the network, this document
will be updated **before** that version ships, and the change will be called out
in the release notes. Until then, the statement at the top of this page remains
true.

## Contact

Questions about privacy: open an issue at
<https://github.com/saxshamdev/vectorcalc/issues> or use the private reporting
channel described in [SECURITY.md](SECURITY.md).
