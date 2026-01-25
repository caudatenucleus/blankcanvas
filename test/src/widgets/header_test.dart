import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Header renders title and actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Header(
          title: w.Text('My App'),
          leading: w.Text('Back'),
          actions: [w.Text('Save')],
        ),
      ),
    );

    expect(find.text('My App'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
