import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('CardStack renders and swipes', (WidgetTester tester) async {
    int swipedIndex = -1;
    w.DismissDirection? swipedDirection;

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(
          child: w.SizedBox(
            width: 300,
            height: 400,
            child: CardStack(
              itemCount: 3,
              visibleCards: 3,
              itemBuilder: (context, index) {
                return w.Container(
                  color: const w.Color(0xFF00FF00),
                  child: w.Text('Card $index'),
                );
              },
              onSwipe: (index, direction) {
                swipedIndex = index;
                swipedDirection = direction;
              },
            ),
          ),
        ),
      ),
    );

    // Check initial render
    expect(find.text('Card 0'), findsOneWidget);
    expect(find.text('Card 1'), findsOneWidget);
    expect(find.text('Card 2'), findsOneWidget);

    // Swipe top card (Card 0) to RIGHT (StartToEnd)
    // Card 0 is painted last (on top).
    // w.Center at 150, 200.
    await tester.drag(find.text('Card 0'), const w.Offset(200, 0));
    await tester.pumpAndSettle();

    expect(
      swipedIndex,
      0,
    ); // "index" passed is unused/0 currently in RenderCardStack
    expect(swipedDirection, w.DismissDirection.startToEnd);

    // Reset
    swipedIndex = -1;
    swipedDirection = null;

    // Swipe left
    await tester.drag(find.text('Card 0'), const w.Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(swipedIndex, 0);
    expect(swipedDirection, w.DismissDirection.endToStart);
  });
}
