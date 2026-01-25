import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('NavigationRail renders items', (WidgetTester tester) async {
    int selected = 0;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Row(
          children: [
            NavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (i) => selected = i,
              destinations: const [
                NavigationRailDestination(icon: w.Text('1'), label: 'One'),
                NavigationRailDestination(icon: w.Text('2'), label: 'Two'),
              ],
            ),
          ],
        ),
      ),
    );

    // We can't find text because it's painted directly.
    expect(find.byType(NavigationRail), findsOneWidget);

    // Tap second item (index 1).
    // Layout: Leading(optional) -> Item 0 (y=0 or below leading) -> Item 1.
    // Leading is null. Item height is 56.
    // Item 0: 0-56. Item 1: 56-112.
    // w.Center of Item 1 is approx y=84.
    await tester.tapAt(
      tester.getTopLeft(find.byType(NavigationRail)) + const w.Offset(36, 84),
    );
    expect(selected, 1);
  });
}
