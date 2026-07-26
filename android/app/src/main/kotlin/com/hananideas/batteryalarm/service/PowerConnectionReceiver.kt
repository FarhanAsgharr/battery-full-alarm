package com.hananideas.batteryalarm.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.hananideas.batteryalarm.core.ServiceActions
import com.hananideas.batteryalarm.data.AppSettings

/**
 * Safety net for the case where the monitor service is not running when a charger is
 * plugged in — for example after the system killed the process and did not recreate it.
 *
 * `ACTION_POWER_CONNECTED` is *not* on Android 12's list of broadcasts exempt from the
 * background foreground-service restriction, so this start can legitimately be refused.
 * The normal path keeps the service alive continuously; this is an opportunistic retry
 * and failure here is expected and harmless.
 */
class PowerConnectionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_POWER_CONNECTED) return
        if (BatteryMonitorService.isRunning) return

        val settings = AppSettings.load(context)
        if (!settings.autoStartMonitoring) return
        if (!AppSettings.isMonitoringEnabled(context)) return

        val started = BatteryMonitorService.send(context, ServiceActions.START)
        Log.i(TAG, "Charger connected while service was down, restart=$started")
    }

    private companion object {
        const val TAG = "PowerConnectionReceiver"
    }
}
