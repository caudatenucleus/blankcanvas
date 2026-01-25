import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('StickyFooter fills remaining space', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.DefaultTextStyle(
          style: const w.TextStyle(
            fontFamily: 'Roboto',
            color: w.Color(0xFF000000),
          ),
          child: w.CustomScrollView(
            slivers: [
              w.SliverToBoxAdapter(
                child: w.Container(
                  height: 100,
                  color: const w.Color(0xFFFF0000),
                  child: const w.Text('Content'),
                ),
              ),
              StickyFooter(child: const w.Text('Footer')),
            ],
          ),
        ),
      ),
    );

    // w.Viewport 600. Content 100. Footer should fill 500? And align bottom.
    // So footer text should be at bottom of screen.
    expect(find.text('Footer'), findsOneWidget);
  });

  testWidgets('StickyFooter appears after large content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.DefaultTextStyle(
          style: const w.TextStyle(
            fontFamily: 'Roboto',
            color: w.Color(0xFF000000),
          ),
          child: w.CustomScrollView(
            physics:
                const w.ClampingScrollPhysics(), // Simplify scrolling behavior
            slivers: [
              w.SliverToBoxAdapter(
                child: w.Container(
                  height: 1000,
                  color: const w.Color(0xFFFF0000),
                  child: const w.Text('Content'),
                ),
              ),
              StickyFooter(child: const w.Text('Footer')),
            ],
          ),
        ),
      ),
    );

    // Initially footer is offscreen (at 1000+)
    expect(find.text('Footer'), findsNothing);

    // Scroll to end
    await tester.drag(
      find.byType(w.CustomScrollView),
      const w.Offset(0, -600),
    ); // Scroll 600
    await tester.pump();

    // Should see footer now? Content ends at 1000. Scroll 600 means we see 600-1200.
    // Footer starts at 1000.
    expect(find.text('Footer'), findsOneWidget);
  });
}
