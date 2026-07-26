# Building Battery Full Alarm

## Toolchain

| | Version used |
|---|---|
| Flutter | 3.44.6 (stable) |
| Dart | 3.12.2 |
| JDK | 17 |
| Android Gradle Plugin | 9.0.1 |
| Gradle | 9.1 |
| compileSdk / targetSdk | from the Flutter SDK (currently 36) |
| minSdk | 26 (Android 8.0) |

Check the toolchain with `flutter doctor -v`. Everything above is free; no paid
plugin, licence key or account is required at any point.

---

## Setup

```bash
flutter pub get
```

Localisation sources live in `lib/l10n/*.arb`. The generated Dart is committed, but
after editing an `.arb` file regenerate it:

```bash
flutter gen-l10n
```

---

## Debug build

```bash
flutter run                      # attached device or emulator
flutter build apk --debug        # build/app/outputs/flutter-apk/app-debug.apk
```

The debug build uses the application id `com.hananideas.batteryalarm.debug`, so it
installs side by side with a release build.

---

## Release signing

Release builds fall back to the debug key when no keystore is configured, so
`flutter build apk --release` works on a fresh clone. **A real key is required before
distributing the app.**

### 1. Generate an upload key

```bash
keytool -genkey -v \
  -keystore ~/battery-alarm-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Keep this file and its passwords safe and backed up. Losing the upload key means you
can no longer publish updates to the same Play Store listing.

### 2. Point the build at it

Create `android/key.properties` (already git-ignored — never commit it):

```properties
storeFile=/Users/you/battery-alarm-upload.jks
storePassword=your-store-password
keyAlias=upload
keyPassword=your-key-password
```

`android/key.properties.example` is a copyable template. When this file is present the
release build signs with it automatically; when it is absent the debug key is used and
the build prints no error — so check the signature before shipping:

```bash
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

---

## Release builds

```bash
# Universal APK — for direct install or sideloading
flutter build apk --release

# Per-ABI APKs — roughly half the size each
flutter build apk --release --split-per-abi

# App bundle — the format Google Play requires
flutter build appbundle --release
```

Outputs:

| Command | Path | Size |
|---|---|---|
| `build apk` | `build/app/outputs/flutter-apk/app-release.apk` | ~54 MB (all ABIs) |
| `build apk --split-per-abi` | `build/app/outputs/flutter-apk/app-<abi>-release.apk` | 16–20 MB each |
| `build appbundle` | `build/app/outputs/bundle/release/app-release.aab` | ~53 MB upload; Play delivers ~19 MB per device |

The universal APK is large because it carries the Flutter engine for arm64, arm32 and
x86_64. Users only ever download one of those — use the app bundle for Play, or
`--split-per-abi` for direct distribution.

Release builds run R8 with `isMinifyEnabled` and `isShrinkResources` on. Rules for the
app's own native surface are in `android/app/proguard-rules.pro`; line numbers are
kept so crash reports stay readable.

---

## Tests

```bash
# Dart unit + widget tests
flutter test

# Kotlin unit tests for the monitoring logic
cd android && ./gradlew :app:testDebugUnitTest

# On-device end-to-end tests (needs a connected device or emulator)
flutter test integration_test -d <device-id>

# Static analysis — must be clean before a release
flutter analyze
```

The Kotlin tests cover `MonitorPolicy` (the full charge → alarm → unplug decision
table), `MessageFormatter` and `AppSettings` sanitisation. The Dart tests mirror those
message-formatting cases, so a change on one side of the platform boundary that is not
mirrored on the other shows up as a failure.

---

## Versioning

The version comes from `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        ^^^^^ versionName   ^ versionCode
```

Raise the build number for every Play Store upload. Override per build if needed:

```bash
flutter build appbundle --release --build-name=1.1.0 --build-number=2
```

---

## Play Store submission checklist

- [ ] `flutter analyze` reports no issues
- [ ] `flutter test` and `./gradlew :app:testDebugUnitTest` pass
- [ ] `android/key.properties` points at the real upload keystore
- [ ] Version name and build number raised
- [ ] `flutter build appbundle --release` produces `app-release.aab`
- [ ] Installed the release build on a physical device and confirmed a full
      charge → alarm → unplug cycle
- [ ] Data safety form filled in as **no data collected, no data shared** — accurate,
      since the app has no `INTERNET` permission
- [ ] Privacy policy published — [PRIVACY.md](PRIVACY.md) is ready to use
- [ ] Foreground service declaration completed. The service type is `specialUse`; the
      justification text is in `AndroidManifest.xml` under
      `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` and can be pasted into the Play Console form.
      Expect to record a short screen capture showing the alarm firing at 100%.
- [ ] Screenshots (phone, 16:9 or 9:16), a 512×512 icon and a 1024×500 feature graphic

### Note on the foreground service type

`ACTION_BATTERY_CHANGED` cannot be received from the manifest, and background
processes are frozen — so a running foreground service is the only way to observe the
battery continuously. None of Android's specific service types describe this work,
which makes `specialUse` the correct and honest declaration. Google Play reviews
`specialUse` manually; the justification string in the manifest is written for that
review.

---

## Known build warnings

`device_info_plus` and `package_info_plus` still apply the Kotlin Gradle Plugin, so
recent Flutter versions print a warning about migrating to built-in Kotlin. The app's
own module does not apply KGP. The warning is about future Flutter releases and comes
from those upstream plugins; it does not affect this build. Both packages are used
only by the About screen and can be dropped if the warning ever becomes an error.
