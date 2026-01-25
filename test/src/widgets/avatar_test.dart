import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Avatar renders label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Avatar(label: w.Text('A'), showStatus: true),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.byType(Avatar), findsOneWidget);
  });
}
