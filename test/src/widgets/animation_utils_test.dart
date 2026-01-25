import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Flip shows front and back', (WidgetTester tester) async {
    final isFront = w.ValueNotifier<bool>(true);

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.ValueListenableBuilder<bool>(
          valueListenable: isFront,
          builder: (context, front, _) => Flip(
            isFront: front,
            front: const w.Text('Front'),
            back: const w.Text('Back'),
          ),
        ),
      ),
    );

    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    isFront.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('CrossFade toggles children', (WidgetTester tester) async {
    final controller = w.AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 300),
    );

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: CrossFade(
          progress: controller,
          firstChild: const w.Text('First'),
          secondChild: const w.Text('Second'),
        ),
      ),
    );

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    controller.value = 1.0;
    await tester.pump();

    expect(find.byType(CrossFade), findsOneWidget);

    controller.dispose();
  });

  testWidgets('PageTransition builds route', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Navigator(
          onGenerateRoute: (settings) {
            return PageTransition(
              child: const w.Text('Next Page'),
              type: PageTransitionType.fade,
            );
          },
        ),
      ),
    );

    expect(find.text('Next Page'), findsOneWidget);
  });
}
