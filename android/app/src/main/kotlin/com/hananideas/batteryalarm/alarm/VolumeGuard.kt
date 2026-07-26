package com.hananideas.batteryalarm.alarm

import android.content.Context
import android.media.AudioManager
import android.util.Log
import com.hananideas.batteryalarm.data.AppSettings

/**
 * Makes the app's temporary change to the system alarm volume survivable.
 *
 * [AlarmPlayer] raises `STREAM_ALARM` while an alarm is ringing and lowers it again
 * afterwards. If the process is killed in between — which Android does freely, and
 * some manufacturers do aggressively — the in-memory "original value" dies with it and
 * the user is left with their alarm volume silently pinned to whatever this app chose.
 *
 * The original is therefore written to disk *before* the change and restored by
 * [restoreIfPending] the next time any component of the app starts.
 */
object VolumeGuard {

    private const val KEY = "pending_alarm_volume"
    private const val TAG = "VolumeGuard"

    fun remember(context: Context, originalVolume: Int) {
        AppSettings.prefs(context).edit().putInt(KEY, originalVolume).apply()
    }

    fun clear(context: Context) {
        AppSettings.prefs(context).edit().remove(KEY).apply()
    }

    /**
     * Puts the user's alarm volume back if a previous run did not get the chance.
     * Safe to call on every start; a no-op when nothing is pending.
     */
    fun restoreIfPending(context: Context) {
        val prefs = AppSettings.prefs(context)
        val pending = prefs.getInt(KEY, -1)
        if (pending < 0) return

        val audio = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        runCatching {
            val max = audio?.getStreamMaxVolume(AudioManager.STREAM_ALARM) ?: return@runCatching
            audio.setStreamVolume(AudioManager.STREAM_ALARM, pending.coerceIn(0, max), 0)
            Log.i(TAG, "Restored alarm volume $pending left over from a killed process")
        }.onFailure { Log.w(TAG, "Could not restore the pending alarm volume", it) }

        prefs.edit().remove(KEY).apply()
    }
}
