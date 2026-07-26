package com.hananideas.batteryalarm

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import com.hananideas.batteryalarm.alarm.AlarmPlayer
import com.hananideas.batteryalarm.alarm.VolumeGuard
import com.hananideas.batteryalarm.core.AppBus
import com.hananideas.batteryalarm.core.BatterySnapshot
import com.hananideas.batteryalarm.core.Channels
import com.hananideas.batteryalarm.data.AppSettings
import com.hananideas.batteryalarm.data.HistoryStore
import com.hananideas.batteryalarm.data.SoundLibrary
import com.hananideas.batteryalarm.media.VoiceRecorder
import com.hananideas.batteryalarm.service.BatteryMonitorService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The only bridge between Dart and the native monitoring stack.
 *
 * Dart owns presentation and settings editing; everything that has to survive the
 * Flutter engine being torn down — the monitor service, the alarm, the charging log —
 * lives in Kotlin and is reached through the method channel declared here.
 *
 * Sound and voice *previews* run in an activity-scoped [AlarmPlayer] rather than in the
 * service, so the settings screens work whether or not monitoring is switched on.
 */
class MainActivity : FlutterActivity() {

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    private lateinit var previewPlayer: AlarmPlayer
    private lateinit var recorder: VoiceRecorder

    private var pendingPickResult: MethodChannel.Result? = null

