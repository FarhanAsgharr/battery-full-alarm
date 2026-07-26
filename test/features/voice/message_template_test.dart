import 'package:battery_full_alarm/features/voice/domain/message_template.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors `MessageFormatterTest.kt` case for case.
///
/// The in-app preview and the sentence the foreground service speaks come from two
/// separate implementations; these tests are what keep them honest.
void main() {
  String format(String template, String name, [int level = 100]) =>
      MessageTemplate.format(
        template: template,
        userName: name,
        batteryLevel: level,
      );

  group('MessageTemplate.format', () {
    test('substitutes the user name', () {
      expect(
        format('{name}, your phone is charged.', 'Muhammad'),
        'Muhammad, your phone is charged.',
      );
    });

    test('drops the name placeholder and its comma when no name is set', () {
      expect(format('{name}, your phone is charged.', ''), 'Your phone is charged.');
    });

    test('substitutes the battery level', () {
      expect(format('Battery is at {level} percent.', ''), 'Battery is at 100 percent.');
    });

    test('handles both placeholders together', () {
      expect(
        format('{name}, the battery is at {level} percent.', 'Ali'),
        'Ali, the battery is at 100 percent.',
      );
    });

    test('trims surrounding whitespace and collapses runs of spaces', () {
      expect(format('   Charging   is complete.  ', ''), 'Charging is complete.');
    });

    test('trims the supplied name', () {
      expect(
        format('{name}, unplug the charger.', '  Sara  '),
        'Sara, unplug the charger.',
      );
    });

    test('capitalises the first letter after the placeholder is removed', () {
      expect(format('{name} unplug the charger now.', ''), 'Unplug the charger now.');
    });

    test('leaves a message with no placeholders untouched', () {
      expect(
        format('Battery is fully charged. Please unplug your phone.', 'Muhammad'),
        'Battery is fully charged. Please unplug your phone.',
      );
    });

    test('removes an Arabic comma after the name placeholder', () {
      expect(format('{name}، افصل الشاحن.', ''), 'افصل الشاحن.');
    });

    test('keeps a name that appears more than once', () {
      expect(
        format('{name}, {name}, the battery is full.', 'Zara'),
        'Zara, Zara, the battery is full.',
      );
    });

    test('reports the actual level, not always 100', () {
      expect(format('Battery is at {level} percent.', '', 87), 'Battery is at 87 percent.');
    });
  });

  test('every suggestion formats to a non-empty sentence with and without a name', () {
    for (final suggestion in MessageTemplate.suggestions) {
      expect(format(suggestion, 'Muhammad'), isNotEmpty);
      expect(format(suggestion, ''), isNotEmpty);
      expect(format(suggestion, ''), isNot(startsWith(',')));
    }
  });
}
