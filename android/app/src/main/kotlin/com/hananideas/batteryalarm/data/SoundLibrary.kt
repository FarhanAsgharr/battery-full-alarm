package com.hananideas.batteryalarm.data

import android.content.Context
import android.media.RingtoneManager
import android.net.Uri
import android.provider.OpenableColumns
import java.io.File

/**
 * The catalogue of sounds the alarm can play.
 *
 * Built-in entries come from the device's own alarm ringtones via [RingtoneManager] —
 * no bundled audio assets, no download, no licensing question. Custom entries are files
 * the user imported or recorded, copied into the app's private storage so playback keeps
 * working after the source file moves or its permission grant expires.
 */
object SoundLibrary {

    const val TYPE_BUILT_IN = "builtin"
    const val TYPE_IMPORTED = "imported"
    const val TYPE_RECORDED = "recorded"

    private const val DIR = "alarm_sounds"
    private const val IMPORT_PREFIX = "imported_"
    private const val RECORD_PREFIX = "recorded_"

    fun storageDir(context: Context): File =
        File(context.filesDir, DIR).apply { if (!exists()) mkdirs() }

    /**
     * The device default alarm tone, used when the user has not picked anything.
     * Falls back through ringtone and notification tones; null only on a device with
     * no system sounds at all, in which case the alarm runs silent (speech, vibration
     * and torch still fire).
     */
    fun defaultAlarmUri(): Uri? =
        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

    fun builtIn(context: Context): List<Map<String, Any?>> {
        val entries = mutableListOf<Map<String, Any?>>()
        entries += descriptor(TYPE_BUILT_IN, defaultAlarmUri()?.toString().orEmpty(), "Default alarm")

        runCatching {
            val manager = RingtoneManager(context).apply { setType(RingtoneManager.TYPE_ALARM) }
            val cursor = manager.cursor
            while (cursor.moveToNext()) {
                val position = cursor.position
                val title = manager.getRingtone(position)?.getTitle(context)
                    ?: cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                val uri = manager.getRingtoneUri(position)?.toString() ?: continue
                if (entries.none { it["uri"] == uri }) {
                    entries += descriptor(TYPE_BUILT_IN, uri, title)
                }
            }
        }
        return entries
    }

    fun custom(context: Context): List<Map<String, Any?>> =
        storageDir(context).listFiles()
            ?.filter { it.isFile }
            ?.sortedByDescending { it.lastModified() }
            ?.map { file ->
                val type = if (file.name.startsWith(RECORD_PREFIX)) TYPE_RECORDED else TYPE_IMPORTED
                descriptor(
                    type = type,
                    uri = Uri.fromFile(file).toString(),
                    label = readableName(file.name),
                    deletable = true,
                )
            }
            ?: emptyList()

    /**
     * Copies a document the user picked into private storage.
     * Returns the new descriptor, or null when the copy fails.
     */
    fun importDocument(context: Context, source: Uri): Map<String, Any?>? {
        val original = queryDisplayName(context, source) ?: "sound"
        val extension = original.substringAfterLast('.', "mp3").take(5)
        val base = original.substringBeforeLast('.').replace(Regex("[^A-Za-z0-9 _-]"), "").trim()
            .ifEmpty { "sound" }
        val target = uniqueFile(context, "$IMPORT_PREFIX$base", extension)

        val copied = runCatching {
            context.contentResolver.openInputStream(source)?.use { input ->
                target.outputStream().use { output -> input.copyTo(output) }
            } != null
        }.getOrDefault(false)

        if (!copied || target.length() == 0L) {
            target.delete()
            return null
        }
        return descriptor(TYPE_IMPORTED, Uri.fromFile(target).toString(), readableName(target.name), deletable = true)
    }

    /** Destination for a new voice recording. */
    fun newRecordingFile(context: Context, label: String): File {
        val base = label.replace(Regex("[^A-Za-z0-9 _-]"), "").trim().ifEmpty { "recording" }
        return uniqueFile(context, "$RECORD_PREFIX$base", "m4a")
    }

    fun descriptorFor(file: File): Map<String, Any?> = descriptor(
        type = if (file.name.startsWith(RECORD_PREFIX)) TYPE_RECORDED else TYPE_IMPORTED,
        uri = Uri.fromFile(file).toString(),
        label = readableName(file.name),
        deletable = true,
    )

    /** Deletes a custom sound. Refuses anything outside the app's own sound directory. */
    fun deleteCustom(context: Context, uriString: String): Boolean {
        val path = runCatching { Uri.parse(uriString).path }.getOrNull() ?: return false
        val file = File(path)
        val dir = storageDir(context)
        if (file.parentFile?.canonicalPath != dir.canonicalPath) return false
        return file.delete()
    }

    private fun uniqueFile(context: Context, prefix: String, extension: String): File {
        val dir = storageDir(context)
        var candidate = File(dir, "$prefix.$extension")
        var counter = 1
        while (candidate.exists()) {
            candidate = File(dir, "$prefix($counter).$extension")
            counter++
        }
        return candidate
    }

    private fun readableName(fileName: String): String = fileName
        .removePrefix(IMPORT_PREFIX)
        .removePrefix(RECORD_PREFIX)
        .substringBeforeLast('.')
        .ifEmpty { fileName }

    private fun queryDisplayName(context: Context, uri: Uri): String? = runCatching {
        context.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { cursor ->
                if (cursor.moveToFirst()) cursor.getString(0) else null
            }
    }.getOrNull() ?: uri.lastPathSegment

    private fun descriptor(
        type: String,
        uri: String,
        label: String,
        deletable: Boolean = false,
    ): Map<String, Any?> = mapOf(
        "type" to type,
        "uri" to uri,
        "label" to label,
        "deletable" to deletable,
    )
}
