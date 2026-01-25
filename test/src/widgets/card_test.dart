import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Card renders child', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: const Card(child: w.Text('Hello Card')),
      ),
    );

    expect(find.text('Hello Card'), findsOneWidget);

    // Hover smoke test (visual mainly, but check no crash)
    final TestGesture gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await gesture.addPointer(location: w.Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byType(Card)));
    await tester.pumpAndSettle();
  });
}
