package com.hananideas.batteryalarm.core

/** What the service should do next, given a battery reading. */
enum class MonitorAction { NONE, START_ALARM, STOP_ALARM }

/**
 * The part of the service's state the alarm decision depends on.
 *
 * [dismissedForSession] is set when the user silences the alarm from the notification.
 * It suppresses further alarms until the charger is unplugged, so "stop" means stop
 * rather than "stop for one interval".
 */
data class MonitorState(
    val alarming: Boolean = false,
    val dismissedForSession: Boolean = false,
)

/**
 * The whole "should the alarm be ringing right now?" rule set, as pure functions.
 *
 * Everything here is deliberately free of Android types so it can be exercised by
 * JVM unit tests (see `BatterySimulationTest`) instead of only on a device.
 */
object MonitorPolicy {

    fun decide(
        snapshot: BatterySnapshot,
        state: MonitorState,
        monitoringEnabled: Boolean,
    ): MonitorAction {
        // Unplugged, or monitoring switched off: silence immediately, never start.
        if (!monitoringEnabled || !snapshot.isPluggedIn) {
            return if (state.alarming) MonitorAction.STOP_ALARM else MonitorAction.NONE
        }
        if (snapshot.isFull) {
            val blocked = state.alarming || state.dismissedForSession
            return if (blocked) MonitorAction.NONE else MonitorAction.START_ALARM
        }
        // Still plugged in but the level dropped back under 100% (e.g. a heavy app
        // drained it while charging) — stop and stay armed for the next time it fills.
        return if (state.alarming) MonitorAction.STOP_ALARM else MonitorAction.NONE
    }

    /**
     * Unplugging ends a charging session: clear the "user dismissed it" latch so the
     * next session alarms normally.
     */
    fun nextState(
        previous: MonitorState,
        action: MonitorAction,
        snapshot: BatterySnapshot,
    ): MonitorState {
        val alarming = when (action) {
            MonitorAction.START_ALARM -> true
            MonitorAction.STOP_ALARM -> false
            MonitorAction.NONE -> previous.alarming
        }
        val dismissed = if (!snapshot.isPluggedIn) false else previous.dismissedForSession
        return MonitorState(alarming = alarming, dismissedForSession = dismissed)
    }
}
