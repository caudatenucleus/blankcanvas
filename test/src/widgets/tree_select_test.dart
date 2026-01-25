import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('TreeSelect renders and handles selection', (
    WidgetTester tester,
  ) async {
    String? selected;

    // Nodes
    final nodes = [
      TreeSelectNode(
        value: 'A',
        label: 'Node A',
        children: [
          TreeSelectNode(value: 'A1', label: 'Node A1'),
          TreeSelectNode(value: 'A2', label: 'Node A2'),
        ],
      ),
      TreeSelectNode(value: 'B', label: 'Node B'),
    ];

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (ctx) => w.Center(
                child: w.SizedBox(
                  width: 300,
                  child: TreeSelect<String>(
                    nodes: nodes,
                    selectedValue: selected,
                    onSelected: (val) => selected = val,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.byType(TreeSelect<String>), findsOneWidget);

    // Open
    await tester.tap(find.byType(TreeSelect<String>));
    await tester.pumpAndSettle();

    expect(find.byType(TreeSelectPopup<String>), findsOneWidget);

    // Check items.
    // RenderTreeSelectPopup paints items.
    // Initially A (collapsed) and B.
    // Height: 2 items * 40 = 80.

    final popupFinder = find.byType(TreeSelectPopup<String>);
    final w.RenderBox popup = tester.renderObject(popupFinder);
    final popupLoc = popup.localToGlobal(w.Offset.zero);

    // Tap expand icon for A
    // w.Icon is at x=[12, 32]. A is at y=0.
    await tester.tapAt(popupLoc + const w.Offset(20, 20));
    await tester.pumpAndSettle();

    // Should expand. Now 4 items visible: A, A1, A2, B.
    // Height 160.

    // Tap A1.
    // A1 is at index 1 (y=40).
    // Tap center of A1 row.
    await tester.tapAt(popupLoc + const w.Offset(100, 60)); // 40 + 20
    await tester.pumpAndSettle();

    expect(selected, 'A1');
    expect(find.byType(TreeSelectPopup<String>), findsNothing);
  });

  testWidgets('TreeSelect MultiSelect', (WidgetTester tester) async {
    List<String> selected = [];

    final nodes = [
      TreeSelectNode(value: 'A', label: 'Node A'),
      TreeSelectNode(value: 'B', label: 'Node B'),
    ];

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (ctx) => w.StatefulBuilder(
                builder: (context, setState) {
                  return w.Center(
                    child: w.SizedBox(
                      width: 300,
                      child: TreeSelect<String>(
                        nodes: nodes,
                        multiSelect: true,
                        selectedValues: selected,
                        onSelected: (_) {},
                        onMultiSelect: (vals) {
                          setState(() {
                            selected = vals;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(TreeSelect<String>));
    await tester.pumpAndSettle();

    final popupFinder = find.byType(TreeSelectPopup<String>);
    final w.RenderBox popup = tester.renderObject(popupFinder);
    final popupLoc = popup.localToGlobal(w.Offset.zero);

    // Tap A (Index 0)
    await tester.tapAt(popupLoc + const w.Offset(100, 20));
    await tester.pumpAndSettle();

    expect(selected, contains('A'));

    // Tap B (Index 1)
    await tester.tapAt(popupLoc + const w.Offset(100, 60));
    await tester.pumpAndSettle();

    expect(selected, containsAll(['A', 'B']));

    // Tap A again to deselect
    await tester.tapAt(popupLoc + const w.Offset(100, 20));
    await tester.pumpAndSettle();

    expect(selected, equals(['B']));
  });
}
