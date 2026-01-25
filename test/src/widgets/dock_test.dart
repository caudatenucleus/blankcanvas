import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Dock renders items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(child: Dock(children: [w.Text('Item 1'), w.Text('Item 2')])),
      ),
    );

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
  });
}
