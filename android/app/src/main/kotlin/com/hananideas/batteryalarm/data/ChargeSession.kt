package com.hananideas.batteryalarm.data

import org.json.JSONObject

/**
 * One charging session: charger in → charger out.
 *
 * Recorded natively rather than in Dart because the Flutter engine is usually not
 * running while the phone charges overnight.
 */
data class ChargeSession(
    val id: Long,
    val startedAt: Long,
    val endedAt: Long = 0L,
    val startLevel: Int = 0,
    val endLevel: Int = 0,
    val peakLevel: Int = 0,
    /** Epoch millis at which the battery first hit 100%, or 0 if it never did. */
    val fullAt: Long = 0L,
    val alarmCount: Int = 0,
    val plugType: String = "unknown",
    /**
     * When this row was last written. Used to close a session honestly if the process
     * is killed while charging — `onDestroy` does not run on a process kill, so the
     * next service instance ends it here rather than leaving it "in progress" forever.
     */
    val lastSeenAt: Long = 0L,
) {
    val isActive: Boolean get() = endedAt <= 0L

    /**
     * Closes a session left open by a killed process, at the last moment it was known
     * to be charging. Never invents a time later than that.
     */
    fun closedFromLastSeen(): ChargeSession =
        if (!isActive) this else copy(endedAt = maxOf(lastSeenAt, startedAt))

    fun toJson(): JSONObject = JSONObject().apply {
        put("id", id)
        put("startedAt", startedAt)
        put("endedAt", endedAt)
        put("lastSeenAt", lastSeenAt)
        put("startLevel", startLevel)
        put("endLevel", endLevel)
        put("peakLevel", peakLevel)
        put("fullAt", fullAt)
        put("alarmCount", alarmCount)
        put("plugType", plugType)
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "startedAt" to startedAt,
        "endedAt" to endedAt,
        "startLevel" to startLevel,
        "endLevel" to endLevel,
        "peakLevel" to peakLevel,
        "fullAt" to fullAt,
        "alarmCount" to alarmCount,
        "plugType" to plugType,
        // lastSeenAt is deliberately absent: it is a persistence detail the UI never
        // reads, and including it would make every live payload differ from the last
        // one, defeating the service's "publish only on real change" check.
    )

    companion object {
        fun fromJson(json: JSONObject): ChargeSession = ChargeSession(
            id = json.optLong("id"),
            startedAt = json.optLong("startedAt"),
            endedAt = json.optLong("endedAt"),
            startLevel = json.optInt("startLevel"),
            endLevel = json.optInt("endLevel"),
            peakLevel = json.optInt("peakLevel"),
            fullAt = json.optLong("fullAt"),
            alarmCount = json.optInt("alarmCount"),
            plugType = json.optString("plugType", "unknown"),
            lastSeenAt = json.optLong("lastSeenAt"),
        )
    }
}
