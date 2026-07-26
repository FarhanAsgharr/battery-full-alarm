# Architecture

## The central constraint

Everything about this app's structure follows from one Android fact:

> `ACTION_BATTERY_CHANGED` **cannot** be registered in the manifest. It is only
> delivered to a receiver registered at runtime by a live process — and background
> processes are frozen.

So the app cannot be a Flutter app that occasionally checks the battery. The part that
watches the battery has to be a native foreground service that outlives the Flutter
engine, because the Flutter engine is destroyed as soon as the user swipes the app
away — which is exactly when most overnight charges happen.

That gives the split:

| Layer | Owns | Alive when |
|---|---|---|
| **Kotlin** | Battery observation, the alarm, the charging log, the notification | Always, while monitoring is on |
| **Dart** | Every screen, settings editing, statistics, history presentation | Only while the user has the app open |

Anything the alarm needs at 3 a.m. lives in Kotlin. Anything only a human looking at
the screen needs lives in Dart.

---

## Native layer (`android/app/src/main/kotlin/com/hananideas/batteryalarm/`)

```
core/
  BatterySnapshot.kt    Decoded battery reading; no framework state
  MonitorPolicy.kt      "Should the alarm be ringing?" — pure functions
  MessageFormatter.kt   Template → spoken sentence
  AppBus.kt             In-process events → the Flutter EventChannel
  Constants.kt          Channel names, actions, prefs keys
data/
  AppSettings.kt        Settings mirror the service reads
  ChargeSession.kt      One charger-in → charger-out cycle
  HistoryStore.kt       JSON log in private SharedPreferences (capped at 500)
  SoundLibrary.kt       Device ringtones + imported/recorded files
alarm/
  AlarmPlayer.kt        The burst → speak → wait → repeat cycle
  SpeechEngine.kt       TextToSpeech wrapper, alarm stream, async-init safe
  TorchController.kt    Flash blinking via setTorchMode (no CAMERA permission)
  VibrationController.kt
service/
  BatteryMonitorService.kt   The foreground service
  ServiceNotifications.kt    Both notifications, in the user's chosen language
  BootReceiver.kt            Optional restart after reboot
  PowerConnectionReceiver.kt Opportunistic restart if the service died
media/
  VoiceRecorder.kt      MediaRecorder → the app's private sound folder
MainActivity.kt         The only Dart↔Kotlin bridge
```

### Why the decision logic is a pure object

`MonitorPolicy.decide(snapshot, state, monitoringEnabled)` returns
`START_ALARM` / `STOP_ALARM` / `NONE` and touches nothing else. That is what makes the
whole "plug in, charge to 100%, alarm, unplug" behaviour testable on the JVM in
`BatterySimulationTest`, including the awkward cases:

- devices that report `BATTERY_STATUS_FULL` or `NOT_CHARGING` at 100% instead of
  `CHARGING` — `plugged` is treated as the ground truth for "a charger is attached";
- a level that drops back below 100% while still plugged in;
- the user silencing the alarm, which latches until the charger comes out.

### Why a `Handler`, not `AlarmManager`

Repeat intervals here are 5–60 seconds and the service is already running. A
main-looper `Handler` inside that service is exact, costs nothing while idle, and
avoids `SCHEDULE_EXACT_ALARM` — a permission that is restricted on Google Play and
would be hard to justify for this app.

### Why `specialUse`

Android 14 requires every foreground service to declare a type. None of the specific
types (dataSync, mediaPlayback, location, …) describes continuous battery observation,
so `specialUse` is the honest declaration, with the justification text in the manifest
for Play review. `specialUse` is also permitted to start from `BOOT_COMPLETED`, which
is what makes "resume after restart" work.

### Staying alive on hostile devices

Three layers, in order of how much they can be relied on:

1. **The service simply keeps running.** This is the primary mechanism and the only
   one that is precise.
2. **`BootReceiver`** restarts it after a reboot *and after an app update*
   (`MY_PACKAGE_REPLACED`) — both are on the short list of broadcasts still allowed to
   start a foreground service from the background.
3. **`MonitorWatchdogJob`**, a persisted 15-minute `JobScheduler` job, restarts the
   service if it finds it stopped. This exists for Xiaomi/MIUI, Oppo and Realme,
   Vivo, and Huawei, where `START_STICKY` is quietly ignored. It is best-effort:
   Android 12+ refuses a foreground-service start from a job unless the app is exempt
   from battery optimisation, which is exactly why the home screen nags about that.

`PowerConnectionReceiver` is a fourth, weakest layer — `ACTION_POWER_CONNECTED` is not
an exempt broadcast, so its restart usually fails on Android 12+. It costs nothing and
helps on older releases.

### Nothing leaves the device — enforced, not promised

- No `INTERNET` permission, so the OS blocks any network call the app could make.
- `allowBackup="false"` plus `dataExtractionRules` excluding everything: without this,
  Android auto-backup would copy settings, the charging log and recorded voice clips to
  the user's Google Drive, which would make the privacy claim false.

### Surviving a process kill

Android kills the process without calling `Service.onDestroy`. `START_STICKY` brings
the service back, and a new instance assumes nothing about the old one:

- it cancels any alarm notification the dead instance left posted, because a fresh
  instance by definition has no alarm ringing;
