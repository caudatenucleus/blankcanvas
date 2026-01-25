import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Carousel renders pages and indicators', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Carousel(children: const [w.Text('Page 1'), w.Text('Page 2')]),
      ),
    );

    expect(find.text('Page 1'), findsOneWidget);
    // Page 2 offscreen

    // Indicators (usually small circles?)
    // Implementation uses w.Row of Containers.
    // Let's find boxes with indicator decoration (Circle).
    // Or just find generic containers.
    // There should be 2 indicators.
    // The indicators are usually below content.

    // Drag to change page
    await tester.drag(find.text('Page 1'), const w.Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Page 2'), findsOneWidget);
  });
}
