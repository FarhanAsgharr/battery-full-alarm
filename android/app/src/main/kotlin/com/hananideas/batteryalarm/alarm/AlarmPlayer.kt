package com.hananideas.batteryalarm.alarm

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import com.hananideas.batteryalarm.core.MessageFormatter
import com.hananideas.batteryalarm.data.AppSettings
import com.hananideas.batteryalarm.data.SoundLibrary

/**
 * Drives one alarm session: alarm tone → spoken announcement → wait the user's
 * interval → repeat, until [stop] is called.
 *
 * Repetition is driven by a main-looper [Handler] inside the already-running foreground
 * service rather than by `AlarmManager`. That keeps the timing exact for the 5–60s
 * intervals this app uses, avoids the `SCHEDULE_EXACT_ALARM` permission entirely, and
 * costs nothing while idle because the service is alive anyway.
 */
class AlarmPlayer(private val context: Context) {

    fun interface CycleListener {
        /** Called at the start of every burst with the 1-based repetition count. */
        fun onCycle(count: Int)
    }

    private val handler = Handler(Looper.getMainLooper())
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
    private val torch = TorchController(context)
    private val vibration = VibrationController(context)
    private val speech = SpeechEngine(context)

    private var player: MediaPlayer? = null
    private var previewPlayer: MediaPlayer? = null
    private var focusRequest: AudioFocusRequest? = null
    private var wakeLock: PowerManager.WakeLock? = null

    private var settings = AppSettings()
    private var batteryLevel = 100
    private var listener: CycleListener? = null
    private var maxCycles: Int? = null
    private var onFinished: (() -> Unit)? = null
    private var cycleCount = 0
    private var savedAlarmVolume = -1
    private val previewGuard = Runnable { stopPreview() }

    // Watchdogs for the current burst, replaced on each cycle.
    private var toneGuard = Runnable { }
    private var speechGuard = Runnable { }

    /** Bumped on every start/stop so callbacks from a cancelled burst are ignored. */
    private var generation = 0

    @Volatile
    var isRunning = false
        private set

    val torchAvailable: Boolean get() = torch.isAvailable
    val vibrationAvailable: Boolean get() = vibration.isAvailable

    // ---------------------------------------------------------------- lifecycle

    /**
     * @param maxCycles stop automatically after this many bursts; null repeats forever
     *   (the real alarm), 1 is used by the in-app "test alarm" button.
     * @param onFinished invoked once [maxCycles] bursts have played; never called for
     *   an unbounded alarm, which only ends via [stop].
     */
    fun start(
        settings: AppSettings,
        batteryLevel: Int,
        listener: CycleListener?,
        maxCycles: Int? = null,
        onFinished: (() -> Unit)? = null,
    ) {
        if (isRunning) return
        this.settings = settings
        this.batteryLevel = batteryLevel
        this.listener = listener
        this.maxCycles = maxCycles
        this.onFinished = onFinished
        isRunning = true
        cycleCount = 0
        generation++

        stopPreview()
        acquireWakeLock()
        applyAlarmVolume(settings.alarmVolumePercent)
        requestAudioFocus()
        runBurst(generation)
    }

    /** Applies edited settings to an alarm that is already ringing. */
    fun updateSettings(settings: AppSettings) {
        this.settings = settings
        if (isRunning) applyAlarmVolume(settings.alarmVolumePercent)
    }

    fun stop() {
        if (!isRunning) {
            releaseTransientResources()
            return
        }
        isRunning = false
        generation++
        handler.removeCallbacksAndMessages(null)
        releaseTransientResources()
        listener = null
        maxCycles = null
        onFinished = null
        cycleCount = 0
    }

    fun release() {
        stop()
        stopPreview()
        speech.shutdown()
    }

    // ------------------------------------------------------------------- cycle

    private fun runBurst(token: Int) {
        if (!isRunning || token != generation) return
        cycleCount++
        listener?.onCycle(cycleCount)

        // Refreshed every burst. A partial wake lock is what keeps `postDelayed`
        // firing on time — without it the CPU can sleep between bursts and Doze
        // stretches a 10-second interval into minutes. Each acquire carries its own
        // one-hour cap, so refreshing cannot turn into a leak.
        acquireWakeLock()

        if (settings.vibrationEnabled) vibration.start()
        if (settings.flashEnabled) torch.start()

        // With sound and speech both switched off the burst would otherwise start and
        // end in the same frame, so vibration and the torch would never be perceived.
        if (!settings.soundEnabled && !settings.voiceEnabled) {
            handler.postDelayed({ endBurst(token) }, SILENT_BURST_MS)
            return
        }

        playAlarmTone(token) {
            announce(token) {
                endBurst(token)
            }
        }
    }

