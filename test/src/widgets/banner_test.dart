import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Banner renders with message and action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Banner(
          message: 'This is a warning',
          action: 'Retry',
          onAction: () {},
        ),
      ),
    );

    expect(find.text('This is a warning'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
