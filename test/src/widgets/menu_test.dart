import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Menu renders items and handles tap', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Menu(
          children: [
            MenuItem(label: const w.Text('Item 1'), onTap: () => tapped = true),
            MenuItem(label: const w.Text('Item 2'), onTap: () {}),
          ],
        ),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    await tester.tap(find.text('Item 1'));
    expect(tapped, true);
  });
}
