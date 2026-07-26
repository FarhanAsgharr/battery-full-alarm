package com.hananideas.batteryalarm.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.hananideas.batteryalarm.core.ServiceActions
import com.hananideas.batteryalarm.data.AppSettings

/**
 * Restores monitoring after a reboot or an app update.
 *
 * `BOOT_COMPLETED` and `MY_PACKAGE_REPLACED` are both on the short list of broadcasts
 * still allowed to start a foreground service from the background, and `specialUse` is
 * not among the service types Android 14 blocks at boot — so these starts are
 * legitimate rather than best-effort.
 *
 * Handling `MY_PACKAGE_REPLACED` matters more than it looks: installing an update stops
 * the service, and without this the app would silently stop monitoring until the user
 * next opened it — which for this app could be the night they most needed the alarm.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        val isBoot = action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_LOCKED_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON"
        val isUpdate = action == Intent.ACTION_MY_PACKAGE_REPLACED
        if (!isBoot && !isUpdate) return

        // Auto-start-after-boot is opt-out only for reboots; an app update should not
        // silently turn monitoring off for someone who had it on a minute earlier.
        if (isBoot && !AppSettings.load(context).autoStartAfterBoot) return
        if (!AppSettings.isMonitoringEnabled(context)) return

        MonitorWatchdogJob.schedule(context)
        val started = BatteryMonitorService.send(context, ServiceActions.START)
        Log.i(TAG, "Restore after ${if (isUpdate) "update" else "boot"}, started=$started")
    }

    private companion object {
        const val TAG = "BootReceiver"
    }
}
