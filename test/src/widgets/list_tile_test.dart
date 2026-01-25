import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('ListTile renders title and subtitle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Column(
          children: [
            ListTile(
              title: const w.Text('Title'),
              subtitle: const w.Text('Subtitle'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
  });

  testWidgets('ListTile onTap works', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: ListTile(
          title: const w.Text('Tap Me'),
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.text('Tap Me'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
