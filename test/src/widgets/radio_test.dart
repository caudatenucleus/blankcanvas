import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Radio renders and selects', (WidgetTester tester) async {
    int? groupValue = 1;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.StatefulBuilder(
          builder: (context, setState) {
            return w.Column(
              children: [
                Radio<int>(
                  value: 1,
                  groupValue: groupValue,
                  onChanged: (v) => setState(() => groupValue = v),
                ),
                Radio<int>(
                  value: 2,
                  groupValue: groupValue,
                  onChanged: (v) => setState(() => groupValue = v),
                ),
              ],
            );
          },
        ),
      ),
    );

    // Initial state
    expect(groupValue, 1);

    // Tap second radio
    await tester.tap(find.byType(Radio<int>).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(groupValue, 2);
  });
}
