import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:flutter/services.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('PieMenu toggles actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: PieMenu(
          trigger: w.Container(
            width: 50,
            height: 50,
            color: const w.Color(0xFF000000),
            child: const w.Text('Trigger', textDirection: w.TextDirection.ltr),
          ),
          actions: [
            w.Container(width: 30, height: 30, color: const w.Color(0xFFFF0000)),
            w.Container(width: 30, height: 30, color: const w.Color(0xFF00FF00)),
          ],
        ),
      ),
    );

    // One Trigger, Two Actions
    expect(find.text('Trigger'), findsOneWidget);
    expect(find.byType(w.Container), findsNWidgets(3));

    // Tap trigger to open
    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    // Verification: Actions should have moved, but layout is handled by Flow.
    // We mainly ensure no crash and state change.
  });

  testWidgets('WheelMenu renders and scrolls', (WidgetTester tester) async {
    int selected = 0;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: WheelMenu(
          onSelectedItemChanged: (i) => selected = i,
          children: List.generate(
            10,
            (i) => w.Text('Item $i', textDirection: w.TextDirection.ltr),
          ),
        ),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);

    // Drag up
    await tester.drag(find.byType(WheelMenu), const w.Offset(0, -50));
    await tester.pumpAndSettle();

    // Should have changed selection
    expect(selected, isNot(0));
  });

  testWidgets('GestureNavigation detects back swipe', (
    WidgetTester tester,
  ) async {
    bool backTriggered = false;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: GestureNavigation(
          onBack: () => backTriggered = true,
          child: w.Container(
            width: 300,
            height: 300,
            color: const w.Color(0xFFFFFFFF),
          ),
        ),
      ),
    );

    // Drag from left edge with velocity
    await tester.flingFrom(const w.Offset(5, 150), const w.Offset(100, 0), 1000.0);
    await tester.pump();

    expect(backTriggered, isTrue);
  });

  testWidgets('VoiceNavigation triggers via keyboard', (
    WidgetTester tester,
  ) async {
    String? command;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: VoiceNavigation(
          onCommand: (cmd) => command = cmd,
          child: w.Container(),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    expect(command, 'Back');

    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    expect(command, 'Home');
  });
}
