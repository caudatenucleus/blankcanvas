import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Spinner renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const w.Directionality(textDirection: w.TextDirection.ltr, child: Spinner()),
    );

    expect(find.byType(Spinner), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100)); // Animate
  });
}
