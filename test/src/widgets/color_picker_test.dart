import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('ColorPicker renders and lays out', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: ColorPicker(
          colors: const [w.Color(0xFF000000), w.Color(0xFFFFFFFF)],
          selectedColor: const w.Color(0xFF000000),
          onChanged: (c) {},
        ),
      ),
    );

    final finder = find.byType(ColorPicker);
    expect(finder, findsOneWidget);

    // Check RenderObject
    final w.RenderBox renderObject = tester.renderObject(finder);
    expect(renderObject.hasSize, true);
  });
}
