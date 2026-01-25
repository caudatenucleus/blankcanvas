import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Accordion renders panels and toggles expansion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Accordion(
          panels: [
            AccordionPanel(
              header: const w.Text('Header 1'),
              body: const w.Text('Body 1'),
            ),
            AccordionPanel(
              header: const w.Text('Header 2'),
              body: const w.Text('Body 2'),
            ),
          ],
        ),
      ),
    );

    // Initial state: collapsed
    expect(find.text('Header 1'), findsOneWidget);
    expect(find.text('Header 2'), findsOneWidget);

    // Body should be not visible or layout 0 size.
    // find.text finds widgets even if offscreen/0 size if they are in tree?
    // w.RenderBox logic: we layout body with size 0 if collapsed.
    // BUT we add them to children list, so they ARE in tree.
    // However, we can check HitTest? Or visual location?

    // Let's tap header 1
    await tester.tap(find.text('Header 1'));
    await tester.pumpAndSettle();

    // Now Body 1 should be visible/have size.
    final body1 = tester.renderObject(find.text('Body 1')) as w.RenderBox;
    expect(body1.size.height, greaterThan(0));

    // Body 2 should be collapsed
    final body2 = tester.renderObject(find.text('Body 2')) as w.RenderBox;
    expect(body2.size.height, 0); // We layout with tight(w.Size.zero)

    // Tap header 2 (single mode, should collapse 1)
    await tester.tap(find.text('Header 2'));
    await tester.pumpAndSettle();

    expect(body1.size.height, 0);
    expect(body2.size.height, greaterThan(0));
  });
}
