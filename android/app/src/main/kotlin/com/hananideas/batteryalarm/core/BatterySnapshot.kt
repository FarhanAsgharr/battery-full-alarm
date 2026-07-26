package com.hananideas.batteryalarm.core

import android.content.Intent
import android.os.BatteryManager

/**
 * An immutable reading of the battery, decoded from `ACTION_BATTERY_CHANGED`.
 *
 * Kept free of Android framework state so the monitoring rules in [MonitorPolicy]
 * can be unit-tested on the JVM.
 */
data class BatterySnapshot(
    val level: Int,
    val status: Int,
    val plugged: Int,
    val temperatureTenthsC: Int = 0,
    val voltageMilliVolts: Int = 0,
    val health: Int = BatteryManager.BATTERY_HEALTH_UNKNOWN,
    val technology: String = "",
) {
    /**
     * True while power is attached. `status` alone is unreliable: a device sitting at
     * 100% reports `BATTERY_STATUS_FULL` rather than `CHARGING`, and a few OEM ROMs
     * report `NOT_CHARGING` at 100% while still plugged in. `plugged` is the ground
     * truth for "a charger is attached", so it wins whenever it is set.
     */
    val isPluggedIn: Boolean
        get() = plugged != 0

    val isCharging: Boolean
        get() = isPluggedIn ||
            status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL

    val isFull: Boolean
        get() = level >= FULL_LEVEL

    /** Human-readable charger type, used by the notification and the Dart UI. */
    val plugName: String
        get() = when (plugged) {
            BatteryManager.BATTERY_PLUGGED_AC -> "ac"
            BatteryManager.BATTERY_PLUGGED_USB -> "usb"
            BatteryManager.BATTERY_PLUGGED_WIRELESS -> "wireless"
            0 -> "none"
            else -> "other"
        }

    fun toMap(): Map<String, Any?> = mapOf(
        "level" to level,
        "status" to status,
        "plugged" to plugged,
        "isCharging" to isCharging,
        "isPluggedIn" to isPluggedIn,
        "isFull" to isFull,
        "plugName" to plugName,
        "temperature" to temperatureTenthsC / 10.0,
        "voltage" to voltageMilliVolts,
        "health" to healthName,
        "technology" to technology,
    )

    private val healthName: String
        get() = when (health) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "overheat"
            BatteryManager.BATTERY_HEALTH_DEAD -> "dead"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "over_voltage"
            BatteryManager.BATTERY_HEALTH_COLD -> "cold"
            BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "failure"
            else -> "unknown"
        }

    companion object {
        const val FULL_LEVEL = 100

        val UNKNOWN = BatterySnapshot(level = 0, status = BatteryManager.BATTERY_STATUS_UNKNOWN, plugged = 0)

        /** Decodes a sticky `ACTION_BATTERY_CHANGED` intent. Returns [UNKNOWN] for a null intent. */
        fun from(intent: Intent?): BatterySnapshot {
            if (intent == null) return UNKNOWN
            val raw = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            val level = if (raw < 0 || scale <= 0) 0 else Math.round(raw * 100f / scale)
            return BatterySnapshot(
                level = level.coerceIn(0, 100),
                status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, BatteryManager.BATTERY_STATUS_UNKNOWN),
                plugged = intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0),
                temperatureTenthsC = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0),
                voltageMilliVolts = intent.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0),
                health = intent.getIntExtra(BatteryManager.EXTRA_HEALTH, BatteryManager.BATTERY_HEALTH_UNKNOWN),
                technology = intent.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY).orEmpty(),
            )
        }
    }
}
