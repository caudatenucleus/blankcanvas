import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Splitter renders two children', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Splitter(
          first: w.Text('Left'),
          second: w.Text('Right'),
          initialRatio: 0.5,
        ),
      ),
    );

    expect(find.text('Left'), findsOneWidget);
    expect(find.text('Right'), findsOneWidget);

    // Test layout? Hard.
    // Ensure both are present is mostly enough for basic verification.
  });
}
