import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Toolbar renders items in slots', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Toolbar(
          leading: const w.Text('Leading'),
          middle: const w.Text('Title'),
          actions: const [w.Text('w.Action')],
        ),
      ),
    );

    expect(find.text('Leading'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('w.Action'), findsOneWidget);

    // Verify layout order? Leading should be left (ltr) usage.
    final leadingPos = tester.getTopLeft(find.text('Leading'));
    final titlePos = tester.getTopLeft(find.text('Title'));
    final actionPos = tester.getTopLeft(find.text('w.Action'));

    expect(leadingPos.dx < titlePos.dx, true);
    expect(titlePos.dx < actionPos.dx, true);
  });
}
