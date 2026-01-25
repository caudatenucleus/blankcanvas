import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('CascadeSelect renders and handles selection', (
    WidgetTester tester,
  ) async {
    List<String> selected = [];

    // Options
    // A -> [A1, A2]
    // B -> [B1 -> [B1.1, B1.2]]

    final options = [
      CascadeOption(
        value: 'A',
        label: 'Option A',
        children: [
          CascadeOption(value: 'A1', label: 'Option A1'),
          CascadeOption(value: 'A2', label: 'Option A2'),
        ],
      ),
      CascadeOption(
        value: 'B',
        label: 'Option B',
        children: [
          CascadeOption(
            value: 'B1',
            label: 'Option B1',
            children: [CascadeOption(value: 'B1.1', label: 'Option B1.1')],
          ),
        ],
      ),
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
                  child: CascadeSelect<String>(
                    options: options,
                    selectedPath: selected,
                    onChanged: (path) => selected = path,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Initial render
    expect(find.byType(CascadeSelect<String>), findsOneWidget);

    // Tap to open
    await tester.tap(find.byType(CascadeSelect<String>));
    await tester.pumpAndSettle();

    // Should see Popup
    expect(find.byType(CascadeSelectPopup<String>), findsOneWidget);

    // Should see w.Column 0 items: Option A, Option B
    // We can't use find.text() because RenderCascadeSelectPopup paints text manually.
    // We must tap by coordinates relative to popup.
    // w.Column 0 is at x=0. Item A (idx 0) y=0. Item B (idx 1) y=40.

    final popupFinder = find.byType(CascadeSelectPopup<String>);
    final w.RenderBox popup = tester.renderObject(popupFinder);
    final popupLoc = popup.localToGlobal(w.Offset.zero);

    // Tap 'Option A' (Col 0, Item 0)
    await tester.tapAt(popupLoc + const w.Offset(50, 20));
    await tester.pumpAndSettle();

    // Should have expanded w.Column 1 with A1, A2.
    // Tap 'Option A1' (Col 1, Item 0)
    // Col 1 starts at x=150.
    await tester.tapAt(popupLoc + const w.Offset(150 + 50, 20));
    await tester.pumpAndSettle();

    // Selection should be finished (A1 is leaf)
    expect(selected, equals(['A', 'A1']));

    // Verify overlay closed?
    expect(find.byType(CascadeSelectPopup<String>), findsNothing);
  });
}
