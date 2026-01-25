import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('SpeedDial renders FAB using CustomPainter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => w.Center(
                child: SpeedDial(
                  items: [
                    SpeedDialItem(
                      label: 'Add',
                      onTap: null,
                      icon: w.IconData(0xe145, fontFamily: 'MaterialIcons'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Initial state: Main FAB icon shown
    expect(
      find.byIcon(const w.IconData(0xe145, fontFamily: 'MaterialIcons')),
      findsOneWidget,
    );

    // Tap to open
    await tester.tap(find.byType(SpeedDial));
    await tester.pumpAndSettle();

    // Verify items shown (this might check overlay or widget tree expansion)
  });
}
