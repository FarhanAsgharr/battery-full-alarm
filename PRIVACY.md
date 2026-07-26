# Privacy Policy — Battery Full Alarm

**Last updated: 26 July 2026**

## Summary

Battery Full Alarm collects nothing, sends nothing and stores everything on your
device. There is no account, no analytics, no advertising and no server.

The app does not request the `INTERNET` permission. Android therefore blocks it from
making any network connection at all — this is enforced by the operating system, not
by a promise.

Android's automatic cloud backup is also switched off (`allowBackup="false"`, with
matching data-extraction rules). Left at its default, it would have copied your
settings, your charging history and any voice clip you recorded to Google Drive. It
does not. The trade-off is that these do not transfer to a new phone; re-entering a
handful of settings is a smaller cost than a recording of your voice leaving the
device.

## What the app stores on your device

All of the following is kept in the app's private storage, readable only by this app:

- Your name and the announcement text you configure
- Your alarm settings: sound, repeat interval, volume, vibration, torch, speech speed
  and pitch
- Your language and theme preference
- Audio files you import or voice clips you record for use as the alarm
- A log of charging sessions: start and end time, battery level at each end, how long
  the charger was connected, when 100% was reached, and how many alarms played

## What the app never does

- It does not transmit any of the above, to us or to anyone else
- It does not use analytics, crash reporting or advertising SDKs
- It does not read your contacts, messages, photos, files, location or call history
- It does not identify you or your device
- It does not run in the background for any purpose other than watching the battery
  while you have monitoring switched on

## Permissions and why they exist

| Permission | Purpose |
|---|---|
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE` | Observe battery level and charging state continuously. Android requires a foreground service for this because the battery broadcast is only delivered to a running process. |
| `POST_NOTIFICATIONS` | Show the ongoing notification that Android requires for that service, and the alarm notification with its Stop button. |
| `VIBRATE` | Vibrate during the alarm, if you enable it. |
| `WAKE_LOCK` | Keep the alarm playing while the screen is off. Held only while an alarm is actually ringing. |
| `RECEIVE_BOOT_COMPLETED` | Optional. Resume monitoring after a restart, only if you turn that setting on. |
| `RECORD_AUDIO` | Optional. Requested only at the moment you choose to record a custom alarm clip. The recording is saved to the app's private folder and is never uploaded. |

The flashlight is controlled through `CameraManager.setTorchMode`, which requires no
camera permission — the app never opens a camera stream and has no access to images.

## Microphone

The microphone is used only while you are actively recording an alarm clip, and only
after you grant permission at that moment. Recording stops when you tap stop or after
30 seconds. Nothing is listened to, transcribed or transmitted.

## Text-to-speech

The spoken announcement uses the text-to-speech engine already installed on your
phone. The app passes it the sentence you wrote. If your device's TTS engine is
configured to use online voices, that is a setting of that engine, not of this app —
this app itself has no network access.

## Children

The app collects no personal data from anyone, of any age.

## Deleting your data

- **Charging history**: Settings → Data → *Clear history*, or swipe individual entries
  away on the History screen.
- **Custom sounds**: delete them from the Alarm sound screen.
- **Everything**: uninstall the app. Android removes its private storage entirely.
  Because nothing was ever uploaded — and because cloud backup is disabled — there is
  nothing elsewhere to delete.

## Changes to this policy

Any change will be published with a new date at the top of this document and included
in the app release that makes the change.

## Contact

Questions about this policy can be raised through the project's issue tracker.
