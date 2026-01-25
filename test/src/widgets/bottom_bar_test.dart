import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('BottomBar renders items and handles interaction', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: BottomBar(
          children: [
            BottomBarItem(
              icon: const w.SizedBox(width: 20, height: 20),
              label: const w.Text('Tab 1'),
              selected: true,
              onTap: () {},
            ),
            BottomBarItem(
              icon: const w.SizedBox(width: 20, height: 20),
              label: const w.Text('Tab 2'),
              selected: false,
              onTap: () => tapped = true,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 2'), findsOneWidget);

    await tester.tap(find.text('Tab 2'));
    expect(tapped, true);
  });
}
