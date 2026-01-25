import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Statistic renders label and value', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Statistic(label: 'Active Users', value: '1,234'),
      ),
    );

    expect(find.text('Active Users'), findsOneWidget);
    expect(find.text('1,234'), findsOneWidget);
  });

  testWidgets('Statistic renders prefix and suffix', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Statistic(
          label: 'Revenue',
          value: '500',
          prefix: w.Text('\$'),
          suffix: w.Text('USD'),
        ),
      ),
    );

    expect(find.text('\$'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
  });
}
