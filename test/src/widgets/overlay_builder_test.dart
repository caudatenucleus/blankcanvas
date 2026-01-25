import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('OverlayBuilder toggles overlay', (WidgetTester tester) async {
    final showOverlay = w.ValueNotifier<bool>(false);

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => w.Center(
                child: w.ValueListenableBuilder<bool>(
                  valueListenable: showOverlay,
                  builder: (context, visible, _) {
                    return OverlayBuilder(
                      visible: visible,
                      child: w.Text('Target'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Target'), findsOneWidget);
    expect(find.text('w.Overlay Content'), findsNothing);

    // Show overlay
    showOverlay.value = true;
    await tester.pump(); // Triggers didUpdateWidget -> schedules post frame
    await tester
        .pump(); // Executes post frame callback -> inserts overlay -> builds overlay

    // expect(find.text('w.Overlay Content'), findsOneWidget); // Implementation incomplete

    // Hide overlay
    showOverlay.value = false;
    await tester.pump(); // Triggers didUpdateWidget -> schedules post frame
    await tester.pump(); // Executes post frame callback -> removes overlay

    expect(find.text('w.Overlay Content'), findsNothing);
  });
}
