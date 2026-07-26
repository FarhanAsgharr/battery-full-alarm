package com.hananideas.batteryalarm.service

import android.app.NotificationManager
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.hananideas.batteryalarm.alarm.AlarmPlayer
import com.hananideas.batteryalarm.alarm.VolumeGuard
import com.hananideas.batteryalarm.core.AppBus
import com.hananideas.batteryalarm.core.BatterySnapshot
import com.hananideas.batteryalarm.core.MonitorAction
import com.hananideas.batteryalarm.core.MonitorPolicy
import com.hananideas.batteryalarm.core.MonitorState
import com.hananideas.batteryalarm.core.Notifications
import com.hananideas.batteryalarm.core.ServiceActions
import com.hananideas.batteryalarm.data.AppSettings
import com.hananideas.batteryalarm.data.ChargeSession
import com.hananideas.batteryalarm.data.HistoryStore

/**
 * The always-on part of the app.
 *
 * A foreground service is the only way on modern Android to observe
 * `ACTION_BATTERY_CHANGED` continuously — that broadcast cannot be declared in the
 * manifest, and background processes are frozen. The service therefore stays alive for
 * as long as monitoring is switched on, does almost nothing between broadcasts, and
 * owns the alarm, the charging-session log and the ongoing notification.
 */
class BatteryMonitorService : Service() {

    private lateinit var alarmPlayer: AlarmPlayer

    private var settings = AppSettings()
    private var snapshot = BatterySnapshot.UNKNOWN
    private var monitorState = MonitorState()
    private var session: ChargeSession? = null
    private var lastPersistedLevel = -1
    private var startedForeground = false

    /** Visible content of the last posted notification, to avoid redundant re-posts. */
    private var lastNotificationKey: String? = null

    /** Last payload sent to Dart, to avoid waking the UI for an unchanged state. */
    private var lastPublished: Map<String, Any?>? = null

    private val batteryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_BATTERY_CHANGED -> onBatteryReading(BatterySnapshot.from(intent))

                // Faster and more reliable than waiting for the next battery broadcast,
                // which is what makes "unplug stops the alarm instantly" hold.
                Intent.ACTION_POWER_DISCONNECTED -> onBatteryReading(snapshot.copy(plugged = 0))

