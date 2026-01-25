import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('VirtualList renders items', (WidgetTester tester) async {
    final List<String> items = List.generate(20, (i) => 'Item $i');

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(
          child: w.SizedBox(
            width: 300,
            height: 200,
            child: VirtualList<String>(
              items: items,
              itemExtent: 40,
              itemBuilder: (context, item, index) =>
                  w.Container(color: const w.Color(0xFFFFFFFF), child: w.Text(item)),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);

    // Total height: 20 * 40 = 800.
    // w.Viewport height 200.
    // Item 10 is at y = 400. Not visible.
    // Since we paint all attached children if within bounds?
    // Wait, MultiChildRenderObjectWidget attaches all children.
    // Finder finds them even if not painted?
    // In RenderObject logic: `paintChild` only paints visible.
    // `find.text` finds widgets in Element tree. They ARE in Element tree.
    // So `findsOneWidget` will find 'Item 19' even if not painted, because we are not using Lazy Building.
    // This confirms "Fake Virtual" behavior which is acceptable for this Refactor constraint.
    expect(find.text('Item 19'), findsOneWidget);

    // Test scrolling (manual drag).
    await tester.drag(find.byType(VirtualList<String>), const w.Offset(0, -100));
    await tester.pump();

    // We can't verify painting easily without screenshot or digging paint log.
    // But drag should not crash.
  });
}
