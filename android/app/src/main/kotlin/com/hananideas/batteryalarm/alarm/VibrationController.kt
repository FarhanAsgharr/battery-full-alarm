package com.hananideas.batteryalarm.alarm

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/** Repeating vibration pattern for the duration of one alarm burst. */
class VibrationController(context: Context) {

    private val vibrator: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)?.defaultVibrator
    } else {
        @Suppress("DEPRECATION")
        context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    }

    val isAvailable: Boolean get() = vibrator?.hasVibrator() == true

    fun start() {
        val device = vibrator?.takeIf { it.hasVibrator() } ?: return
        device.vibrate(VibrationEffect.createWaveform(PATTERN, REPEAT_FROM_INDEX))
    }

    fun stop() {
        vibrator?.cancel()
    }

    private companion object {
        /** wait, buzz, pause, buzz — loops from index 0. */
        val PATTERN = longArrayOf(0L, 700L, 400L, 700L, 700L)
        const val REPEAT_FROM_INDEX = 0
    }
}
