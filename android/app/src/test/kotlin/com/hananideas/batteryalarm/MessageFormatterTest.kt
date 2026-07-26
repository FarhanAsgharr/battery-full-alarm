package com.hananideas.batteryalarm

import com.hananideas.batteryalarm.core.MessageFormatter
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * The spoken announcement.
 *
 * These cases are mirrored one-for-one in `test/features/voice/message_template_test.dart`
 * so the in-app preview can never disagree with what the service actually says.
 */
class MessageFormatterTest {

    @Test
    fun `substitutes the user name`() {
        assertEquals(
            "Muhammad, your phone is charged.",
            MessageFormatter.format("{name}, your phone is charged.", "Muhammad", 100),
        )
    }

    @Test
    fun `drops the name placeholder and its comma when no name is set`() {
        assertEquals(
            "Your phone is charged.",
            MessageFormatter.format("{name}, your phone is charged.", "", 100),
        )
    }

    @Test
    fun `substitutes the battery level`() {
        assertEquals(
            "Battery is at 100 percent.",
            MessageFormatter.format("Battery is at {level} percent.", "", 100),
        )
    }

    @Test
    fun `handles both placeholders together`() {
        assertEquals(
            "Ali, the battery is at 100 percent.",
            MessageFormatter.format("{name}, the battery is at {level} percent.", "Ali", 100),
        )
    }

    @Test
    fun `trims surrounding whitespace and collapses runs of spaces`() {
        assertEquals(
            "Charging is complete.",
            MessageFormatter.format("   Charging   is complete.  ", "", 100),
        )
    }

    @Test
    fun `trims the supplied name`() {
        assertEquals(
            "Sara, unplug the charger.",
            MessageFormatter.format("{name}, unplug the charger.", "  Sara  ", 100),
        )
    }

    @Test
    fun `capitalises the first letter after the placeholder is removed`() {
        assertEquals(
            "Unplug the charger now.",
            MessageFormatter.format("{name} unplug the charger now.", "", 100),
        )
    }

    @Test
    fun `leaves a message with no placeholders untouched`() {
        assertEquals(
            "Battery is fully charged. Please unplug your phone.",
            MessageFormatter.format(
                "Battery is fully charged. Please unplug your phone.",
                "Muhammad",
                100,
            ),
        )
    }

    @Test
    fun `removes an Arabic comma after the name placeholder`() {
        assertEquals(
            "افصل الشاحن.",
            MessageFormatter.format("{name}، افصل الشاحن.", "", 100),
        )
    }

    @Test
    fun `keeps a name that appears more than once`() {
        assertEquals(
            "Zara, Zara, the battery is full.",
            MessageFormatter.format("{name}, {name}, the battery is full.", "Zara", 100),
        )
    }
}
