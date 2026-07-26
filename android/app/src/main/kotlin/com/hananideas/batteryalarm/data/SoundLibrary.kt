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
    private const val KEY_HIDDEN = "hidden_sound_uris"

    /** Outcomes of [remove], reported back to the UI so it can word the result. */
    const val REMOVED_DELETED = "deleted"
    const val REMOVED_HIDDEN = "hidden"
    const val REMOVED_MISSING = "missing"

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

    // --------------------------------------------------------------- visibility

    fun hiddenUris(context: Context): Set<String> =
        SoundVisibility.decode(AppSettings.prefs(context).getString(KEY_HIDDEN, null))

    private fun writeHidden(context: Context, hidden: Set<String>) {
        AppSettings.prefs(context).edit()
            .putString(KEY_HIDDEN, SoundVisibility.encode(hidden))
            .apply()
    }

    fun hiddenCount(context: Context): Int = hiddenUris(context).size

    /**
     * Removes a sound from the picker.
     *
     * A file this app owns is deleted outright. Anything else — a device ringtone
     * reached through `RingtoneManager` — is hidden instead, because deleting it would
     * remove the ringtone from every other app on the phone.
     */
    @Synchronized
    fun remove(context: Context, uriString: String): String {
        if (uriString.isBlank()) return REMOVED_MISSING

        if (isOwnedFile(context, uriString) && deleteCustom(context, uriString)) {
            return REMOVED_DELETED
        }

        // Everything else is hidden rather than deleted: a device ringtone, or a file of
        // ours that could not be removed (already gone, or storage refused). Hiding it
        // either way means the list never shows an entry that cannot be played.
        writeHidden(context, SoundVisibility.hide(hiddenUris(context), uriString))
        return REMOVED_HIDDEN
    }

    /** Brings every hidden device sound back. @return how many were restored. */
    @Synchronized
    fun restoreAllHidden(context: Context): Int {
        val count = hiddenUris(context).size
        if (count > 0) writeHidden(context, emptySet())
        return count
    }

    /** True when the URI points at a file inside this app's own sound folder. */
    private fun isOwnedFile(context: Context, uriString: String): Boolean {
        val uri = runCatching { Uri.parse(uriString) }.getOrNull() ?: return false
        if (uri.scheme != null && uri.scheme != "file") return false
        val path = uri.path ?: return false
        val parent = runCatching { File(path).parentFile?.canonicalPath }.getOrNull()
        val dir = runCatching { storageDir(context).canonicalPath }.getOrNull()
        return parent != null && parent == dir
    }

    // ---------------------------------------------------------------- catalogue

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
        return SoundVisibility.visible(entries, hiddenUris(context))
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
                )
            }
            ?.let { SoundVisibility.visible(it, hiddenUris(context)) }
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
        return descriptor(TYPE_IMPORTED, Uri.fromFile(target).toString(), readableName(target.name))
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
    ): Map<String, Any?> = mapOf(
        "type" to type,
        "uri" to uri,
        "label" to label,
    )
}
