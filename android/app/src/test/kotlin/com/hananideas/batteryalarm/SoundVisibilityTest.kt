package com.hananideas.batteryalarm

import com.hananideas.batteryalarm.data.SoundVisibility
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * The rule behind "delete" for device ringtones.
 *
 * Those sounds belong to the phone, not to this app — deleting one would take it away
 * from the clock app and every other alarm app — so removal means hiding, and hiding
 * has to survive a restart.
 */
class SoundVisibilityTest {

    private fun sound(uri: String, label: String = uri) =
        mapOf<String, Any?>("uri" to uri, "label" to label, "type" to "builtin")

    private val catalogue = listOf(
        sound("content://settings/system/alarm_alert", "Default alarm"),
        sound("content://media/internal/audio/media/12", "Oxygen"),
        sound("content://media/internal/audio/media/13", "Helium"),
    )

    @Test
    fun `nothing hidden leaves the catalogue untouched`() {
        assertEquals(catalogue, SoundVisibility.visible(catalogue, emptySet()))
    }

    @Test
    fun `a hidden uri is filtered out`() {
        val visible = SoundVisibility.visible(
            catalogue,
            setOf("content://media/internal/audio/media/12"),
        )

        assertEquals(2, visible.size)
        assertTrue(visible.none { it["label"] == "Oxygen" })
    }

    @Test
    fun `hiding every entry leaves an empty list rather than failing`() {
        val all = catalogue.mapNotNull { it["uri"] as? String }.toSet()

        assertTrue(SoundVisibility.visible(catalogue, all).isEmpty())
    }

    @Test
    fun `hiding a uri that is not in the catalogue changes nothing visible`() {
        val visible = SoundVisibility.visible(catalogue, setOf("content://gone"))

        assertEquals(catalogue.size, visible.size)
    }

    @Test
    fun `the hidden set round-trips through storage`() {
        val hidden = setOf("content://a", "content://b", "content://c")

        assertEquals(hidden, SoundVisibility.decode(SoundVisibility.encode(hidden)))
    }

    @Test
    fun `an empty set round-trips`() {
        assertTrue(SoundVisibility.decode(SoundVisibility.encode(emptySet())).isEmpty())
    }

    @Test
    fun `unreadable stored data is treated as nothing hidden`() {
        // A user with a corrupted preference must still see their sounds, not none.
        assertTrue(SoundVisibility.decode("{not json").isEmpty())
        assertTrue(SoundVisibility.decode("").isEmpty())
        assertTrue(SoundVisibility.decode(null).isEmpty())
    }

    @Test
    fun `hiding is idempotent`() {
        var hidden = SoundVisibility.hide(emptySet(), "content://a")
        hidden = SoundVisibility.hide(hidden, "content://a")

        assertEquals(setOf("content://a"), hidden)
    }

    @Test
    fun `a blank uri is never added to the hidden set`() {
        assertTrue(SoundVisibility.hide(emptySet(), "").isEmpty())
    }

    @Test
    fun `revealing removes exactly one entry`() {
        val hidden = setOf("content://a", "content://b")

        assertEquals(setOf("content://b"), SoundVisibility.reveal(hidden, "content://a"))
    }

    @Test
    fun `revealing something that was never hidden is harmless`() {
        val hidden = setOf("content://a")

        assertEquals(hidden, SoundVisibility.reveal(hidden, "content://zzz"))
    }

    @Test
    fun `restoring means an empty hidden set, which shows everything again`() {
        val hidden = catalogue.mapNotNull { it["uri"] as? String }.toSet()
        assertTrue(SoundVisibility.visible(catalogue, hidden).isEmpty())

        // What restoreAllHidden does: clear the set.
        assertEquals(catalogue, SoundVisibility.visible(catalogue, emptySet()))
    }
}
