import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('SmartStack positions children', (WidgetTester tester) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Align(
          alignment: w.Alignment.topLeft,
          child: w.SizedBox(
            width: 200,
            height: 200,
            child: SmartStack(
              children: [
                w.Container(
                  color: const w.Color(0xFFFF0000),
                ), // Fills or top-left? StackFit.loose by default
                P(right: 10, top: 10, child: w.Text('TopRight')),
                P.fill(child: w.Center(child: w.Text('CenterFill'))),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify text exists
    expect(find.text('TopRight'), findsOneWidget);
    expect(find.text('CenterFill'), findsOneWidget);

    // Verify positioning logic loosely by location
    final centerFinder = find.text('CenterFill');
    final centerPos = tester.getCenter(centerFinder);
    expect(centerPos, const w.Offset(100, 100)); // Should be in center of 200x200
  });
}
