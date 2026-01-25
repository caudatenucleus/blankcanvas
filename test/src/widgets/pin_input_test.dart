import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('PinInput renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: PinInput(length: 4, onChanged: (v) {}, onCompleted: (v) {}),
      ),
    );

    expect(find.byType(PinInput), findsOneWidget);
    // Verify PinInput renders
    expect(find.byType(PinInput), findsOneWidget);
  });
}
