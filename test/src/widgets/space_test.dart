import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Space renders correct size', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Column(
          children: [
            const w.Text('A'),
            const Space.vertical(10), // Should provide 10 height
            const w.Text('B'),
          ],
        ),
      ),
    );

    final textA = tester.getBottomLeft(find.text('A'));
    final textB = tester.getTopLeft(find.text('B'));

    expect(textB.dy - textA.dy, equals(10.0));
  });

  testWidgets('Space.h renders horizontal space', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Row(
          children: [
            const w.Text('A'),
            const Space.horizontal(20),
            const w.Text('B'),
          ],
        ),
      ),
    );

    final textA = tester.getTopRight(find.text('A'));
    final textB = tester.getTopLeft(find.text('B'));

    expect(textB.dx - textA.dx, equals(20.0));
  });
}
