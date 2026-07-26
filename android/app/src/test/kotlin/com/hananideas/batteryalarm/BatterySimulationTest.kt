package com.hananideas.batteryalarm

import android.os.BatteryManager
import com.hananideas.batteryalarm.core.BatterySnapshot
import com.hananideas.batteryalarm.core.MonitorAction
import com.hananideas.batteryalarm.core.MonitorPolicy
import com.hananideas.batteryalarm.core.MonitorState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Simulated charging sessions driven through [MonitorPolicy].
 *
 * This is the alarm's decision logic end to end — plug in, charge up, hit 100%, unplug —
 * exercised on the JVM without a device, an emulator or a real battery.
 */
class BatterySimulationTest {

    private fun snapshot(
        level: Int,
        plugged: Int = BatteryManager.BATTERY_PLUGGED_AC,
        status: Int = BatteryManager.BATTERY_STATUS_CHARGING,
    ) = BatterySnapshot(level = level, status = status, plugged = plugged)

    private fun unplugged(level: Int) = snapshot(
        level = level,
        plugged = 0,
        status = BatteryManager.BATTERY_STATUS_DISCHARGING,
    )

    /** Runs a sequence of readings and returns every action the policy decided. */
    private fun run(
        readings: List<BatterySnapshot>,
        monitoringEnabled: Boolean = true,
        initial: MonitorState = MonitorState(),
    ): Pair<List<MonitorAction>, MonitorState> {
        var state = initial
        val actions = readings.map { reading ->
            val action = MonitorPolicy.decide(reading, state, monitoringEnabled)
            state = MonitorPolicy.nextState(state, action, reading)
            action
        }
        return actions to state
    }

    @Test
    fun `alarm fires exactly once when the battery reaches full while charging`() {
        val (actions, state) = run(listOf(snapshot(97), snapshot(99), snapshot(100), snapshot(100)))

        assertEquals(
            listOf(
                MonitorAction.NONE,
                MonitorAction.NONE,
                MonitorAction.START_ALARM,
                MonitorAction.NONE,
            ),
            actions,
        )
        assertTrue(state.alarming)
    }

    @Test
    fun `unplugging stops the alarm immediately`() {
        val (actions, state) = run(listOf(snapshot(100), unplugged(100)))

        assertEquals(listOf(MonitorAction.START_ALARM, MonitorAction.STOP_ALARM), actions)
        assertFalse(state.alarming)
    }

    @Test
    fun `a device reporting FULL rather than CHARGING still triggers the alarm`() {
        // Many OEMs switch the status to FULL the moment the level hits 100%.
        val reading = snapshot(100, status = BatteryManager.BATTERY_STATUS_FULL)
        val action = MonitorPolicy.decide(reading, MonitorState(), monitoringEnabled = true)

        assertEquals(MonitorAction.START_ALARM, action)
    }

    @Test
    fun `a device reporting NOT_CHARGING at full while still plugged in triggers the alarm`() {
        val reading = snapshot(100, status = BatteryManager.BATTERY_STATUS_NOT_CHARGING)
        val action = MonitorPolicy.decide(reading, MonitorState(), monitoringEnabled = true)

        assertEquals(MonitorAction.START_ALARM, action)
    }

    @Test
    fun `reaching 100 percent on battery never alarms`() {
        val (actions, _) = run(listOf(unplugged(100), unplugged(100)))

        assertEquals(listOf(MonitorAction.NONE, MonitorAction.NONE), actions)
    }

    @Test
    fun `monitoring switched off never alarms and silences a running alarm`() {
        val (actions, state) = run(
            readings = listOf(snapshot(100)),
            monitoringEnabled = false,
            initial = MonitorState(alarming = true),
        )

        assertEquals(listOf(MonitorAction.STOP_ALARM), actions)
        assertFalse(state.alarming)
    }

    @Test
    fun `dismissing the alarm keeps it silent for the rest of the session`() {
        var state = MonitorState(alarming = false, dismissedForSession = true)

        // Still plugged in and full: no re-trigger.
        repeat(5) {
            val action = MonitorPolicy.decide(snapshot(100), state, monitoringEnabled = true)
            assertEquals(MonitorAction.NONE, action)
            state = MonitorPolicy.nextState(state, action, snapshot(100))
        }

        // Unplugging clears the latch...
        state = MonitorPolicy.nextState(
            state,
            MonitorPolicy.decide(unplugged(100), state, true),
            unplugged(100),
        )
        assertFalse(state.dismissedForSession)

        // ...so the next charge alarms normally.
        assertEquals(
            MonitorAction.START_ALARM,
            MonitorPolicy.decide(snapshot(100), state, monitoringEnabled = true),
        )
    }

    @Test
    fun `dropping below full while plugged in stops the alarm and stays armed`() {
        val (actions, state) = run(listOf(snapshot(100), snapshot(99), snapshot(100)))

        assertEquals(
            listOf(MonitorAction.START_ALARM, MonitorAction.STOP_ALARM, MonitorAction.START_ALARM),
            actions,
        )
        assertTrue(state.alarming)
    }

    @Test
    fun `a full overnight session alarms once and stops on unplug`() {
        val overnight = buildList {
            addAll((40..99).map { snapshot(it) })
            addAll(List(20) { snapshot(100) })
            add(unplugged(100))
        }
        val (actions, state) = run(overnight)

        assertEquals(1, actions.count { it == MonitorAction.START_ALARM })
        assertEquals(1, actions.count { it == MonitorAction.STOP_ALARM })
        assertFalse(state.alarming)
    }

    @Test
    fun `wireless and usb chargers are treated the same as AC`() {
        for (plug in listOf(
            BatteryManager.BATTERY_PLUGGED_USB,
            BatteryManager.BATTERY_PLUGGED_WIRELESS,
        )) {
            val action = MonitorPolicy.decide(
                snapshot(100, plugged = plug),
                MonitorState(),
                monitoringEnabled = true,
            )
            assertEquals("plug type $plug", MonitorAction.START_ALARM, action)
        }
    }
}