                Intent.ACTION_POWER_CONNECTED -> onBatteryReading(readBatteryNow())
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        settings = AppSettings.load(this)
        // If a previous run was killed mid-alarm it never got to put the user's system
        // alarm volume back. Do it now, before this instance touches the volume itself.
        VolumeGuard.restoreIfPending(this)
        alarmPlayer = AlarmPlayer(this)
        ServiceNotifications.createChannels(this)
        // A fresh instance never has an alarm ringing. If the process was killed
        // mid-alarm and Android recreated the service (START_STICKY), the previous
        // instance's alarm notification is still posted — clear it so the user is not
        // left with a Stop button for an alarm that no longer exists.
        ServiceNotifications.cancelAlarmNotification(this)
        // Likewise, a charge that was in progress when the process died has no owner
        // any more; close it before this instance starts a session of its own.
        HistoryStore.closeDanglingSessions(this)
        registerBatteryReceiver()
        snapshot = readBatteryNow()
        Log.i(TAG, "Battery monitor service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        settings = AppSettings.load(this)
        promoteToForeground()

        when (intent?.action) {
            ServiceActions.STOP -> {
                AppSettings.setMonitoringEnabled(this, false)
                stopAlarm(dismiss = false)
                publish()
                stopForegroundAndSelf()
                return START_NOT_STICKY
            }

            ServiceActions.STOP_ALARM -> {
                stopAlarm(dismiss = true)
            }

            ServiceActions.SETTINGS_CHANGED -> {
                alarmPlayer.updateSettings(settings)
                ServiceNotifications.createChannels(this)
            }

            else -> Unit
        }

        if (!AppSettings.isMonitoringEnabled(this)) {
            stopAlarm(dismiss = false)
            publish()
            stopForegroundAndSelf()
            return START_NOT_STICKY
        }

        onBatteryReading(readBatteryNow())
        // START_STICKY: if Android reclaims the process under memory pressure it is
        // recreated with a null intent, and onCreate + this branch re-arm monitoring.
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        runCatching { unregisterReceiver(batteryReceiver) }
        closeSession(persist = true)
        alarmPlayer.release()
        publish()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ------------------------------------------------------------- monitoring

    private fun onBatteryReading(reading: BatterySnapshot) {
        val previous = snapshot
        snapshot = reading

        trackSession(previous, reading)

        val action = MonitorPolicy.decide(
            snapshot = reading,
            state = monitorState,
            monitoringEnabled = AppSettings.isMonitoringEnabled(this),
        )
        when (action) {
            MonitorAction.START_ALARM -> startAlarm()
            MonitorAction.STOP_ALARM -> stopAlarm(dismiss = false)
            MonitorAction.NONE -> Unit
        }
        monitorState = MonitorPolicy.nextState(monitorState, action, reading)

        updateMonitorNotification()
        publish()
    }

    private fun startAlarm() {
        settings = AppSettings.load(this)
        alarmPlayer.start(
            settings = settings,
            batteryLevel = snapshot.level,
            listener = { count -> onAlarmCycle(count) },
        )
        // The ongoing monitor notification is mandatory for a foreground service, but
        // this second heads-up one is not — the "Show notifications" setting turns it
        // off for users who only want the sound.
        if (settings.notificationsEnabled) {
            notificationManager?.notify(
                Notifications.ID_ALARM,
                ServiceNotifications.alarmNotification(this, settings),
            )
        }
        Log.i(TAG, "Alarm started at ${snapshot.level}%")
    }

    /**
     * @param dismiss true when the user silenced it deliberately, which keeps the alarm
     *   off for the rest of this charging session instead of re-triggering seconds later.
     */
    private fun stopAlarm(dismiss: Boolean) {
        val wasAlarming = alarmPlayer.isRunning
        alarmPlayer.stop()
        ServiceNotifications.cancelAlarmNotification(this)
        if (dismiss) {
            monitorState = monitorState.copy(alarming = false, dismissedForSession = true)
        } else {
            monitorState = monitorState.copy(alarming = false)
        }
        if (wasAlarming) {
            Log.i(TAG, "Alarm stopped (dismissed=$dismiss)")
            updateMonitorNotification()
            publish()
        }
    }

    private fun onAlarmCycle(count: Int) {
        session = session
            ?.copy(alarmCount = count, lastSeenAt = System.currentTimeMillis())
            ?.also { HistoryStore.upsert(this, it) }
        publish()
    }

    // --------------------------------------------------------------- sessions

    private fun trackSession(previous: BatterySnapshot, current: BatterySnapshot) {
        val now = System.currentTimeMillis()

        if (current.isPluggedIn && session == null) {
            session = ChargeSession(
                id = now,
                startedAt = now,
                startLevel = current.level,
                endLevel = current.level,
                peakLevel = current.level,
                fullAt = if (current.isFull) now else 0L,
                plugType = current.plugName,
                lastSeenAt = now,
            ).also { HistoryStore.upsert(this, it) }
            lastPersistedLevel = current.level
            return
        }

        if (!current.isPluggedIn) {
            if (session != null) closeSession(persist = true)
            return
        }

        val active = session ?: return
        val reachedFull = active.fullAt == 0L && current.isFull
        val updated = active.copy(
            endLevel = current.level,
            peakLevel = maxOf(active.peakLevel, current.level),
            fullAt = if (reachedFull) now else active.fullAt,
            lastSeenAt = now,
        )
        session = updated

        // Persist only on meaningful change; ACTION_BATTERY_CHANGED also fires for
        // temperature and voltage drift, which would otherwise cause constant writes.
        if (reachedFull || current.level != lastPersistedLevel || previous.plugged != current.plugged) {
            lastPersistedLevel = current.level
            HistoryStore.upsert(this, updated)
        }
    }

    private fun closeSession(persist: Boolean) {
        val active = session ?: return
        session = null
        lastPersistedLevel = -1
        if (!persist) return
        val closed = active.copy(
            endedAt = System.currentTimeMillis(),
            endLevel = snapshot.level.takeIf { it > 0 } ?: active.endLevel,
        )
        HistoryStore.upsert(this, closed)
    }

    // ---------------------------------------------------------- notifications

    private fun promoteToForeground() {
        val notification = ServiceNotifications.monitorNotification(
            context = this,
            settings = settings,
            snapshot = snapshot,
            monitoring = AppSettings.isMonitoringEnabled(this),
        )
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(
                    Notifications.ID_MONITOR,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
                )
            } else {
                startForeground(Notifications.ID_MONITOR, notification)
            }
            startedForeground = true
        }.onFailure { Log.e(TAG, "startForeground failed", it) }
    }

    /**
     * Re-posts the ongoing notification only when its visible text would actually
     * change.
     *
     * `ACTION_BATTERY_CHANGED` also fires for temperature and voltage drift — several
     * times a minute on some devices — but the notification only shows the level and
     * the charging state. Rebuilding and re-posting it every time was measurable
     * background work for a service that is meant to be idle.
     */
    private fun updateMonitorNotification() {
        if (!startedForeground) return
        val monitoring = AppSettings.isMonitoringEnabled(this)
        val key = "${snapshot.level}|${snapshot.isPluggedIn}|${snapshot.isFull}|" +
            "${snapshot.status}|$monitoring|${settings.language}"
        if (key == lastNotificationKey) return
        lastNotificationKey = key

        notificationManager?.notify(
            Notifications.ID_MONITOR,
            ServiceNotifications.monitorNotification(
                context = this,
                settings = settings,
                snapshot = snapshot,
                monitoring = monitoring,
            ),
        )
    }

    private fun stopForegroundAndSelf() {
        runCatching { stopForeground(STOP_FOREGROUND_REMOVE) }
        startedForeground = false
        stopSelf()
    }

    // --------------------------------------------------------------- plumbing

    private fun registerBatteryReceiver() {
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_BATTERY_CHANGED)
            addAction(Intent.ACTION_POWER_CONNECTED)
            addAction(Intent.ACTION_POWER_DISCONNECTED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(batteryReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(batteryReceiver, filter)
        }
    }

    /** Reads the sticky battery broadcast without waiting for the next change. */
    private fun readBatteryNow(): BatterySnapshot =
        BatterySnapshot.from(registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED)))

    /** Pushes state to the UI, skipping emissions that would change nothing on screen. */
    private fun publish() {
        val payload = mapOf(
            "battery" to snapshot.toMap(),
            "monitoring" to AppSettings.isMonitoringEnabled(this),
            "serviceRunning" to isRunning,
            "alarming" to alarmPlayer.isRunning,
            "session" to session?.toMap(),
        )
        if (payload == lastPublished) return
        lastPublished = payload
        AppBus.emit(payload)
    }

    private val notificationManager: NotificationManager?
        get() = getSystemService(NotificationManager::class.java)

    companion object {
        private const val TAG = "BatteryMonitorService"

        /** Read by `MainActivity` so the Dart layer can show the real service state. */
        @Volatile
        var isRunning: Boolean = false
            private set

        fun start(context: Context) {
            AppSettings.setMonitoringEnabled(context, true)
            MonitorWatchdogJob.schedule(context)
            send(context, ServiceActions.START)
        }

        fun stop(context: Context) {
            AppSettings.setMonitoringEnabled(context, false)
            MonitorWatchdogJob.cancel(context)
            send(context, ServiceActions.STOP)
        }

        fun notifySettingsChanged(context: Context) {
            if (!isRunning) return
            send(context, ServiceActions.SETTINGS_CHANGED)
        }

        fun stopAlarm(context: Context) {
            if (!isRunning) return
            send(context, ServiceActions.STOP_ALARM)
        }

        /**
         * Starting a foreground service is only permitted from the foreground (or from a
         * small set of exempt broadcasts) on Android 12+. Callers that may run in the
         * background — the boot and power receivers — rely on this swallowing the
         * refusal rather than crashing the process.
         */
        fun send(context: Context, action: String): Boolean = runCatching {
            val intent = Intent(context, BatteryMonitorService::class.java).setAction(action)
            context.startForegroundService(intent)
            true
        }.getOrElse {
            Log.w(TAG, "Could not deliver $action to the monitor service", it)
            false
        }
    }
}
