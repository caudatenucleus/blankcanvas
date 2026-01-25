import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Masonry renders items simple', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.SizedBox(
          width: 400,
          child: Masonry(
            columnCount: 2,
            spacing: 10,
            children: List.generate(
              4,
              (index) => w.Container(
                height: (index + 1) * 50.0,
                color: const w.Color(0xFFFF0000),
                child: w.Text('Item $index'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);

    // RenderObject implementation doesn't use Rows/Columns
    expect(find.byType(Masonry), findsOneWidget);
    // Verify layout logic by checking positions
    final item0 = tester.getTopLeft(find.text('Item 0'));
    final item1 = tester.getTopLeft(find.text('Item 1'));
    // Item 1 should be in second column (to the right of Item 0)
    expect(item1.dx, greaterThan(item0.dx));
  });
}