    private fun endBurst(token: Int) {
        if (!isRunning || token != generation) return
        vibration.stop()
        torch.stop()
        val limit = maxCycles
        if (limit != null && cycleCount >= limit) {
            val finished = onFinished
            stop()
            finished?.invoke()
            return
        }
        val delay = settings.alarmIntervalSeconds.coerceIn(1, 600) * 1000L
        handler.postDelayed({ runBurst(token) }, delay)
    }

    private fun playAlarmTone(token: Int, onFinished: () -> Unit) {
        if (!settings.soundEnabled) {
            onFinished()
            return
        }
        playTone(token, resolveSoundUri(), allowFallback = true, onFinished = onFinished)
    }

    /**
     * @param allowFallback retry once with the device's default alarm tone if this URI
     *   cannot be played. A chosen sound can disappear — the user deletes the source
     *   file, or clears app storage — and an alarm that silently plays nothing is the
     *   one failure this app must not have.
     */
    private fun playTone(
        token: Int,
        uri: Uri?,
        allowFallback: Boolean,
        onFinished: () -> Unit,
    ) {
        if (uri == null) {
            onFinished()
            return
        }

        releasePlayer()

        // Guarantees the cycle continues even if the tone never completes: a very long
        // file, a stalled prepare, or a codec the device cannot decode.
        var done = false
        val fallback = SoundLibrary.defaultAlarmUri()

        fun finish(playedSomething: Boolean) {
            if (done) return
            done = true
            handler.removeCallbacks(toneGuard)
            releasePlayer()
            if (token != generation) return
            if (!playedSomething && allowFallback && fallback != null && fallback != uri) {
                Log.w(TAG, "Falling back to the default alarm tone")
                playTone(token, fallback, allowFallback = false, onFinished = onFinished)
            } else {
                onFinished()
            }
        }
        toneGuard = Runnable { finish(playedSomething = true) }

        val created = runCatching {
            MediaPlayer().apply {
                setAudioAttributes(alarmAudioAttributes)
                setDataSource(context, uri)
                isLooping = false
                setOnPreparedListener { it.start() }
                setOnCompletionListener { finish(playedSomething = true) }
                setOnErrorListener { _, what, extra ->
                    Log.w(TAG, "MediaPlayer error what=$what extra=$extra")
                    finish(playedSomething = false)
                    true
                }
                // Asynchronous: prepare() would block the service's main looper while
                // it reads the file header, and this runs on every alarm burst.
                prepareAsync()
            }
        }.getOrElse {
            Log.w(TAG, "Unable to play alarm tone $uri", it)
            null
        }

        if (created == null) {
            finish(playedSomething = false)
            return
        }
        player = created
        handler.postDelayed(toneGuard, MAX_TONE_MS)
    }

    private fun announce(token: Int, onFinished: () -> Unit) {
        if (!settings.voiceEnabled) {
            onFinished()
            return
        }
        val text = MessageFormatter.format(settings.voiceMessage, settings.userName, batteryLevel)

        // The same guarantee as the tone. It matters more here: a device with no
        // text-to-speech engine installed never calls back at all, which would leave
        // the alarm sounding once and never repeating.
        var done = false
        fun finishOnce() {
            if (done) return
            done = true
            handler.removeCallbacks(speechGuard)
            if (token == generation) onFinished()
        }
        speechGuard = Runnable { finishOnce() }

        speech.speak(text, settings.ttsLocale(), settings.speechRate, settings.speechPitch) {
            finishOnce()
        }
        handler.postDelayed(speechGuard, MAX_SPEECH_MS)
    }

    // ----------------------------------------------------------------- preview

    /** Plays a sound once, for the sound picker. Independent of the alarm cycle. */
    fun previewSound(uriString: String?, volumePercent: Int) {
        stopPreview()
        val uri = resolveSoundUri(uriString) ?: return
        applyAlarmVolume(volumePercent)
        previewPlayer = runCatching {
            MediaPlayer().apply {
                setAudioAttributes(alarmAudioAttributes)
                setDataSource(context, uri)
                setOnPreparedListener { it.start() }
                setOnCompletionListener { stopPreview() }
                setOnErrorListener { _, _, _ -> stopPreview(); true }
                prepareAsync()
            }
        }.getOrNull()
        handler.postDelayed(previewGuard, MAX_PREVIEW_MS)
    }

