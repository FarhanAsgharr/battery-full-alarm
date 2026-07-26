# Battery Full Alarm

An Android app that watches the battery while charging and — the moment it reaches
**100%** — sounds an alarm, speaks a custom message, vibrates and flashes the torch,
repeating at an interval you choose until you unplug the charger.

Built entirely with free and open-source tools. **No accounts, no cloud, no network
access at all** — the app does not declare the `INTERNET` permission, so it *cannot*
send anything anywhere even if it wanted to.

---

## What it does

```
Charger connected
        │
        ▼
Foreground service watches ACTION_BATTERY_CHANGED
        │
        ├── level < 100%  ──►  keep watching (notification shows live %)
        │
        └── level == 100% while plugged in
                    │
                    ▼
            Alarm tone  ──►  spoken announcement
                    │
                    ▼
            wait your interval (5 / 10 / 15 / 30 / 60 s)
                    │
                    ├── still plugged in?  ──►  repeat
                    │
                    └── charger removed    ──►  stop everything instantly,
                                                log the session, keep watching
```

## Features

**Monitoring**
- Live battery level, charging state, charger type, temperature, voltage and health
- Runs continuously in a foreground service, screen on or off
- Optional restart after reboot
- Instant stop the moment the charger is pulled

**Voice announcement** — Android's built-in text-to-speech, nothing downloaded
- Editable message with `{name}` and `{level}` tags
- Your name, speech speed and pitch
- English, Urdu, Arabic and Hindi voices

**Alarm**
- Any alarm ringtone already on the device
- Import your own audio file
- Record your own voice in the app
- Repeat interval: 5, 10, 15, 30 or 60 seconds
- Alarm volume, vibration and torch flashing, each independently switchable

**History and statistics** — stored on the device only
- Every charging session: time, levels, duration, time to full, alarms played
- Daily / weekly / monthly summaries with averages and a sessions-per-day chart

**Interface**
- Material 3, light / dark / system theme
- Full UI translation into English, Urdu, Arabic and Hindi, with right-to-left layout

## Requirements

| | |
|---|---|
| Android | 8.0 (API 26) or newer |
| Flutter | 3.44 or newer |
| JDK | 17 |

## Quick start

```bash
flutter pub get
flutter run
```

See [INSTALL.md](INSTALL.md) to install a build on a phone, and [BUILD.md](BUILD.md)
to produce a signed release APK or Play Store bundle.

## Permissions

Nothing is requested that a feature does not need.

| Permission | Why | Optional |
|---|---|---|
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE` | Observe the battery continuously | no |
| `POST_NOTIFICATIONS` | The ongoing notification Android requires for that service | no |
| `VIBRATE` | Alarm vibration | no |
| `WAKE_LOCK` | Keep the alarm running with the screen off | no |
| `RECEIVE_BOOT_COMPLETED` | Resume monitoring after a restart | yes — only if you enable it |
| `RECORD_AUDIO` | Record a custom alarm clip | yes — only when you tap Record |

Deliberately **not** requested: `INTERNET`, `CAMERA` (the torch uses `setTorchMode`,
which needs no permission), storage, location, contacts, phone state.

## Dependencies

Every dependency is free, open-source and permissively licensed. No paid API, SDK,
subscription or account is involved anywhere in the project.

| Package | Purpose | Licence |
|---|---|---|
| `flutter_riverpod` | State management | MIT |
| `go_router` | Navigation | BSD-3-Clause |
| `shared_preferences` | Local settings storage | BSD-3-Clause |
| `permission_handler` | Runtime permission requests | MIT |
| `intl` | Date, number and message formatting | BSD-3-Clause |
| `package_info_plus`, `device_info_plus` | Version and device info on the About screen | BSD-3-Clause |
| `flutter_lints` (dev) | Lint rules | BSD-3-Clause |
| `integration_test` (dev) | On-device tests | BSD-3-Clause |

Audio playback, text-to-speech, vibration, the torch, file import and voice recording
all use the Android platform directly, so no extra package is needed for them.

## Documentation

- [INSTALL.md](INSTALL.md) — installing and first-run setup
- [BUILD.md](BUILD.md) — building, signing and releasing
- [ARCHITECTURE.md](ARCHITECTURE.md) — how the code is organised and why
- [PRIVACY.md](PRIVACY.md) — the privacy policy, ready for a Play Store listing

## Tests

```bash
flutter test                                    # 82 Dart unit and widget tests
cd android && ./gradlew :app:testDebugUnitTest   # 36 Kotlin unit tests
flutter test integration_test -d <device-id>    # on-device end-to-end tests
flutter analyze                                 # static analysis
```

The Kotlin tests simulate whole charging sessions through the alarm decision logic —
including devices that report `FULL` or `NOT_CHARGING` at 100%, a level that falls back
below full while plugged in, and the alarm being dismissed mid-session.

## Licence

Released under the MIT Licence — see [LICENSE](LICENSE).
