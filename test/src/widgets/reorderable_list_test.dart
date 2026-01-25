import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('ReorderableList renders items', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: ReorderableList(
          onReorder: (oldIndex, newIndex) {},
          children: [
            w.SizedBox(height: 50, key: w.ValueKey('1'), child: w.Text('Item 1')),
            w.SizedBox(height: 50, key: w.ValueKey('2'), child: w.Text('Item 2')),
          ],
        ),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    // Test layout
    final rItem1 = tester.renderObject(find.byKey(w.ValueKey('1'))) as w.RenderBox;
    final rItem2 = tester.renderObject(find.byKey(w.ValueKey('2'))) as w.RenderBox;

    final pd1 = rItem1.parentData as ReorderableListParentData;
    final pd2 = rItem2.parentData as ReorderableListParentData;

    expect(pd1.offset.dy, 0);
    // rItem1 height is 50.
    // pd2 offset should be 50.
    expect(pd2.offset.dy, 50);
  });
}
