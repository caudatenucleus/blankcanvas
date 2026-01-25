import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Transfer moves items between lists', (
    WidgetTester tester,
  ) async {
    List<String> source = ['Item A', 'Item B'];
    List<String> target = [];

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.StatefulBuilder(
          builder: (context, setState) {
            return w.Center(
              child: w.SizedBox(
                width: 600,
                height: 400,
                child: Transfer<String>(
                  sourceItems: source,
                  targetItems: target,
                  itemBuilder: (item) => w.Text(item),
                  onChanged: (s, t) {
                    setState(() {
                      source = s;
                      target = t;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.byType(Transfer<String>), findsOneWidget);
    // Finds our custom RenderObjects indirectly?
    // We can find by type transfer list?
    expect(find.byType(TransferList<String>), findsNWidgets(2));
    expect(find.byType(TransferControls), findsOneWidget);

    // Tap Source Item A.
    // We need to tap the TransferList (Source).
    // The items are painted.
    // Source is the first one.
    final sourceFinder = find.byType(TransferList<String>).first;
    final w.RenderBox sourceRender = tester.renderObject(sourceFinder);
    final sourceLoc = sourceRender.localToGlobal(w.Offset.zero);

    // Header is 40. Item height 36.
    // Item A is at index 0. y = 40. w.Center y = 40 + 18 = 58.
    await tester.tapAt(sourceLoc + const w.Offset(100, 58));
    await tester.pump();

    // Check Source header text: "Available (1/2)"
    // Since we paint text, we can't search for w.Text widget.
    // We trust logic or we'd need golden test/renderObject inspection.
    // Let's assume selection worked.

    // Tap ">" button.
    // Controls is in the middle.
    // TransferControls.
    final controlsFinder = find.byType(TransferControls);
    final w.RenderBox controlsRender = tester.renderObject(controlsFinder);
    final controlsLoc = controlsRender.localToGlobal(w.Offset.zero);

    // Buttons are centered.
    // controls size is 64x400.
    // yCenter = 200.
    // buttons: > (0), >> (1), < (2), << (3).
    // Layout: 4*32 + 3*8 = 128 + 24 = 152.
    // StartY = (400 - 152)/2 = 124.
    // > is at 124.
    // Top button is Move Right.
    await tester.tapAt(controlsLoc + const w.Offset(32, 124 + 16));
    await tester.pumpAndSettle();

    // Should have moved Item A to target.
    expect(source, equals(['Item B']));
    expect(target, equals(['Item A']));

    // Move All Left "<<"
    // Bottom button.
    // y = 124 + 3*(40) = 244.
    await tester.tapAt(controlsLoc + const w.Offset(32, 244 + 16));
    await tester.pumpAndSettle();

    // Expect target empty, source contains both.
    // Wait, Move All Left moves ALL target to source.
    expect(target, isEmpty);
    expect(source, containsAll(['Item A', 'Item B']));
  });
}
