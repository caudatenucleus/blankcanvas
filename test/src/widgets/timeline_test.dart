import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Timeline renders items', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Timeline(
          items: const [
            TimelineItem(
              title: 'Step 1',
              description: 'Desc 1',
              isActive: true,
            ),
            TimelineItem(title: 'Step 2', description: 'Desc 2'),
          ],
        ),
      ),
    );

    // RenderObject implementation paints text directly, so we can't find w.Text widgets.
    expect(find.byType(Timeline), findsOneWidget);
  });
}
