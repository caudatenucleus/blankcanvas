import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Popconfirm shows overlay on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) {
                return w.Center(
                  child: Popconfirm(
                    title: 'Are you sure?',
                    onConfirm: () {},
                    child: const w.Text('Delete'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    expect(find.text('Are you sure?'), findsNothing);

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(find.text('Are you sure?'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
