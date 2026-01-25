import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart' hide TextField;

void main() {
  testWidgets('NumberInput renders', (WidgetTester tester) async {
    final controller = w.TextEditingController(text: '10');
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: NumberInput(controller: controller),
      ),
    );

    expect(find.byType(NumberInput), findsOneWidget);
    expect(find.byType(NumberInput), findsOneWidget);
    final input = tester.widget<NumberInput>(find.byType(NumberInput));
    expect(input.controller?.text, '10');
  });
}
