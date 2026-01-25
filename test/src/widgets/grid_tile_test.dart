import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('GridTile renders header, footer, body', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: GridTile(
          header: const w.Text('Header'),
          footer: const w.Text('Footer'),
          child: const w.Text('Body'),
        ),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });
}
