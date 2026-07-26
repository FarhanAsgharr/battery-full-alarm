package com.hananideas.batteryalarm.core

/** Names shared between the Dart and Kotlin sides of the app. */
object Channels {
    const val METHOD = "com.hananideas.batteryalarm/methods"
    const val EVENTS = "com.hananideas.batteryalarm/events"
}

/** Intent actions handled by [com.hananideas.batteryalarm.service.BatteryMonitorService]. */
object ServiceActions {
    const val START = "com.hananideas.batteryalarm.action.START"
    const val STOP = "com.hananideas.batteryalarm.action.STOP"
    const val SETTINGS_CHANGED = "com.hananideas.batteryalarm.action.SETTINGS_CHANGED"
    const val STOP_ALARM = "com.hananideas.batteryalarm.action.STOP_ALARM"
    const val TEST_ALARM = "com.hananideas.batteryalarm.action.TEST_ALARM"
    const val PREVIEW_SOUND = "com.hananideas.batteryalarm.action.PREVIEW_SOUND"
    const val PREVIEW_VOICE = "com.hananideas.batteryalarm.action.PREVIEW_VOICE"
    const val STOP_PREVIEW = "com.hananideas.batteryalarm.action.STOP_PREVIEW"

    const val EXTRA_SOUND_URI = "sound_uri"
}

object Notifications {
    const val CHANNEL_MONITOR = "battery_monitor"
    const val CHANNEL_ALARM = "battery_alarm"
    const val ID_MONITOR = 1001
    const val ID_ALARM = 1002
}

object PrefsKeys {
    const val FILE = "battery_alarm_native_prefs"

    const val SETTINGS = "settings_json"
    const val HISTORY = "history_json"
    const val MONITORING_ENABLED = "monitoring_enabled"
}
