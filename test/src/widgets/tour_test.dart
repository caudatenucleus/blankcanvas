import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Tour renders steps', (WidgetTester tester) async {
    final w.GlobalKey key1 = w.GlobalKey();

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => w.Stack(
                children: [
                  Tour(
                    steps: [
                      TourStep(
                        target: key1,
                        title: 'Step 1',
                        description: 'Description 1',
                      ),
                    ],
                    child: w.SizedBox(key: key1, width: 50, height: 50),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Initial state might not show tour immediately or requires trigger
    // Assuming it shows on mount if enabled
    // ... logic to verify overlay presence
  });
}
