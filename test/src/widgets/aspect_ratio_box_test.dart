import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('AspectRatioBox respects ratio', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(
          child: w.SizedBox(
            width: 100,
            child: AspectRatioBox(
              aspectRatio: 2.0, // 2:1 ratio. Width 100 -> Height 50.
              child: w.Container(color: const w.Color(0xFFFF0000)),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(AspectRatioBox);
    final size = tester.getSize(finder);

    // Logic: w.AspectRatio expands to fit.
    // Parent w.SizedBox(width: 100) passes width=100.
    // w.AspectRatio should be 100x50.

    expect(size.width, equals(100.0));
    expect(size.height, equals(50.0));
  });
}
