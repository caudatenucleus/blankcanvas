import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('SearchField renders input, clear, and search buttons', (
    WidgetTester tester,
  ) async {
    final controller = w.TextEditingController();
    String? lastSearch;
    String? changedText;

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Center(
          child: w.SizedBox(
            width: 300,
            child: SearchField(
              controller: controller,
              placeholder: 'Type here',
              onChanged: (val) => changedText = val,
              onSearchPressed: () {
                lastSearch = controller.text;
              },
            ),
          ),
        ),
      ),
    );

    // Initial Render
    expect(find.byType(SearchField), findsOneWidget);
    // Should see placeholder if empty.

    // Type text
    // SearchField wraps TextField (RenderTextField).
    // tester.enterText works on w.EditableText.
    // Our RenderTextField might not work with tester.enterText automatically unless we use manual simulation
    // OR if we fixed RenderTextField to support generic input (unlikely yet).
    // In AutoComplete test I used manual `controller.text = ...`.

    // 1. Enter text via controller
    controller.text = 'Hello';
    // We need to notify SearchField to layout again (show Clear button).
    // RenderSearchField listens to controller changes.
    await tester.pump();

    // Clear button should be visible (layout size > 0).
    // RenderSearchField paints children.
    // We can tap the Clear button?
    // How to find it?
    // It's a Button widget in Slot 1.
    // find.text('✕') should find it.
    expect(find.text('✕'), findsOneWidget);

    // Tap Clear
    await tester.tap(find.text('✕'));
    await tester.pump();

    // Controller should be cleared.
    expect(controller.text, isEmpty);
    // onChanged called? Button onPressed does: controller.clear(); onChanged('');
    expect(changedText, isEmpty);

    // Set text again
    controller.text = 'World';
    await tester.pump();

    // Tap Search
    // find.text('🔍')
    expect(find.text('🔍'), findsOneWidget);
    await tester.tap(find.text('🔍'));

    expect(lastSearch, 'World');
  });
}
