package com.hananideas.batteryalarm

import com.hananideas.batteryalarm.data.AppSettings
import org.junit.Assert.assertEquals
import org.junit.Test
import java.util.Locale

/**
 * Settings that reach the service from the method channel are untrusted input:
 * [AppSettings.sanitized] is the guard that keeps a bad value from turning into a
 * silent alarm or a 0-second repeat loop.
 */
class AppSettingsTest {

    @Test
    fun `defaults match the documented values`() {
        val defaults = AppSettings()

        assertEquals(10, defaults.alarmIntervalSeconds)
        assertEquals(80, defaults.alarmVolumePercent)
        assertEquals("en", defaults.language)
        assertEquals(1.0f, defaults.speechRate, 0.001f)
        assertEquals(1.0f, defaults.speechPitch, 0.001f)
    }

    @Test
    fun `an unsupported interval snaps to the nearest allowed value`() {
        assertEquals(15, AppSettings(alarmIntervalSeconds = 17).sanitized().alarmIntervalSeconds)
        assertEquals(5, AppSettings(alarmIntervalSeconds = 1).sanitized().alarmIntervalSeconds)
        assertEquals(60, AppSettings(alarmIntervalSeconds = 900).sanitized().alarmIntervalSeconds)
    }

    @Test
    fun `volume is clamped into an audible range`() {
        assertEquals(10, AppSettings(alarmVolumePercent = -20).sanitized().alarmVolumePercent)
        assertEquals(100, AppSettings(alarmVolumePercent = 400).sanitized().alarmVolumePercent)
    }

    @Test
    fun `speech rate and pitch are clamped`() {
        val sanitized = AppSettings(speechRate = 9f, speechPitch = 0.01f).sanitized()

        assertEquals(2.0f, sanitized.speechRate, 0.001f)
        assertEquals(0.5f, sanitized.speechPitch, 0.001f)
    }

    @Test
    fun `an empty announcement falls back to the default message`() {
        assertEquals(
            AppSettings.DEFAULT_MESSAGE,
            AppSettings(voiceMessage = "   ").sanitized().voiceMessage,
        )
    }

    @Test
    fun `an unknown language falls back to English`() {
        assertEquals("en", AppSettings(language = "kl").sanitized().language)
    }

    @Test
    fun `each supported language maps to a text-to-speech locale`() {
        assertEquals(Locale.ENGLISH, AppSettings(language = "en").ttsLocale())
        assertEquals("ur", AppSettings(language = "ur").ttsLocale().language)
        assertEquals("ar", AppSettings(language = "ar").ttsLocale().language)
        assertEquals("hi", AppSettings(language = "hi").ttsLocale().language)
    }

    @Test
    fun `a map from the method channel round-trips through the model`() {
        val original = AppSettings(
            userName = "Muhammad",
            voiceMessage = "{name}, unplug it.",
            alarmIntervalSeconds = 30,
            alarmVolumePercent = 65,
            flashEnabled = true,
            language = "ur",
        )

        assertEquals(original, AppSettings.fromMap(original.toMap()))
    }

    @Test
    fun `missing keys in an incoming map fall back to defaults`() {
        val parsed = AppSettings.fromMap(mapOf("userName" to "Ali"))

        assertEquals("Ali", parsed.userName)
        assertEquals(AppSettings().alarmIntervalSeconds, parsed.alarmIntervalSeconds)
        assertEquals(AppSettings().voiceMessage, parsed.voiceMessage)
    }

    @Test
    fun `an overlong name is truncated rather than rejected`() {
        val parsed = AppSettings(userName = "x".repeat(200)).sanitized()

        assertEquals(40, parsed.userName.length)
    }
}
