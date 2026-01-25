import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Badge renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Badge(
          label: const w.Text('1'),
          child: w.SizedBox(width: 50, height: 50),
        ),
      ),
    );
    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
