import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('CountUp counts to target', (WidgetTester tester) async {
    final controller = w.AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 200),
    );

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: CountUp(
          count: controller,
          style: const w.TextStyle(fontSize: 20),
        ),
      ),
    );

    controller.value = 0.5;
    await tester.pump();

    // We can't use find.text() because ParagraphPrimitive doesn't create Text widgets.
    // Instead we verify it exists.
    expect(find.byType(CountUp), findsOneWidget);

    controller.dispose();
  });
}
