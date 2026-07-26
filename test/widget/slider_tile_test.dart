import 'package:battery_full_alarm/features/settings/presentation/widgets/slider_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the fix for a real performance bug: the slider used to persist to
/// `SharedPreferences` and push the whole settings map across the platform channel on
/// every drag frame.
void main() {
  Widget host({
    required double value,
    required ValueChanged<double> onCommit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SliderTile(
          icon: Icons.volume_up,
          title: 'Alarm volume',
          value: value,
          min: 0,
          max: 100,
          divisions: 10,
          formatValue: (v) => '${v.round()}%',
          onCommit: onCommit,
        ),
      ),
    );
  }

  testWidgets('does not commit while the user is dragging', (tester) async {
    final commits = <double>[];
    await tester.pumpWidget(host(value: 50, onCommit: commits.add));

    final gesture = await tester.startGesture(tester.getCenter(find.byType(Slider)));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();

    expect(commits, isEmpty, reason: 'a drag in progress must not hit storage');

    await gesture.up();
    await tester.pumpAndSettle();

    expect(commits, hasLength(1));
    expect(commits.single, greaterThan(50));
  });

  testWidgets('the label tracks the finger even though nothing is saved yet',
      (tester) async {
    await tester.pumpWidget(host(value: 50, onCommit: (_) {}));
    expect(find.text('50%'), findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(find.byType(Slider)));
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();

    expect(find.text('50%'), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('an external value change overrides a stale drag value', (tester) async {
    await tester.pumpWidget(host(value: 50, onCommit: (_) {}));

    final gesture = await tester.startGesture(tester.getCenter(find.byType(Slider)));
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    // e.g. settings reloaded, or the user hit "reset" elsewhere.
    await tester.pumpWidget(host(value: 20, onCommit: (_) {}));
    await tester.pumpAndSettle();

    expect(find.text('20%'), findsOneWidget);
    await gesture.up();
  });
}
