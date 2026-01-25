import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('ProgressIndicator renders determinate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(
          child: w.SizedBox(width: 100, child: ProgressIndicator(value: 0.5)),
        ),
      ),
    );

    expect(find.byType(ProgressIndicator), findsOneWidget);
    // Visual check implied by lack of crash
  });

  testWidgets('ProgressIndicator renders indeterminate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(
          child: w.SizedBox(width: 100, child: ProgressIndicator(value: null)),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Advance time to verify animation doesn't crash
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
