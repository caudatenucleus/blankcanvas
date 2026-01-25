import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('MultiSelect renders chips and toggles options', (
    WidgetTester tester,
  ) async {
    List<String> selected = ['A'];

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => w.StatefulBuilder(
                builder: (ctx, setState) {
                  return w.Center(
                    child: w.SizedBox(
                      width: 300,
                      child: MultiSelect<String>(
                        options: ['A', 'B', 'C'],
                        selectedValues: selected,
                        onChanged: (val) {
                          setState(() {
                            selected = val;
                          });
                        },
                        labelBuilder: (s) => 'Item $s',
                        placeholder: 'Select...',
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

    final renderMultiSelect =
        tester.renderObject(find.byType(MultiSelect<String>))
            as RenderMultiSelect;
    expect(renderMultiSelect.childCount, 1); // 1 Chip

    // Tap to open
    await tester.tap(find.byType(MultiSelect<String>));
    await tester.pumpAndSettle();

    final popupFinder = find.byType(MultiSelectPopup<String>);
    expect(popupFinder, findsOneWidget);

    final w.RenderBox popupRender = tester.renderObject(popupFinder) as w.RenderBox;
    final popupTopLeft = popupRender.localToGlobal(w.Offset.zero);

    // Tap Index 1 ('B') -> y range [36, 72]. Mid: 54.
    await tester.tapAt(popupTopLeft + const w.Offset(50, 54));
    await tester.pumpAndSettle();

    expect(selected, containsAll(['A', 'B']));

    // Tap Index 0 ('A') -> y range [0, 36]. Mid: 18.
    await tester.tapAt(popupTopLeft + const w.Offset(50, 18));
    await tester.pumpAndSettle();

    expect(selected, equals(['B'])); // A removed
  });
}
