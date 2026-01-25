import 'package:flutter/widgets.dart' as w;
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('ContextMenu shows and handles taps', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => w.Center(
                child: ContextMenu(
                  items: [
                    ContextMenuItem(label: 'Item 1', onTap: () {}),
                    ContextMenuItem(
                      label: 'Item 2',
                      onTap: () {
                        tapped = true;
                      },
                    ),
                  ],
                  child: const w.SizedBox(
                    width: 100,
                    height: 100,
                    child: w.Text('Trigger'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Right click
    await tester.tap(find.text('Trigger'), buttons: kSecondaryButton);
    await tester.pump(); // Insert overlay

    expect(find.byType(ContextOverlay), findsOneWidget);

    // Tap outside (barrier)
    await tester.tapAt(w.Offset.zero);
    await tester.pump();

    expect(find.byType(ContextOverlay), findsNothing);

    // Show again
    await tester.tap(find.text('Trigger'), buttons: kSecondaryButton);
    await tester.pump();

    expect(find.byType(ContextOverlay), findsOneWidget);

    final renderContent =
        tester.renderObject(find.byType(ContextMenuContent)) as w.RenderBox;
    final contentLoc = renderContent.localToGlobal(w.Offset.zero);

    // Tap at (10, 40 + 10).
    await tester.tapAt(contentLoc + const w.Offset(10, 50));
    await tester.pump();

    expect(tapped, isTrue);
    expect(find.byType(ContextOverlay), findsNothing);
  });
}
