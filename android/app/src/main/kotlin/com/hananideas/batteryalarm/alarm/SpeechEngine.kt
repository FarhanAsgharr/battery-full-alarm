package com.hananideas.batteryalarm.alarm

import android.content.Context
import android.media.AudioAttributes
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

/**
 * Thin wrapper over Android's built-in [TextToSpeech] engine.
 *
 * Speech is routed through the alarm stream so it is audible even in silent mode and
 * follows the alarm volume the user chose. Initialisation is asynchronous, so a request
 * that arrives before the engine is ready is queued rather than dropped.
 */
class SpeechEngine(context: Context) {

    private val main = Handler(Looper.getMainLooper())
    private val callbacks = ConcurrentHashMap<String, () -> Unit>()
    private val utteranceCounter = AtomicLong()

    @Volatile private var ready = false
    @Volatile private var pending: (() -> Unit)? = null

    /** False when the selected language has no voice data installed and English was used instead. */
    @Volatile var lastLanguageSupported = true
        private set

    private var engine: TextToSpeech? = null

    init {
        engine = TextToSpeech(context.applicationContext) { status ->
            ready = status == TextToSpeech.SUCCESS
            if (ready) {
                engine?.setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build(),
                )
                engine?.setOnUtteranceProgressListener(listener)
            }
            val queued = pending
            pending = null
            queued?.let { main.post(it) }
        }
    }

    val isReady: Boolean get() = ready

    fun isLanguageAvailable(locale: Locale): Boolean {
        val result = engine?.isLanguageAvailable(locale) ?: return false
        return result >= TextToSpeech.LANG_AVAILABLE
    }

    /**
     * Speaks [text], invoking [onDone] when playback finishes, fails, or the engine is
     * unavailable — the caller can always rely on being called back exactly once.
     */
    fun speak(
        text: String,
        locale: Locale,
        rate: Float,
        pitch: Float,
        onDone: () -> Unit,
    ) {
        if (text.isBlank()) {
            onDone()
            return
        }
        if (!ready) {
            // Engine still starting up: run this once initialisation completes.
            pending = { speak(text, locale, rate, pitch, onDone) }
            return
        }
        val tts = engine
        if (tts == null) {
            onDone()
            return
        }

        val applied = tts.setLanguage(locale)
        lastLanguageSupported = applied != TextToSpeech.LANG_MISSING_DATA &&
            applied != TextToSpeech.LANG_NOT_SUPPORTED
        if (!lastLanguageSupported) tts.setLanguage(Locale.ENGLISH)

        tts.setSpeechRate(rate.coerceIn(0.5f, 2.0f))
        tts.setPitch(pitch.coerceIn(0.5f, 2.0f))

        val id = "utt-${utteranceCounter.incrementAndGet()}"
        callbacks[id] = onDone

        val params = Bundle().apply {
            putInt(TextToSpeech.Engine.KEY_PARAM_STREAM, android.media.AudioManager.STREAM_ALARM)
            putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, 1.0f)
        }
        val result = tts.speak(text, TextToSpeech.QUEUE_FLUSH, params, id)
        if (result != TextToSpeech.SUCCESS) finish(id)
    }

    /**
     * Cancels speech and drops outstanding continuations — a stop means the whole alarm
     * is being torn down, so nothing should be scheduled off the back of it.
     */
    fun stop() {
        pending = null
        callbacks.clear()
        runCatching { engine?.stop() }
    }

    fun shutdown() {
        pending = null
        callbacks.clear()
        runCatching { engine?.stop() }
        runCatching { engine?.shutdown() }
        engine = null
        ready = false
    }

    private fun finish(id: String) {
        val callback = callbacks.remove(id) ?: return
        main.post(callback)
    }

    private val listener = object : UtteranceProgressListener() {
        override fun onStart(utteranceId: String?) = Unit

        override fun onDone(utteranceId: String?) {
            utteranceId?.let(::finish)
        }

        @Deprecated("Required by the base class; the int-code overload below is used on API 21+.")
        override fun onError(utteranceId: String?) {
            utteranceId?.let(::finish)
        }

        override fun onError(utteranceId: String?, errorCode: Int) {
            utteranceId?.let(::finish)
        }

        override fun onStop(utteranceId: String?, interrupted: Boolean) {
            utteranceId?.let { callbacks.remove(it) }
        }
    }
}
