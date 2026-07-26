package com.hananideas.batteryalarm.core

import android.os.Handler
import android.os.Looper

/**
 * A tiny in-process event bus between the foreground service and the Flutter
 * `EventChannel` in `MainActivity`.
 *
 * Both live in the same process, so a plain listener list is enough — no
 * `LocalBroadcastManager`, no serialisation, no extra dependency. Emissions are
 * marshalled to the main thread because platform channels must be touched there.
 */
object AppBus {

    private val main = Handler(Looper.getMainLooper())
    private val listeners = mutableListOf<(Map<String, Any?>) -> Unit>()

    /** The most recent payload, replayed to new subscribers so the UI never starts blank. */
    @Volatile
    var last: Map<String, Any?>? = null
        private set

    @Synchronized
    fun subscribe(listener: (Map<String, Any?>) -> Unit) {
        listeners += listener
        last?.let { snapshot -> main.post { listener(snapshot) } }
    }

    @Synchronized
    fun unsubscribe(listener: (Map<String, Any?>) -> Unit) {
        listeners -= listener
    }

    fun emit(payload: Map<String, Any?>) {
        last = payload
        val current = synchronized(this) { listeners.toList() }
        if (current.isEmpty()) return
        main.post { current.forEach { it(payload) } }
    }
}
