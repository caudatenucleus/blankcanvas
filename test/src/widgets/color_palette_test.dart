import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('ColorPalette renders', (WidgetTester tester) async {
    w.Color selected = const w.Color(0xFF000000);
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: ColorPalette(
          colors: const [w.Color(0xFF000000), w.Color(0xFFFFFFFF)],
          selectedColor: selected,
          onColorChanged: (c) => selected = c,
        ),
      ),
    );

    expect(find.byType(ColorPalette), findsOneWidget);
  });
}