- it closes any charging session still marked open, ending it at `lastSeenAt` — the
  last moment the battery was actually known to be charging — rather than inventing a
  time or leaving the row "in progress" for ever;
- `VolumeGuard` puts the system alarm volume back. The alarm raises `STREAM_ALARM`
  while ringing and lowers it afterwards; if the process dies in between, the original
  value would be lost with it and the user's alarm volume would stay pinned to whatever
  this app chose. It is therefore written to disk *before* the change, and restored by
  whichever component starts next.

### Settings are stored twice, deliberately

Dart writes to `SharedPreferences` (what the UI reads at launch) **and** pushes the
same map to native storage (what the service reads at 3 a.m.). `SettingsRepository.save`
does both in one call, so the two cannot drift. `main()` re-pushes at every launch, so
a fresh install has native storage populated before the first charge.

---

## Dart layer (`lib/`)

Feature-first, with each feature split into `domain` (immutable models and pure
logic), `data` (repositories over the platform bridge), `providers` (Riverpod wiring)
and `presentation` (screens and widgets).

```
core/
  constants/    Values shared with Kotlin (channel names, intervals, tokens)
  platform/     NativeBridge — the single seam to Kotlin
  providers/    sharedPreferencesProvider, nativeBridgeProvider
  router/       go_router with a StatefulShellRoute for the bottom nav
  theme/        Material 3 light and dark schemes from one seed colour
  utils/        Locale-aware formatters
  widgets/      SectionCard, InfoRow, NoticeBanner
features/
  battery/      Home screen, gauge, live monitor state
  settings/     AppSettings model, repository, settings screen
  voice/        Message template + the announcement editor
  alarm/        Sound library and the alarm sound picker
  history/      Charging log
  statistics/   Aggregation and the summary screen
  notifications/Permission state for the ongoing notification
  about/        Version, device, permissions, privacy statement
l10n/           app_en / app_ur / app_ar / app_hi .arb + generated Dart
```

### The bridge

`NativeBridge` is one class wrapping one `MethodChannel` and one `EventChannel`. Every
method corresponds to a case in `MainActivity.handleMethodCall`. Because the whole
platform surface is in one place, tests replace it wholesale with `FakeNativeBridge` —
which is how charging scenarios and alarm behaviour are tested without a device.

The event channel pushes a full `MonitorSnapshot` (battery + monitoring + service
alive + alarming + current session) rather than deltas, so the UI is a pure function
of the last message received.

### State

Riverpod, with `sharedPreferencesProvider` overridden in `main()` so settings load
synchronously and the first frame already has the user's theme and language.

`SettingsController.update` sanitises, sets state, then persists and pushes to native
— every mutation goes through the same path.

### Two things the UI is careful about

- **Previews run in the activity, not the service.** `MainActivity` owns its own
  `AlarmPlayer` for the sound and voice previews and the Test alarm button, so those
  screens work whether or not monitoring is switched on.
- **Permission prompts never block the switch.** Turning monitoring on starts the
  service immediately and requests notification permission afterwards, so a slow or
  refused system dialog can never leave the user with a switch that did nothing.

---

## Data flow, end to end

```
                      ┌──────────────────────────────────────┐
   ACTION_BATTERY_    │  BatteryMonitorService               │
   CHANGED  ─────────►│    BatterySnapshot.from(intent)      │
                      │    MonitorPolicy.decide(...)         │
                      │      ├─ START_ALARM ─► AlarmPlayer   │──► tone, TTS,
                      │      └─ STOP_ALARM  ─► AlarmPlayer   │    vibration, torch
                      │    HistoryStore.upsert(session)      │
                      │    ServiceNotifications.monitor(...) │──► ongoing notification
                      │    AppBus.emit(state)                │
                      └────────────────┬─────────────────────┘
                                       │  EventChannel
                                       ▼
                      ┌──────────────────────────────────────┐
                      │  monitorStreamProvider (Dart)        │
                      │    └─► home / history / statistics   │
                      └──────────────────────────────────────┘

   Settings edit ──► SettingsController ──► SharedPreferences (UI copy)
                                        └─► MethodChannel ──► native prefs (service copy)
```

---

## Tests

| Where | What it covers |
|---|---|
| `android/app/src/test/kotlin/` | `MonitorPolicy` charge simulations, `MessageFormatter`, `AppSettings` sanitisation |
| `test/features/` | Settings model, statistics aggregation, charge sessions, message template, monitor state decoding, settings→platform propagation |
| `test/widget/` | Home, settings, alarm sound picker, history and statistics screens against `FakeNativeBridge` |
| `integration_test/` | Real launch on a device, against the real Kotlin service |

Counts at the time of writing: 36 Kotlin, 82 Dart.

The message-formatting cases exist in both Kotlin and Dart on purpose: the in-app
preview and the sentence the service speaks come from two separate implementations,
and the mirrored tests are what keep them from disagreeing.

---

## Performance notes

- The service is idle between broadcasts — no polling, no timers while monitoring.
- `ACTION_BATTERY_CHANGED` also fires for temperature and voltage drift, so the
  charging log is only written when the level or plug state actually changes.
- History is capped at 500 sessions.
- The statistics chart is drawn with plain widgets rather than a charting package: the
  data is a handful of integers, and it keeps the dependency list and APK smaller.
- A partial wake lock is held only while an alarm is actually ringing, with a timeout.