    /** Speaks the announcement once, for the voice settings screen. */
    fun previewVoice(settings: AppSettings, batteryLevel: Int) {
        applyAlarmVolume(settings.alarmVolumePercent)
        val text = MessageFormatter.format(settings.voiceMessage, settings.userName, batteryLevel)
        speech.speak(text, settings.ttsLocale(), settings.speechRate, settings.speechPitch) {
            if (!isRunning) restoreAlarmVolume()
        }
    }

    fun stopPreview() {
        handler.removeCallbacks(previewGuard)
        previewPlayer?.let { existing ->
            runCatching { if (existing.isPlaying) existing.stop() }
            runCatching { existing.release() }
        }
        previewPlayer = null
        if (!isRunning) {
            speech.stop()
            restoreAlarmVolume()
        }
    }

    fun isTtsLanguageAvailable(settings: AppSettings): Boolean =
        speech.isLanguageAvailable(settings.ttsLocale())

    val isTtsReady: Boolean get() = speech.isReady

    // ---------------------------------------------------------------- plumbing

    private fun resolveSoundUri(override: String? = null): Uri? {
        val raw = override ?: settings.soundUri
        if (raw.isNotBlank()) {
            val parsed = runCatching { Uri.parse(raw) }.getOrNull()
            if (parsed != null) return parsed
        }
        return SoundLibrary.defaultAlarmUri()
    }

    private fun releasePlayer() {
        player?.let { existing ->
            runCatching { if (existing.isPlaying) existing.stop() }
            runCatching { existing.release() }
        }
        player = null
    }

    private fun releaseTransientResources() {
        handler.removeCallbacksAndMessages(null)
        releasePlayer()
        speech.stop()
        vibration.stop()
        torch.stop()
        abandonAudioFocus()
        restoreAlarmVolume()
        releaseWakeLock()
    }

    private fun applyAlarmVolume(percent: Int) {
        runCatching {
            val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            if (savedAlarmVolume < 0) {
                savedAlarmVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
                // Written to disk before the change, not after: if the process is killed
                // while the alarm is ringing, nothing in this object survives to put the
                // user's volume back. The next launch reads this and restores it.
                VolumeGuard.remember(context, savedAlarmVolume)
            }
            val target = ((percent.coerceIn(10, 100) / 100f) * max).toInt().coerceIn(1, max)
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, target, 0)
        }.onFailure { Log.w(TAG, "Could not set alarm volume", it) }
    }

    private fun restoreAlarmVolume() {
        if (savedAlarmVolume < 0) return
        runCatching { audioManager.setStreamVolume(AudioManager.STREAM_ALARM, savedAlarmVolume, 0) }
        savedAlarmVolume = -1
        VolumeGuard.clear(context)
    }

    private fun requestAudioFocus() {
        val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            .setAudioAttributes(alarmAudioAttributes)
            .setOnAudioFocusChangeListener { }
            .build()
        focusRequest = request
        runCatching { audioManager.requestAudioFocus(request) }
    }

    private fun abandonAudioFocus() {
        focusRequest?.let { request -> runCatching { audioManager.abandonAudioFocusRequest(request) } }
        focusRequest = null
    }

    /**
     * Acquires — or re-arms — the alarm wake lock. The lock is not reference counted,
     * so calling `acquire` again simply restarts its timeout.
     */
    private fun acquireWakeLock() {
        val lock = wakeLock ?: powerManager
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_LOCK_TAG)
            .apply { setReferenceCounted(false) }
            .also { wakeLock = it }
        runCatching { lock.acquire(WAKE_LOCK_TIMEOUT_MS) }
    }

    private fun releaseWakeLock() {
        wakeLock?.let { lock -> if (lock.isHeld) runCatching { lock.release() } }
        wakeLock = null
    }

    private val alarmAudioAttributes: AudioAttributes
        get() = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

    private companion object {
        const val TAG = "AlarmPlayer"

        // These are stall protection, not trimming. A tone or utterance that finishes
        // normally ends its step immediately via its own callback; these only fire when
        // something never calls back at all. They are therefore set above the longest
        // legitimate case — a 30-second recorded clip, and a 300-character message read
        // at the slowest speech rate — so a guard can never cut a user off mid-sentence.
        const val MAX_TONE_MS = 30_000L
        const val MAX_SPEECH_MS = 45_000L
        const val MAX_PREVIEW_MS = 30_000L

        /** How long a vibration/torch-only burst lasts when no audio will play. */
        const val SILENT_BURST_MS = 3_000L
        const val WAKE_LOCK_TAG = "BatteryFullAlarm::AlarmWakeLock"
        const val WAKE_LOCK_TIMEOUT_MS = 60 * 60 * 1000L
    }
}
