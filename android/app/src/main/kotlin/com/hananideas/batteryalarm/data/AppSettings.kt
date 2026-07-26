package com.hananideas.batteryalarm.data

import android.content.Context
import android.content.SharedPreferences
import com.hananideas.batteryalarm.core.PrefsKeys
import org.json.JSONObject
import java.util.Locale

/**
 * Every user-configurable value, mirrored from the Dart layer into native
 * `SharedPreferences` so the foreground service keeps working after the Flutter
 * engine is torn down (app swiped away, or started at boot with no UI at all).
 *
 * Dart owns the UI copy; this is the copy the service reads. `updateSettings` on the
 * method channel keeps them in sync on every change.
 */
data class AppSettings(
    val userName: String = "",
    val voiceMessage: String = DEFAULT_MESSAGE,
    val voiceEnabled: Boolean = true,
    val speechRate: Float = 1.0f,
    val speechPitch: Float = 1.0f,
    val language: String = "en",
    val alarmIntervalSeconds: Int = 10,
    val alarmVolumePercent: Int = 80,
    val soundEnabled: Boolean = true,
    val soundUri: String = "",
    val soundLabel: String = "",
    val vibrationEnabled: Boolean = true,
    val flashEnabled: Boolean = false,
    val notificationsEnabled: Boolean = true,
    val autoStartMonitoring: Boolean = true,
    val autoStartAfterBoot: Boolean = true,
    val themeMode: String = "system",
) {

    /** Clamped copy — protects the service from out-of-range values however they arrive. */
    fun sanitized(): AppSettings = copy(
        userName = userName.trim().take(40),
        voiceMessage = voiceMessage.trim().ifEmpty { DEFAULT_MESSAGE }.take(300),
        speechRate = speechRate.coerceIn(0.5f, 2.0f),
        speechPitch = speechPitch.coerceIn(0.5f, 2.0f),
        language = language.takeIf { it in SUPPORTED_LANGUAGES } ?: "en",
        alarmIntervalSeconds = ALLOWED_INTERVALS.minByOrNull {
            kotlin.math.abs(it - alarmIntervalSeconds)
        } ?: 10,
        alarmVolumePercent = alarmVolumePercent.coerceIn(10, 100),
        themeMode = themeMode.takeIf { it in setOf("system", "light", "dark") } ?: "system",
    )

    /** Region-qualified so engines that ship regional voices pick the right one. */
    fun ttsLocale(): Locale = when (language) {
        "ur" -> Locale.forLanguageTag("ur-PK")
        "ar" -> Locale.forLanguageTag("ar-SA")
        "hi" -> Locale.forLanguageTag("hi-IN")
        else -> Locale.ENGLISH
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "userName" to userName,
        "voiceMessage" to voiceMessage,
        "voiceEnabled" to voiceEnabled,
        "speechRate" to speechRate.toDouble(),
        "speechPitch" to speechPitch.toDouble(),
        "language" to language,
        "alarmIntervalSeconds" to alarmIntervalSeconds,
        "alarmVolumePercent" to alarmVolumePercent,
        "soundEnabled" to soundEnabled,
        "soundUri" to soundUri,
        "soundLabel" to soundLabel,
        "vibrationEnabled" to vibrationEnabled,
        "flashEnabled" to flashEnabled,
        "notificationsEnabled" to notificationsEnabled,
        "autoStartMonitoring" to autoStartMonitoring,
        "autoStartAfterBoot" to autoStartAfterBoot,
        "themeMode" to themeMode,
    )

    private fun toJson(): JSONObject = JSONObject(toMap())

    companion object {
        const val DEFAULT_MESSAGE = "{name}, your phone battery is fully charged. Please remove the charger."

        val ALLOWED_INTERVALS = listOf(5, 10, 15, 30, 60)
        val SUPPORTED_LANGUAGES = setOf("en", "ur", "ar", "hi")

        fun prefs(context: Context): SharedPreferences =
            context.applicationContext.getSharedPreferences(PrefsKeys.FILE, Context.MODE_PRIVATE)

        fun load(context: Context): AppSettings {
            val raw = prefs(context).getString(PrefsKeys.SETTINGS, null) ?: return AppSettings()
            return runCatching { fromJson(JSONObject(raw)) }.getOrDefault(AppSettings())
        }

        fun save(context: Context, settings: AppSettings) {
            prefs(context).edit()
                .putString(PrefsKeys.SETTINGS, settings.sanitized().toJson().toString())
                .apply()
        }

        fun isMonitoringEnabled(context: Context): Boolean =
            prefs(context).getBoolean(PrefsKeys.MONITORING_ENABLED, false)

        fun setMonitoringEnabled(context: Context, enabled: Boolean) {
            prefs(context).edit().putBoolean(PrefsKeys.MONITORING_ENABLED, enabled).apply()
        }

        fun fromMap(map: Map<*, *>): AppSettings {
            val defaults = AppSettings()
            fun str(key: String, fallback: String) = (map[key] as? String) ?: fallback
            fun bool(key: String, fallback: Boolean) = (map[key] as? Boolean) ?: fallback
            fun int(key: String, fallback: Int) = (map[key] as? Number)?.toInt() ?: fallback
            fun flt(key: String, fallback: Float) = (map[key] as? Number)?.toFloat() ?: fallback

            return AppSettings(
                userName = str("userName", defaults.userName),
                voiceMessage = str("voiceMessage", defaults.voiceMessage),
                voiceEnabled = bool("voiceEnabled", defaults.voiceEnabled),
                speechRate = flt("speechRate", defaults.speechRate),
                speechPitch = flt("speechPitch", defaults.speechPitch),
                language = str("language", defaults.language),
                alarmIntervalSeconds = int("alarmIntervalSeconds", defaults.alarmIntervalSeconds),
                alarmVolumePercent = int("alarmVolumePercent", defaults.alarmVolumePercent),
                soundEnabled = bool("soundEnabled", defaults.soundEnabled),
                soundUri = str("soundUri", defaults.soundUri),
                soundLabel = str("soundLabel", defaults.soundLabel),
                vibrationEnabled = bool("vibrationEnabled", defaults.vibrationEnabled),
                flashEnabled = bool("flashEnabled", defaults.flashEnabled),
                notificationsEnabled = bool("notificationsEnabled", defaults.notificationsEnabled),
                autoStartMonitoring = bool("autoStartMonitoring", defaults.autoStartMonitoring),
                autoStartAfterBoot = bool("autoStartAfterBoot", defaults.autoStartAfterBoot),
                themeMode = str("themeMode", defaults.themeMode),
            ).sanitized()
        }

        private fun fromJson(json: JSONObject): AppSettings {
            val map = mutableMapOf<String, Any?>()
            json.keys().forEach { key -> map[key] = json.opt(key) }
            return fromMap(map)
        }
    }
}
