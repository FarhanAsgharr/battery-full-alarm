package com.hananideas.batteryalarm.data

import org.json.JSONArray

/**
 * Which sounds the picker shows, and how that choice is stored.
 *
 * The "built-in" sounds are the device's own alarm ringtones, reached through
 * `RingtoneManager` — they are not files this app owns. Removing one therefore cannot
 * mean deleting it: that would take the ringtone away from the clock app and every
 * other alarm app on the phone. Instead the URI is remembered here as hidden, and
 * filtered out of the catalogue.
 *
 * Kept free of Android types so the rule and its storage format can be unit-tested on
 * the JVM.
 */
object SoundVisibility {

    /** Serialises the hidden set for `SharedPreferences`. */
    fun encode(hidden: Set<String>): String {
        val array = JSONArray()
        hidden.filter { it.isNotBlank() }.sorted().forEach { array.put(it) }
        return array.toString()
    }

    /** Reads the hidden set back. Unreadable or absent data means "nothing hidden". */
    fun decode(raw: String?): Set<String> {
        if (raw.isNullOrBlank()) return emptySet()
        return runCatching {
            val array = JSONArray(raw)
            (0 until array.length())
                .mapNotNull { array.optString(it, null)?.takeIf(String::isNotBlank) }
                .toSet()
        }.getOrDefault(emptySet())
    }

    /** Drops every entry whose `uri` the user has hidden. */
    fun visible(
        sounds: List<Map<String, Any?>>,
        hidden: Set<String>,
    ): List<Map<String, Any?>> {
        if (hidden.isEmpty()) return sounds
        return sounds.filterNot { it["uri"] as? String in hidden }
    }

    fun hide(hidden: Set<String>, uri: String): Set<String> =
        if (uri.isBlank()) hidden else hidden + uri

    fun reveal(hidden: Set<String>, uri: String): Set<String> = hidden - uri
}
