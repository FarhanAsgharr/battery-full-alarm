package com.hananideas.batteryalarm.core

/**
 * Expands the user's announcement template into the sentence the TTS engine speaks.
 *
 * Supported placeholders: `{name}` and `{level}`. When the user has not set a name,
 * `{name}` is removed along with the punctuation that would be left dangling, so
 * "{name}, your phone is charged." reads as "Your phone is charged." rather than
 * ", your phone is charged."
 *
 * The Dart side has a byte-for-byte equivalent in `lib/features/voice/domain/message_template.dart`
 * so the in-app preview matches what the service actually says.
 */
object MessageFormatter {

    fun format(template: String, userName: String, batteryLevel: Int): String {
        val name = userName.trim()
        var text = template.replace(LEVEL_TOKEN, batteryLevel.toString())

        text = if (name.isEmpty()) {
            // Drop the placeholder plus any comma/dash and spacing that followed it.
            text.replace(Regex("""\{name}\s*[,،-]?\s*"""), "")
        } else {
            text.replace(NAME_TOKEN, name)
        }

        return text.trim()
            .replace(Regex("""\s{2,}"""), " ")
            .replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
    }

    private const val NAME_TOKEN = "{name}"
    private const val LEVEL_TOKEN = "{level}"
}
