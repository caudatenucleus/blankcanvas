import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('QuickActions renders actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: QuickActions(
          actions: [
            QuickActionItem(
              label: 'Copy',
              icon: w.IconData(0xe14d, fontFamily: 'MaterialIcons'),
            ),
            QuickActionItem(
              label: 'Paste',
              icon: w.IconData(0xe14f, fontFamily: 'MaterialIcons'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Paste'), findsOneWidget);
  });
}
