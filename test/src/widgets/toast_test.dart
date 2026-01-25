import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Toast displays and dismisses', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) {
                return w.Builder(
                  builder: (context) {
                    return w.GestureDetector(
                      onTap: () =>
                          ToastManager.show(context, message: 'Hello Toast'),
                      child: const w.Text('Show Toast'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Show Toast'));
    await tester.pump(); // Frame for insert

    expect(find.text('Hello Toast'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4)); // Wait for timer
    await tester.pump(); // Frame for removal

    expect(find.text('Hello Toast'), findsNothing);
  });
}
