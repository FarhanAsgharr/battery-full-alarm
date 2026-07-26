# Installing Battery Full Alarm

## Requirements

- Android 8.0 (API 26) or newer
- A text-to-speech engine (every Android device ships with one; Google
  Text-to-Speech is the usual default)

Nothing else. No account, no sign-in, no internet connection — the app has no network
permission and works fully offline from the first launch.

---

## Option A — install a prebuilt APK

1. Copy `app-release.apk` to the phone.
2. Open it with the Files app and tap **Install**.
3. Android will ask to allow installs from this source the first time. Approve it and
   tap Install again.
4. Open **Battery Full Alarm**.

The APK produced by `flutter build apk --release` is a universal binary and runs on
both arm64 and arm32 devices. For a smaller download, see the per-ABI split in
[BUILD.md](BUILD.md).

## Option B — install from source over USB

1. Enable **Developer options** on the phone: Settings → About phone → tap
   *Build number* seven times.
2. Turn on **USB debugging** in Settings → System → Developer options.
3. Connect the phone and confirm the debugging prompt.
4. From the project folder:

```bash
flutter devices          # confirm the phone is listed
flutter run --release    # build, install and launch
```

---

## First run

### 1. Allow notifications

On Android 13 and newer the app asks for notification permission the first time you
switch monitoring on. **Allow it.** The ongoing notification is what Android requires
to keep the monitoring service alive — without it the service can be stopped and the
alarm will not fire. The notification itself is silent and shows the live battery
percentage.

### 2. Switch monitoring on

Move the **Monitoring** switch on the home screen to on. The card turns green and the
ongoing notification appears.

### 3. Remove background restrictions

If the home screen shows *"Battery optimisation is on"*, tap **Open settings**, find
**Battery Full Alarm** in the list and set it to **Unrestricted** (wording varies by
manufacturer — "Don't optimise", "No restrictions", "Allow background activity").

This step matters most on Xiaomi/MIUI, Huawei/EMUI, Oppo/ColorOS, Vivo/FuntouchOS and
Samsung/One UI, which stop background services aggressively. On those phones also:

| Manufacturer | Extra step |
|---|---|
| Xiaomi (MIUI) | Security → Permissions → Autostart → enable for this app. In Recents, long-press the app card and tap the lock icon. |
| Huawei (EMUI) | Settings → Battery → App launch → set the app to *Manage manually* with all three toggles on. |
| Oppo / Realme (ColorOS) | Settings → Battery → App battery management → allow background running. |
| Vivo (Funtouch) | Settings → Battery → Background power consumption management → allow. |
| Samsung (One UI) | Settings → Battery → Background usage limits → make sure the app is **not** in "Sleeping apps" or "Deep sleeping apps". |

### 4. Personalise the announcement

Settings → **Announcement**:
- Set **Your name** so the message greets you by name.
- Edit the sentence, or pick one of the suggestions. Tap the **Your name** and
  **Battery level** tags to insert them where you want.
- Adjust speech speed and pitch, then tap **Play preview** to hear it.

### 5. Choose the alarm sound

Settings → **Alarm sound**:
- Pick any alarm ringtone already on the device, **or**
- **Import audio file** to use your own MP3 / M4A / OGG, **or**
- **Record your voice** — grant microphone access when asked. Recordings are limited
  to 30 seconds and are stored only in the app's private folder.

### 6. Set the repeat interval and volume

Settings → **Alarm** → *Repeat every* (5, 10, 15, 30 or 60 seconds) and
*Alarm volume*. The alarm plays on the alarm audio stream, so it is audible even when
the phone is on silent.

### 7. Test it

Tap **Test alarm** at the bottom of the home screen. One full cycle plays: alarm tone,
spoken message, vibration and torch (if enabled). Tap **Stop** in the snackbar to end
it early.

---

## Using it

Plug the charger in. That is all. The notification tracks the level; when it reaches
100% the alarm starts and repeats at your interval. Unplug the charger and everything
stops immediately.

To silence the alarm without unplugging, tap **Stop alarm** in the notification or on
the home screen — it stays silent for the rest of that charging session and re-arms
automatically the next time you plug in.

---

## Troubleshooting

**The alarm never fires**
- Is the Monitoring switch on, and does the home screen show the ongoing notification?
- Check the warnings on the home screen — each one names the thing that is blocking it.
- Confirm background restrictions are removed (step 3 above).
- Some batteries settle at 99% and never report 100%. The app alarms at 100% only;
  check the level shown on the home screen while charging.

**No voice, only the alarm tone**
- Settings → *Speak the message* must be on.
- If the home screen warns *"Voice not available for this language"*, tap
  **Text-to-speech settings** and install the voice data for that language, or switch
  the app language to English.

**The alarm is too quiet**
- Raise *Alarm volume* in Settings. It sets the system **alarm** stream, not the media
  or ringer volume.

**Monitoring stops overnight**
- Almost always background restrictions. Repeat step 3 and the manufacturer-specific
  step for your phone.

**Nothing after a reboot**
- Settings → Startup → turn on **Start after restart**.

---

## Uninstalling

Long-press the app icon → **Uninstall**, or Settings → Apps → Battery Full Alarm →
Uninstall. Every setting, recording and history entry lives in the app's private
storage and is deleted with it. Nothing is left behind and nothing was ever uploaded.
