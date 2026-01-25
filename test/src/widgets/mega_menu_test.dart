import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('MegaMenu renders trigger and content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => MegaMenu(
                trigger: w.Text('Products'),
                content: w.Text('Full Product List'),
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Products'), findsOneWidget);

    // Tap to open
    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();

    expect(find.text('Full Product List'), findsOneWidget);
  });
}
