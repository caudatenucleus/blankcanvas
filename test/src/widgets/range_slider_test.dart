import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' as m;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('RangeSlider renders', (WidgetTester tester) async {
    RangeValues values = const RangeValues(0.2, 0.8);
    await tester.pumpWidget(
      m.Directionality(
        textDirection: m.TextDirection.ltr,
        child: RangeSlider(values: values, onChanged: (v) => values = v),
      ),
    );

    expect(find.byType(RangeSlider), findsOneWidget);
  });
}
