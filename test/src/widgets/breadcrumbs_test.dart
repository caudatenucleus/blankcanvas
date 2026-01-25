import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Breadcrumbs renders items and handles tap', (
    WidgetTester tester,
  ) async {
    int? tapped;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Breadcrumbs(
          items: [w.Text('Home'), w.Text('Category')],
          onItemTapped: (i) => tapped = i,
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    // Separator text '/'
    expect(find.text(' / '), findsOneWidget);

    await tester.tap(find.text('Home'));
    expect(tapped, 0);
  });
}
