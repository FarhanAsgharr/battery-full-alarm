package com.hananideas.batteryalarm.data

import android.content.Context
import com.hananideas.batteryalarm.core.PrefsKeys
import org.json.JSONArray

/**
 * Append-only local log of charging sessions, newest first, capped at [MAX_ENTRIES].
 *
 * Stored as a JSON array in the app's private `SharedPreferences`. Nothing leaves the
 * device and the file is removed with the app.
 *
 * The parsed list is cached in memory. A single charge from 20% to 100% writes about
 * eighty times, and without the cache each of those would re-parse the entire log —
 * which, once a user has months of history, is tens of kilobytes of JSON per percent.
 * The service is the only writer and lives in the same process as the reader, so the
 * cache cannot go stale as long as every access goes through this object.
 */
object HistoryStore {

    const val MAX_ENTRIES = 500

    private var cache: List<ChargeSession>? = null

    @Synchronized
    fun all(context: Context): List<ChargeSession> {
        cache?.let { return it }
        val raw = AppSettings.prefs(context).getString(PrefsKeys.HISTORY, null)
        val parsed = if (raw == null) {
            emptyList()
        } else {
            runCatching {
                val array = JSONArray(raw)
                (0 until array.length()).mapNotNull { index ->
                    array.optJSONObject(index)?.let(ChargeSession::fromJson)
                }
            }.getOrDefault(emptyList())
        }
        cache = parsed
        return parsed
    }

    /** Inserts a new session or replaces the existing one with the same id. */
    @Synchronized
    fun upsert(context: Context, session: ChargeSession) {
        val merged = buildList {
            add(session)
            addAll(all(context).filter { it.id != session.id })
        }.sortedByDescending { it.startedAt }.take(MAX_ENTRIES)
        write(context, merged)
    }

    /**
     * Ends any session left open by a previous process.
     *
     * `Service.onDestroy` does not run when Android kills the process, so a charge that
     * was in progress at that moment would otherwise stay marked "in progress" for
     * ever. Called when a service instance starts, before it opens a session of its own.
     */
    @Synchronized
    fun closeDanglingSessions(context: Context) {
        val sessions = all(context)
        if (sessions.none { it.isActive }) return
        write(context, sessions.map { it.closedFromLastSeen() })
    }

    @Synchronized
    fun delete(context: Context, id: Long) {
        write(context, all(context).filter { it.id != id })
    }

    @Synchronized
    fun clear(context: Context) {
        cache = emptyList()
        AppSettings.prefs(context).edit().remove(PrefsKeys.HISTORY).apply()
    }

    /** Drops the cache. Only needed if the backing store is changed behind this object. */
    @Synchronized
    fun invalidate() {
        cache = null
    }

    private fun write(context: Context, sessions: List<ChargeSession>) {
        cache = sessions
        val array = JSONArray()
        sessions.forEach { array.put(it.toJson()) }
        AppSettings.prefs(context).edit().putString(PrefsKeys.HISTORY, array.toString()).apply()
    }
}
