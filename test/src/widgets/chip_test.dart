import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Chip renders label and handles tap', (
    WidgetTester tester,
  ) async {
    bool selected = false;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.StatefulBuilder(
          builder: (context, setState) {
            return Chip(
              label: const w.Text('Chip'),
              selected: selected,
              onSelected: (val) => setState(() => selected = val),
            );
          },
        ),
      ),
    );

    expect(find.text('Chip'), findsOneWidget);

    await tester.tap(find.byType(Chip));
    await tester.pump();

    expect(selected, true);
  });
}
