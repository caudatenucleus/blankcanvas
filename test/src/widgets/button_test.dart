import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Button renders and handles tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: CustomizedTheme(
          data: const ControlCustomizations(),
          child: Button(
            onPressed: () => tapped = true,
            child: const w.Text('Click Me'),
          ),
        ),
      ),
    );

    expect(find.text('Click Me'), findsOneWidget);

    // Tap
    await tester.tap(find.byType(Button));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('Button supports customization', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: CustomizedTheme(
          data: ControlCustomizations(
            buttons: {
              'custom': ButtonCustomization.simple(
                width: 200,
                height: 50,
                backgroundColor: const w.Color(0xFFFF0000),
              ),
            },
          ),
          child: w.Center(
            child: Button(
              tag: 'custom',
              onPressed: () {},
              child: const w.Text('Custom'),
            ),
          ),
        ),
      ),
    );
    // Verify size via RenderObject
    final w.RenderBox box = tester.renderObject(find.byType(Button));
    expect(box.size, const w.Size(200, 50));
  });
}
