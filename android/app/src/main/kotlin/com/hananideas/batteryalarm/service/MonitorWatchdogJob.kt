package com.hananideas.batteryalarm.service

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.util.Log
import com.hananideas.batteryalarm.core.ServiceActions
import com.hananideas.batteryalarm.data.AppSettings

/**
 * A periodic check that the monitor service is still alive, and a restart if it is not.
 *
 * Why this exists: `START_STICKY` is a request, not a guarantee, and several
 * manufacturers — Xiaomi/MIUI, Oppo and Realme/ColorOS, Vivo/Funtouch, and Huawei/EMUI
 * most of all — kill background services and then decline to recreate them. On those
 * devices the app would go quiet after a day and the user would only notice when an
 * alarm they were relying on never rang.
 *
 * `JobScheduler` is part of the framework (no dependency), survives reboots when
 * persisted, and is one of the few things those OEM task-killers leave alone.
 *
 * This is best-effort by design. On Android 12+ starting a foreground service from a
 * job is refused unless the app is exempt from battery optimisation, so the restart can
 * fail — [BatteryMonitorService.send] swallows that. It is a safety net behind the
 * primary mechanism (a service that simply stays running), not a replacement for the
 * user granting unrestricted battery use.
 */
class MonitorWatchdogJob : JobService() {

    override fun onStartJob(params: JobParameters?): Boolean {
        val shouldRun = AppSettings.isMonitoringEnabled(this)
        if (shouldRun && !BatteryMonitorService.isRunning) {
            val restarted = BatteryMonitorService.send(this, ServiceActions.START)
            Log.i(TAG, "Watchdog found the monitor stopped; restart requested=$restarted")
        } else if (!shouldRun) {
            // Monitoring was switched off while the job was scheduled — stand down.
            cancel(this)
        }
        // All the work is done synchronously on the main thread and takes microseconds.
        return false
    }

    override fun onStopJob(params: JobParameters?): Boolean = false

    companion object {
        private const val TAG = "MonitorWatchdog"
        private const val JOB_ID = 8021

        /** The framework floor for a periodic job is 15 minutes. */
        private const val INTERVAL_MS = 15 * 60 * 1000L

        fun schedule(context: Context) {
            val scheduler = context.getSystemService(JobScheduler::class.java) ?: return
            if (scheduler.getPendingJob(JOB_ID) != null) return

            val job = JobInfo.Builder(JOB_ID, ComponentName(context, MonitorWatchdogJob::class.java))
                .setPeriodic(INTERVAL_MS)
                .setPersisted(true)
                .setRequiresDeviceIdle(false)
                .setRequiresCharging(false)
                .build()

            runCatching { scheduler.schedule(job) }
                .onFailure { Log.w(TAG, "Could not schedule the watchdog", it) }
        }

        fun cancel(context: Context) {
            runCatching {
                context.getSystemService(JobScheduler::class.java)?.cancel(JOB_ID)
            }
        }
    }
}
