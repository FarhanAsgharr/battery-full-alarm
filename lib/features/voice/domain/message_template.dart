import '../../../core/constants/app_constants.dart';

/// Expands the announcement template exactly the way Kotlin's `MessageFormatter` does,
/// so the in-app preview is the sentence the alarm will actually speak.
///
/// The two implementations are covered by matching test cases; changing one without the
/// other will show up as a preview that no longer matches reality.
class MessageTemplate {
  const MessageTemplate._();

  static final _namePlus = RegExp(r'\{name\}\s*[,،-]?\s*');
  static final _collapseSpaces = RegExp(r'\s{2,}');

  static String format({
    required String template,
    required String userName,
    required int batteryLevel,
  }) {
    final name = userName.trim();
    var text = template.replaceAll(AppConstants.levelToken, '$batteryLevel');

    text = name.isEmpty
        // Drop the placeholder together with the punctuation that would dangle after it.
        ? text.replaceAll(_namePlus, '')
        : text.replaceAll(AppConstants.nameToken, name);

    text = text.trim().replaceAll(_collapseSpaces, ' ');
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Ready-made messages offered on the voice screen. Kept as templates so the user's
  /// name and level are substituted at speak time.
  static const suggestions = <String>[
    AppConstants.defaultVoiceMessage,
    '{name}, charging is complete. Please unplug the charger now.',
    'Battery is at {level} percent. Please disconnect the charger.',
    '{name}, your battery is full. Unplug it to protect battery health.',
  ];
}
