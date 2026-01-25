import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('StickyHeader sticks to top', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.CustomScrollView(
          slivers: [
            StickyHeader(child: w.SizedBox(height: 50, child: w.Text('Header'))),
            w.SliverList(
              delegate: w.SliverChildBuilderDelegate(
                (context, index) => w.Text('Item $index'),
                childCount: 100,
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Header'), findsOneWidget);

    // Scroll down
    await tester.drag(find.text('Item 0'), const w.Offset(0, -200));
    await tester.pump();

    // Header should still be visible (pinned)
    expect(find.text('Header'), findsOneWidget);
  });
}
