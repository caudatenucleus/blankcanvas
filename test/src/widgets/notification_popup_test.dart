import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('NotificationPopup shows and dismisses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => w.Center(
                child: w.GestureDetector(
                  onTap: () {
                    NotificationPopup.show(
                      context,
                      child: const w.Text(
                        'Hello Popup',
                        textDirection: w.TextDirection.ltr,
                      ),
                      duration: NotificationDuration.long,
                    );
                  },
                  child: const w.Text('Show'),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Tap to show
    await tester.tap(find.text('Show'));
    await tester.pump(); // Insert overlay
    await tester.pump(const Duration(milliseconds: 50)); // Start animation

    expect(find.text('Hello Popup'), findsOneWidget);

    // Wait for dismiss (mock time)
    // Duration long = 5000ms.
    // + 200ms fade in.
    // + 200ms fade out.
    await tester.pump(const Duration(milliseconds: 6000));
    await tester.pumpAndSettle();

    expect(find.text('Hello Popup'), findsNothing);
  });
}
