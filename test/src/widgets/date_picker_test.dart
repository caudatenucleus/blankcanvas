import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('DatePicker renders and lays out', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: DatePicker(
          selectedDate: DateTime(2023, 1, 1),
          firstDate: DateTime(2020, 1, 1),
          lastDate: DateTime(2030, 12, 31),
          onChanged: (d) {},
        ),
      ),
    );

    final finder = find.byType(DatePicker);
    expect(finder, findsOneWidget);

    // Check RenderObject
    final w.RenderBox renderObject = tester.renderObject(finder);
    expect(renderObject.hasSize, true);
    // Should be at least 300x300 roughly
    expect(renderObject.size.width, greaterThan(100));
    expect(renderObject.size.height, greaterThan(100));
  });
}
