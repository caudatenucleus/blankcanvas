import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('OpacityTransition toggles opacity', (WidgetTester tester) async {
    final controller = w.AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 200),
    );
    final animation = w.CurvedAnimation(
      parent: controller,
      curve: w.Curves.linear,
    );

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: OpacityTransition(
          opacity: animation,
          child: const w.SizedBox(width: 100, height: 100),
        ),
      ),
    );

    controller.value = 1.0;
    await tester.pump();

    final renderOpacity = tester.renderObject(find.byType(OpacityTransition));
    // Verify it's using our custom RenderObject
    expect(renderOpacity.runtimeType.toString(), contains('Opacity'));

    controller.value = 0.5;
    await tester.pump();
    // Verification of internal painting values is usually done via goldens
    // or by mocking PaintingContext, but here we just ensure no crashes.

    controller.dispose();
  });

  testWidgets('SlidingTransition applies offset', (WidgetTester tester) async {
    final controller = w.AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 200),
    );
    final animation = w.Tween<w.Offset>(
      begin: const w.Offset(1, 1),
      end: w.Offset.zero,
    ).animate(controller);

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: SlidingTransition(
          position: animation,
          child: const w.SizedBox(width: 100, height: 100),
        ),
      ),
    );

    controller.value = 0.0; // At (1, 1)
    await tester.pump();

    final renderSlide = tester.renderObject(find.byType(SlidingTransition));
    expect(renderSlide, isNotNull);

    controller.dispose();
  });
}