    private val busListener: (Map<String, Any?>) -> Unit = { payload ->
        eventSink?.success(payload)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Covers the case where a preview or test alarm raised the system alarm volume
        // and the process died before it could be put back. The service does the same
        // on its own start; whichever component runs first wins and the other no-ops.
        VolumeGuard.restoreIfPending(this)
        previewPlayer = AlarmPlayer(this)
        recorder = VoiceRecorder(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, Channels.METHOD).apply {
            setMethodCallHandler(::handleMethodCall)
        }

        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, Channels.EVENTS).apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    AppBus.subscribe(busListener)
                    events?.success(currentState())
                }

                override fun onCancel(arguments: Any?) {
                    AppBus.unsubscribe(busListener)
                    eventSink = null
                }
            })
        }
    }

    override fun onDestroy() {
        // A file picker open at teardown would otherwise leave the Dart future hanging
        // for ever, and the sound screen stuck on "importing".
        pendingPickResult?.success(null)
        pendingPickResult = null

        AppBus.unsubscribe(busListener)
        eventSink = null
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        recorder.cancel()
        previewPlayer.release()
        super.onDestroy()
    }

    override fun onPause() {
        // Never leave a preview ringing behind when the user leaves the screen.
        previewPlayer.stopPreview()
        super.onPause()
    }

    // ---------------------------------------------------------- method channel

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getState" -> result.success(currentState())

            "getCapabilities" -> result.success(capabilities())

            "startMonitoring" -> {
                BatteryMonitorService.start(this)
                result.success(true)
            }

            "stopMonitoring" -> {
                BatteryMonitorService.stop(this)
                result.success(true)
            }

            "updateSettings" -> {
                val map = call.arguments as? Map<*, *>
                if (map == null) {
                    result.error("bad_args", "updateSettings expects a settings map", null)
                    return
                }
                val settings = AppSettings.fromMap(map)
                AppSettings.save(this, settings)
                previewPlayer.updateSettings(settings)
                BatteryMonitorService.notifySettingsChanged(this)
                result.success(settings.toMap())
            }

            "stopAlarm" -> {
                BatteryMonitorService.stopAlarm(this)
                previewPlayer.stop()
                result.success(true)
            }

            "testAlarm" -> {
                previewPlayer.stop()
                previewPlayer.start(
                    settings = AppSettings.load(this),
                    batteryLevel = readBattery().level,
                    listener = null,
                    maxCycles = 1,
                )
                result.success(true)
            }

            "stopTest" -> {
                previewPlayer.stop()
                previewPlayer.stopPreview()
                result.success(true)
            }

            "previewSound" -> {
                val uri = call.argument<String>("uri")
                val volume = call.argument<Int>("volume") ?: AppSettings.load(this).alarmVolumePercent
                previewPlayer.previewSound(uri, volume)
                result.success(true)
            }

            "previewVoice" -> {
                previewPlayer.previewVoice(AppSettings.load(this), readBattery().level)
                result.success(true)
            }

            "stopPreview" -> {
                previewPlayer.stopPreview()
                result.success(true)
            }

            "getSounds" -> result.success(
                mapOf(
                    "builtIn" to SoundLibrary.builtIn(this),
                    "custom" to SoundLibrary.custom(this),
                    "hiddenCount" to SoundLibrary.hiddenCount(this),
                ),
            )

            "pickAudioFile" -> pickAudioFile(result)

            // One entry point for both kinds of removal. The UI does not decide whether
            // a sound is deleted or hidden — SoundLibrary does, and reports which.
            "removeSound" -> {
                val uri = call.argument<String>("uri").orEmpty()
                previewPlayer.stopPreview()
                result.success(
                    mapOf(
                        "outcome" to SoundLibrary.remove(this, uri),
                        "hiddenCount" to SoundLibrary.hiddenCount(this),
                    ),
                )
            }

            "restoreDefaultSounds" -> result.success(SoundLibrary.restoreAllHidden(this))

            "startRecording" -> {
                val label = call.argument<String>("label").orEmpty()
                if (!recorder.hasPermission()) {
                    result.error("permission_denied", "Microphone permission is required", null)
                    return
                }
                previewPlayer.stopPreview()
                result.success(recorder.start(label))
            }

            "stopRecording" -> result.success(recorder.stop())

            "cancelRecording" -> {
                recorder.cancel()
                result.success(true)
            }

            "getHistory" -> result.success(HistoryStore.all(this).map { it.toMap() })

            "deleteHistoryEntry" -> {
                val id = (call.argument<Any>("id") as? Number)?.toLong()
                if (id == null) {
                    result.error("bad_args", "deleteHistoryEntry expects an id", null)
                    return
                }
                HistoryStore.delete(this, id)
                result.success(true)
            }

            "clearHistory" -> {
                HistoryStore.clear(this)
                result.success(true)
            }

            "isIgnoringBatteryOptimizations" -> result.success(isIgnoringBatteryOptimizations())

            "openBatteryOptimizationSettings" -> {
                // The system list, not a direct exemption request: asking for
                // REQUEST_IGNORE_BATTERY_OPTIMIZATIONS is restricted on Google Play.
                result.success(openSettings(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
            }

            "openNotificationSettings" -> {
                val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                result.success(launch(intent))
            }

            "openTtsSettings" -> result.success(openSettings("com.android.settings.TTS_SETTINGS"))

            else -> result.notImplemented()
        }
    }

    // --------------------------------------------------------------- file pick

    private fun pickAudioFile(result: MethodChannel.Result) {
        if (pendingPickResult != null) {
            result.error("busy", "A file picker is already open", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
            .addCategory(Intent.CATEGORY_OPENABLE)
            .setType("audio/*")
            .putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("audio/*", "application/ogg"))

        val launched = runCatching {
            startActivityForResult(intent, REQUEST_PICK_AUDIO)
            true
        }.getOrElse { false }

        if (launched) {
            pendingPickResult = result
        } else {
            // No document provider on the device — surfaced to the user as a message.
            result.success(null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_PICK_AUDIO) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val pending = pendingPickResult
        pendingPickResult = null

        val uri: Uri? = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            pending?.success(null)
            return
        }
        val imported = SoundLibrary.importDocument(this, uri)
        if (imported == null) {
            pending?.error("import_failed", "The selected file could not be copied", null)
        } else {
            pending?.success(imported)
        }
    }

    // ----------------------------------------------------------------- helpers

    private fun currentState(): Map<String, Any?> {
        val cached = AppBus.last
        val battery = (cached?.get("battery") as? Map<*, *>) ?: readBattery().toMap()
        return mapOf(
            "battery" to battery,
            "monitoring" to AppSettings.isMonitoringEnabled(this),
            "serviceRunning" to BatteryMonitorService.isRunning,
            "alarming" to (cached?.get("alarming") as? Boolean ?: false),
            "session" to cached?.get("session"),
            "settings" to AppSettings.load(this).toMap(),
        )
    }

    private fun capabilities(): Map<String, Any?> {
        val settings = AppSettings.load(this)
        return mapOf(
            "hasFlash" to previewPlayer.torchAvailable,
            "hasVibrator" to previewPlayer.vibrationAvailable,
            "ttsReady" to previewPlayer.isTtsReady,
            // TextToSpeech initialises asynchronously. Until it is ready the answer is
            // unknown, and reporting "unavailable" would flash a warning on the home
            // screen for every cold start; the screen re-queries on resume.
            "ttsLanguageAvailable" to
                (!previewPlayer.isTtsReady || previewPlayer.isTtsLanguageAvailable(settings)),
            "ignoringBatteryOptimizations" to isIgnoringBatteryOptimizations(),
            "canRecord" to recorder.hasPermission(),
        )
    }

    private fun readBattery(): BatterySnapshot =
        BatterySnapshot.from(registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED)))

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val manager = getSystemService(Context.POWER_SERVICE) as? PowerManager ?: return false
        return runCatching { manager.isIgnoringBatteryOptimizations(packageName) }.getOrDefault(false)
    }

    private fun openSettings(action: String): Boolean = launch(Intent(action))

    private fun launch(intent: Intent): Boolean = runCatching {
        startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        true
    }.getOrElse {
        Log.w(TAG, "Could not open ${intent.action}", it)
        false
    }

    private companion object {
        const val TAG = "MainActivity"
        const val REQUEST_PICK_AUDIO = 4001
    }
}
