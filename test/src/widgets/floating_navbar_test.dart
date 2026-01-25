import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('FloatingNavbar renders items', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(
          child: FloatingNavbar(
            items: [
              FloatingNavbarItem(
                icon: w.IconData(0xe88a, fontFamily: 'MaterialIcons'),
                label: 'Home',
              ),
              FloatingNavbarItem(
                icon: w.IconData(0xe8b6, fontFamily: 'MaterialIcons'),
                label: 'Search',
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.text('Home'),
      findsOneWidget,
    ); // IsSelected is 0 by default, so Home label shows
    expect(
      find.text('Search'),
      findsNothing,
    ); // Unselected items hide label? Logic says "if (isSelected) w.Text(...)".
    // Wait, let's check logic.
    // if (isSelected) w.Text(...)
    // So 'Search' which is index 1 (not current 0) should NOT have text.
  });
}
