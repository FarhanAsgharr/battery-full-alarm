package com.hananideas.batteryalarm.media

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.os.Build
import android.util.Log
import com.hananideas.batteryalarm.data.SoundLibrary
import java.io.File

/**
 * Records a short voice clip with [MediaRecorder] straight into the app's private
 * sound folder. Nothing is uploaded — the file never leaves the device and is deleted
 * with the app.
 */
class VoiceRecorder(private val context: Context) {

    private var recorder: MediaRecorder? = null
    private var target: File? = null

    val isRecording: Boolean get() = recorder != null

    fun hasPermission(): Boolean =
        context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED

    /** @return true if recording actually started. */
    fun start(label: String): Boolean {
        if (isRecording || !hasPermission()) return false

        val file = SoundLibrary.newRecordingFile(context, label)
        val instance = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            MediaRecorder(context)
        } else {
            @Suppress("DEPRECATION")
            MediaRecorder()
        }

        return runCatching {
            instance.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setAudioEncodingBitRate(96_000)
                setAudioSamplingRate(44_100)
                setMaxDuration(MAX_DURATION_MS)
                setOutputFile(file.absolutePath)
                setOnInfoListener { _, what, _ ->
                    if (what == MediaRecorder.MEDIA_RECORDER_INFO_MAX_DURATION_REACHED) stop()
                }
                prepare()
                start()
            }
            recorder = instance
            target = file
            true
        }.getOrElse { error ->
            Log.w(TAG, "Recording failed to start", error)
            runCatching { instance.release() }
            file.delete()
            false
        }
    }

    /** Finalises the clip. @return its descriptor, or null if nothing usable was captured. */
    fun stop(): Map<String, Any?>? {
        val instance = recorder ?: return null
        val file = target
        recorder = null
        target = null

        runCatching { instance.stop() }.onFailure { Log.w(TAG, "Recorder stop failed", it) }
        runCatching { instance.release() }

        if (file == null || !file.exists() || file.length() < MIN_VALID_BYTES) {
            file?.delete()
            return null
        }
        return SoundLibrary.descriptorFor(file)
    }

    fun cancel() {
        val instance = recorder ?: return
        val file = target
        recorder = null
        target = null
        runCatching { instance.stop() }
        runCatching { instance.release() }
        file?.delete()
    }

    private companion object {
        const val TAG = "VoiceRecorder"
        const val MAX_DURATION_MS = 30_000
        const val MIN_VALID_BYTES = 1_024L
    }
}
