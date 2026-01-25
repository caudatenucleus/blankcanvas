import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('TextField accepts input and renders text', (
    WidgetTester tester,
  ) async {
    final controller = w.TextEditingController(text: 'Initial');

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: TextField(controller: controller, placeholder: 'w.Placeholder'),
      ),
    );

    // Check render object props
    final renderObject =
        tester.renderObject(find.byType(TextField)) as RenderTextField;

    // Test initial state from controller
    expect(renderObject.value.text, 'Initial');

    // Simulate input from engine (IME)
    // We update the render object directly as if the engine called updateEditingValue
    renderObject.updateEditingValue(const TextEditingValue(text: 'Updated'));

    // Controller should be updated
    expect(controller.text, 'Updated');

    // Simulate input from controller (Programmatic change)
    controller.text = 'Controller';
    // Pump to process listener
    await tester.pump();

    expect(renderObject.value.text, 'Controller');
  });
}
