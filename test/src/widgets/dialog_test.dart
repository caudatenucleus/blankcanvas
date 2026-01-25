import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Dialog renders child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Dialog(child: w.Text('Content')),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
  });
}
