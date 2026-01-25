import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Slider renders and drags', (WidgetTester tester) async {
    double value = 0.5;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.StatefulBuilder(
          builder: (context, setState) {
            return w.Center(
              child: w.SizedBox(
                width: 200,
                child: Slider(
                  value: value,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (v) {
                    setState(() => value = v);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    // Initial state
    expect(value, 0.5);

    // Drag to 0.75
    final Finder slider = find.byType(Slider);
    final w.Offset center = tester.getCenter(slider);

    // Slider is 200 width. w.Center is at 0.5.
    // Move to 0.75 means moving right by 25% of 200 = 50px.

    await tester.dragFrom(center, const w.Offset(50, 0));
    await tester.pump();

    expect(value, closeTo(0.75, 0.05));
  });
}
