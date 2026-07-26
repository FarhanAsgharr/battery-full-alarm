package com.hananideas.batteryalarm.alarm

import android.content.Context
import android.content.pm.PackageManager
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.os.Handler
import android.os.Looper
import android.util.Log

/**
 * Blinks the camera flash while the alarm is sounding.
 *
 * Uses `CameraManager.setTorchMode`, which needs no CAMERA permission — the app never
 * opens a camera stream, so no image data is ever accessible to it.
 */
class TorchController(private val context: Context) {

    private val handler = Handler(Looper.getMainLooper())
    private val cameraManager: CameraManager? =
        context.getSystemService(Context.CAMERA_SERVICE) as? CameraManager

    private var cameraId: String? = null
    private var on = false
    private var blinking = false

    val isAvailable: Boolean
        get() = context.packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH) &&
            resolveCameraId() != null

    fun start() {
        if (blinking || !isAvailable) return
        blinking = true
        handler.post(blinkRunnable)
    }

    fun stop() {
        blinking = false
        handler.removeCallbacks(blinkRunnable)
        setTorch(false)
    }

    private val blinkRunnable = object : Runnable {
        override fun run() {
            if (!blinking) return
            setTorch(!on)
            handler.postDelayed(this, if (on) ON_MS else OFF_MS)
        }
    }

    private fun setTorch(enabled: Boolean) {
        val id = resolveCameraId() ?: return
        runCatching { cameraManager?.setTorchMode(id, enabled) }
            .onFailure { Log.w(TAG, "Torch toggle failed", it) }
            .onSuccess { on = enabled }
    }

    private fun resolveCameraId(): String? {
        cameraId?.let { return it }
        val manager = cameraManager ?: return null
        val id = runCatching {
            manager.cameraIdList.firstOrNull { candidate ->
                manager.getCameraCharacteristics(candidate)
                    .get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
            }
        }.getOrNull()
        cameraId = id
        return id
    }

    private companion object {
        const val TAG = "TorchController"
        const val ON_MS = 220L
        const val OFF_MS = 220L
    }
}
