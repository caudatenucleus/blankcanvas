import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Checkbox renders and toggles', (WidgetTester tester) async {
    bool value = false;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.StatefulBuilder(
          builder: (context, setState) {
            return Button(
              // Use something to layout? No, Checkbox is smaller.
              onPressed: null,
              child: Checkbox(
                value: value,
                onChanged: (v) {
                  setState(() => value = v);
                },
              ),
            );
          },
        ),
      ),
    );

    // Initial state
    expect(value, isFalse);

    // Tap
    await tester.tap(find.byType(Checkbox));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 200)); // Finish animation

    expect(value, isTrue);
  });
}
