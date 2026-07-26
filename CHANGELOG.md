# Changelog

All notable changes to Battery Full Alarm. Newest first.

This project follows [Semantic Versioning](https://semver.org/).

---

## 1.1.0 — 26 July 2026

First build published as a downloadable APK.

> **Signing note:** the 1.1.0 APKs are signed with a **debug key**, because no upload
> keystore exists yet. They install and run normally, but Android will refuse to update
> them from a properly-signed release later — that requires uninstalling first, which
> loses your settings and history. Treat this build as a preview.

### Added

- **Remove any alarm sound.** Every entry in the picker now has a Delete action.
  - Sounds you imported or recorded are deleted from storage.
  - The entries under *On this device* are your phone's own ringtones, reached through
    `RingtoneManager` — deleting one would take it away from your clock app and every
    other alarm app, so those are **hidden** from the list instead. The confirmation
    dialog says so rather than pretending otherwise.
  - Hiding survives an app restart and a device reboot.
- **Restore default sounds** in Settings → Alarm, with a confirmation step. It reports
  how many sounds are hidden and is disabled when there is nothing to restore. The same
  action is offered inline once the list has been emptied.
- Removing the sound that is currently selected as your alarm resets the selection to
  your device's default tone, so the alarm can never point at something that is gone.
- Average charge gained is now shown on the Statistics screen (it was calculated but
  never displayed).
- A proper adaptive app icon, replacing the Flutter placeholder.

### Fixed — reliability

- The alarm no longer loses timing accuracy after an hour. The wake lock is re-armed on
  every repeat instead of once per alarm, so `Doze` cannot stretch a 10-second interval
  into minutes.
- Vibration and the torch are now perceptible when both the alarm sound and the spoken
  message are switched off. Previously the burst began and ended in the same frame.
- If your chosen alarm sound disappears, the alarm falls back to the device default
  instead of playing nothing.
- A charging session left open by a killed process is now closed at the last moment the
  battery was known to be charging, rather than showing "In progress" for ever.
- A stale alarm notification left behind by a killed process is cleared on restart.
- Monitoring is restored after an app update (`MY_PACKAGE_REPLACED`), not only after a
  reboot.
- A `JobScheduler` watchdog restarts the monitor if an aggressive task-killer stops it.
  Aimed at Xiaomi, Oppo, Realme, Vivo and Huawei, where `START_STICKY` is often ignored.
  Best-effort: Android 12+ still refuses the restart unless the app is exempt from
  battery optimisation.
- Text-to-speech now initialises on a worker thread. It was binding to the platform TTS
  service on the main looper during service startup — the same thread Flutter draws on.
- Long alarm tones and long spoken messages are no longer cut short. The internal
  watchdogs were set below the longest legitimate case.

### Fixed — privacy

- **Android cloud backup is now disabled.** At its default it would have copied your
  settings, charging history and any recorded voice clip to your Google Drive, which
  contradicted the app's central claim. `allowBackup` is off and the Android 12+
  extraction rules exclude everything.
- If the app is killed while an alarm is ringing, your system alarm volume is now
  restored on the next launch. Previously it could stay pinned at whatever the app set.

### Fixed — interface

- Leaving the alarm sound screen while the file picker or a permission dialog was open
  no longer crashes the app.
- The volume and speech sliders no longer write to storage and cross the platform
  channel on every frame of a drag; they save once, when you let go.
- The announcement editor saves after a pause in typing rather than on every keystroke.
- The battery gauge and the statistics tiles no longer overflow at large system font
  sizes.
- The ongoing notification is only re-posted when its visible text actually changes.
  It was being rebuilt several times a minute, because the battery broadcast also fires
  for temperature drift.

---

## 1.0.0 — internal

The initial build. **Never published** — no APK was released for this version, so there
is nothing to upgrade from.

- Foreground service watching `ACTION_BATTERY_CHANGED`, alarming at 100% while plugged
  in and stopping the instant the charger is removed.
- Repeating alarm chain: tone → spoken announcement → vibration and torch → wait your
  chosen interval → repeat.
- Custom announcement with `{name}` and `{level}` tags, adjustable speech speed and
  pitch, using the platform text-to-speech engine.
- Alarm sound from the device's ringtones, an imported audio file, or a clip recorded
  in the app.
- Charging history and daily/weekly/monthly statistics, stored only on the device.
- English, Urdu, Arabic and Hindi, with right-to-left layout.
- Material 3 with light, dark and system themes.
