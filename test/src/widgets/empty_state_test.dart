import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('EmptyState renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: EmptyState(
          title: 'No Data',
          description: 'Try reloading',
          action: w.Text('Reload'),
        ),
      ),
    );

    expect(find.text('No Data'), findsOneWidget);
    expect(find.text('Try reloading'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
  });
}
