import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Watermark renders content and overlay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Watermark(text: 'CONFIDENTIAL', child: w.Text('Content')),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
    // Since we added an Offstage text widget, we can find it!
    expect(find.text('CONFIDENTIAL', skipOffstage: false), findsOneWidget);
  });
}
