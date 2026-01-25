import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Drawer renders child and animates', (WidgetTester tester) async {
    // We need to setup a context to call showDrawer or test Drawer directly.
    // Testing Drawer directly with animation controller.

    final w.AnimationController controller = w.AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 200),
    );
    controller.value = 1.0; // Fully Open

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Align(
          alignment: w.Alignment.centerLeft,
          child: Drawer(animation: controller, child: const w.Text('Menu Item')),
        ),
      ),
    );

    expect(find.text('Menu Item'), findsOneWidget);

    // Check hit test (open)
    await tester.tap(find.text('Menu Item'));

    // Close animation
    controller.value = 0.5;
    await tester.pump();
    // Still found
    expect(find.text('Menu Item'), findsOneWidget);
  });
}
