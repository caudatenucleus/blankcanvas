import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('CommandPalette renders and filters items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => CommandPalette(
                actions: [
                  CommandAction(id: '1', label: 'Open File', onExecute: null),
                  CommandAction(id: '2', label: 'Save File', onExecute: null),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Open File'), findsOneWidget);

    // Type query
    await tester.enterText(find.byType(w.EditableText), 'Save');
    await tester.pump();

    expect(find.text('Open File'), findsNothing);
    expect(find.text('Save File'), findsOneWidget);
  });
}
