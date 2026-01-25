import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('CardStack renders visible cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: CardStack(
          itemCount: 5,
          visibleCards: 3,
          itemBuilder: (context, index) => w.Container(
            width: 200,
            height: 300,
            color: w.Color(0xFF000000 + index * 0x111111),
            child: w.Text('Card $index'),
          ),
        ),
      ),
    );

    // Should show first 3 cards (indices 0, 1, 2)
    expect(find.text('Card 0'), findsOneWidget);
    expect(find.text('Card 1'), findsOneWidget);
    expect(find.text('Card 2'), findsOneWidget);
    expect(find.text('Card 3'), findsNothing);
  });

  testWidgets('Tilt renders child', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Tilt(
          child: w.Container(
            width: 100,
            height: 100,
            color: const w.Color(0xFFFF0000),
          ),
        ),
      ),
    );

    expect(find.byType(Tilt), findsOneWidget);
    // RenderObject implementation doesn't use MouseRegion widget
    expect(find.byType(w.Container), findsOneWidget);
  });

  testWidgets('Shimmer animates', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Shimmer(
          child: w.Container(
            width: 100,
            height: 20,
            color: const w.Color(0xFFCCCCCC),
          ),
        ),
      ),
    );

    expect(find.byType(Shimmer), findsOneWidget);

    // Advance animation
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(Shimmer), findsOneWidget);
  });

  testWidgets('Parallax renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.ListView(
          children: [
            Parallax(
              background: w.Container(
                height: 200,
                color: const w.Color(0xFF0000FF),
              ),
              child: const w.SizedBox(height: 150),
            ),
          ],
        ),
      ),
    );

    expect(find.byType(Parallax), findsOneWidget);
  });
}
