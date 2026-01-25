import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('SwipeAction renders child', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: SwipeAction(
          rightActions: [
            SwipeActionItem(child: const w.Text('Delete'), onPressed: () {}),
          ],
          child: w.Container(
            height: 60,
            color: const w.Color(0xFFFFFFFF),
            child: const w.Text('Swipe me'),
          ),
        ),
      ),
    );

    expect(find.text('Swipe me'), findsOneWidget);
  });

  testWidgets('Pulse animates', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Pulse(
          child: w.Container(
            width: 50,
            height: 50,
            color: const w.Color(0xFF0000FF),
          ),
        ),
      ),
    );

    expect(find.byType(Pulse), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(Pulse), findsOneWidget);
  });

  testWidgets('Wave renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Wave(
          child: w.Container(
            width: 200,
            height: 100,
            color: const w.Color(0xFF00FF00),
          ),
        ),
      ),
    );

    expect(find.byType(Wave), findsOneWidget);
  });

  testWidgets('Ripple renders and responds to tap', (
    WidgetTester tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Ripple(
          onTap: () => tapped = true,
          child: w.Container(
            width: 100,
            height: 100,
            color: const w.Color(0xFFFF0000),
          ),
        ),
      ),
    );

    expect(find.byType(Ripple), findsOneWidget);
    await tester.tap(find.byType(Ripple));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
