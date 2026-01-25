import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Scrollbar renders child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Scrollbar(child: w.Text('Item 0')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
  });
}
