package com.hananideas.batteryalarm

import com.hananideas.batteryalarm.data.ChargeSession
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ChargeSessionTest {

    private val start = 1_700_000_000_000L

    @Test
    fun `a session with no end time is active`() {
        assertTrue(ChargeSession(id = start, startedAt = start).isActive)
        assertFalse(ChargeSession(id = start, startedAt = start, endedAt = start + 1).isActive)
    }

    @Test
    fun `a dangling session closes at the moment it was last seen charging`() {
        val dangling = ChargeSession(
            id = start,
            startedAt = start,
            lastSeenAt = start + 3_600_000,
        )

        val closed = dangling.closedFromLastSeen()

        assertFalse(closed.isActive)
        assertEquals(start + 3_600_000, closed.endedAt)
    }

    @Test
    fun `closing never produces an end time before the start`() {
        // lastSeenAt can be 0 for a row written by an older version of the app.
        val dangling = ChargeSession(id = start, startedAt = start, lastSeenAt = 0L)

        assertEquals(start, dangling.closedFromLastSeen().endedAt)
    }

    @Test
    fun `closing an already finished session changes nothing`() {
        val finished = ChargeSession(
            id = start,
            startedAt = start,
            endedAt = start + 100,
            lastSeenAt = start + 90,
        )

        assertEquals(finished, finished.closedFromLastSeen())
    }

    @Test
    fun `a session round-trips through JSON`() {
        val session = ChargeSession(
            id = start,
            startedAt = start,
            endedAt = start + 7_200_000,
            startLevel = 34,
            endLevel = 100,
            peakLevel = 100,
            fullAt = start + 5_400_000,
            alarmCount = 6,
            plugType = "usb",
            lastSeenAt = start + 7_100_000,
        )

        assertEquals(session, ChargeSession.fromJson(session.toJson()))
    }

    @Test
    fun `the map sent to Dart carries every field the UI reads`() {
        val keys = ChargeSession(id = 1, startedAt = start).toMap().keys

        assertTrue(
            keys.containsAll(
                listOf(
                    "id",
                    "startedAt",
                    "endedAt",
                    "startLevel",
                    "endLevel",
                    "peakLevel",
                    "fullAt",
                    "alarmCount",
                    "plugType",
                ),
            ),
        )
    }
}
