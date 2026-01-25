import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Skeleton renders and animates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(child: Skeleton(width: 100, height: 20)),
      ),
    );

    // Initial state
    expect(find.byType(Skeleton), findsOneWidget);
    final renderSkeleton = tester.renderObject<RenderSkeleton>(
      find.byType(Skeleton),
    );
    expect(renderSkeleton.size.width, 100);
    expect(renderSkeleton.size.height, 20);

    // w.Animation check requires pumping frames
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // As long as no error is thrown during animation, it passes basic check.
    // Visual verification is hard in unit test without golden (headless).
  });
}
