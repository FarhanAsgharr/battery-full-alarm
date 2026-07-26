package com.hananideas.batteryalarm.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.BatteryManager
import com.hananideas.batteryalarm.MainActivity
import com.hananideas.batteryalarm.R
import com.hananideas.batteryalarm.core.BatterySnapshot
import com.hananideas.batteryalarm.core.Notifications
import com.hananideas.batteryalarm.core.ServiceActions
import com.hananideas.batteryalarm.data.AppSettings
import java.util.Locale

/**
 * Builds the two notifications the service uses:
 *
 * - a quiet, ongoing **monitor** notification that satisfies the foreground-service
 *   requirement and shows live battery state;
 * - a high-importance **alarm** notification with a "Stop alarm" action, posted only
 *   while the alarm is actually sounding.
 *
 * Both are rendered in the language the user picked *in the app*, which may differ from
 * the device locale, by resolving strings against a locale-overridden context.
 */
object ServiceNotifications {

    fun createChannels(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        val localized = localizedContext(context, AppSettings.load(context).language)

        manager.createNotificationChannel(
            NotificationChannel(
                Notifications.CHANNEL_MONITOR,
                localized.getString(R.string.notif_channel_monitor_name),
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = localized.getString(R.string.notif_channel_monitor_desc)
                setShowBadge(false)
                enableVibration(false)
                setSound(null, null)
            },
        )

        manager.createNotificationChannel(
            NotificationChannel(
                Notifications.CHANNEL_ALARM,
                localized.getString(R.string.notif_channel_alarm_name),
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = localized.getString(R.string.notif_channel_alarm_desc)
                setShowBadge(true)
                // The alarm audio and vibration are driven by AlarmPlayer so they honour
                // the user's chosen tone, volume and interval — the channel stays silent.
                enableVibration(false)
                setSound(null, null)
            },
        )
    }

    fun monitorNotification(
        context: Context,
        settings: AppSettings,
        snapshot: BatterySnapshot,
        monitoring: Boolean,
    ): Notification {
        val localized = localizedContext(context, settings.language)
        val text = if (monitoring) {
            localized.getString(R.string.notif_monitor_text, snapshot.level, statusLabel(localized, snapshot))
        } else {
            localized.getString(R.string.notif_monitor_paused)
        }

        return Notification.Builder(context, Notifications.CHANNEL_MONITOR)
            .setSmallIcon(R.drawable.ic_stat_battery)
            .setContentTitle(localized.getString(R.string.notif_monitor_title))
            .setContentText(text)
            .setContentIntent(openAppIntent(context))
            .setOngoing(true)
            .setShowWhen(false)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }

    fun alarmNotification(context: Context, settings: AppSettings): Notification {
        val localized = localizedContext(context, settings.language)
        val stopIntent = Intent(context, BatteryMonitorService::class.java)
            .setAction(ServiceActions.STOP_ALARM)
        val stopPending = PendingIntent.getService(
            context,
            REQUEST_STOP_ALARM,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return Notification.Builder(context, Notifications.CHANNEL_ALARM)
            .setSmallIcon(R.drawable.ic_stat_battery)
            .setContentTitle(localized.getString(R.string.notif_alarm_title))
            .setContentText(localized.getString(R.string.notif_alarm_text))
            .setContentIntent(openAppIntent(context))
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .addAction(
                Notification.Action.Builder(
                    android.graphics.drawable.Icon.createWithResource(context, R.drawable.ic_stat_alarm_off),
                    localized.getString(R.string.action_stop_alarm),
                    stopPending,
                ).build(),
            )
            .build()
    }

    fun cancelAlarmNotification(context: Context) {
        context.getSystemService(NotificationManager::class.java)?.cancel(Notifications.ID_ALARM)
    }

    private fun statusLabel(localized: Context, snapshot: BatterySnapshot): String = when {
        snapshot.isPluggedIn && snapshot.isFull -> localized.getString(R.string.status_full)
        snapshot.isPluggedIn -> localized.getString(R.string.status_charging)
        snapshot.status == BatteryManager.BATTERY_STATUS_NOT_CHARGING ->
            localized.getString(R.string.status_not_charging)
        else -> localized.getString(R.string.status_discharging)
    }

    private fun openAppIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(
            context,
            REQUEST_OPEN_APP,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /**
     * A context whose resources resolve in the language the user picked in the app,
     * which may differ from the device locale.
     *
     * Cached: `createConfigurationContext` allocates a whole Resources/AssetManager
     * pair, and this is on the path of every notification update in a service that
     * runs for days.
     */
    @Volatile
    private var cachedLocale: String? = null

    @Volatile
    private var cachedContext: Context? = null

    @Synchronized
    private fun localizedContext(context: Context, language: String): Context {
        val tag = language.ifBlank { "en" }
        cachedContext?.let { existing -> if (cachedLocale == tag) return existing }

        val config = android.content.res.Configuration(context.resources.configuration).apply {
            setLocale(Locale.forLanguageTag(tag))
        }
        // Built from the application context so the cache cannot pin an Activity.
        return context.applicationContext.createConfigurationContext(config).also {
            cachedContext = it
            cachedLocale = tag
        }
    }

    private const val REQUEST_OPEN_APP = 100
    private const val REQUEST_STOP_ALARM = 101
}
