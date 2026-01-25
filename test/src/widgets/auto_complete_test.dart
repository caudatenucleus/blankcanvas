import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('AutoComplete renders and shows suggestions on typing', (
    WidgetTester tester,
  ) async {
    final controller = w.TextEditingController();
    String? selected;

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.Overlay(
          initialEntries: [
            w.OverlayEntry(
              builder: (context) => w.Center(
                child: w.SizedBox(
                  width: 300,
                  child: AutoComplete<String>(
                    controller: controller,
                    suggestions: ['Apple', 'Banana', 'Cherry'],
                    onSelected: (val) => selected = val,
                    itemBuilder: (item, highlighted) => w.SizedBox(
                      height: 40,
                      child: w.Text(
                        item,
                        style: w.TextStyle(
                          color: highlighted
                              ? w.Color(0xFFFF0000)
                              : w.Color(0xFF000000),
                        ),
                      ),
                    ),
                    placeholder: 'Type fruit...',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Initial state
    expect(find.byType(AutoComplete<String>), findsOneWidget);
    // Should find the RenderObject
    final renderObj = tester.renderObject(find.byType(AutoComplete<String>));
    expect(renderObj, isA<RenderAutoComplete>());
    expect((renderObj as RenderAutoComplete).controller, controller);

    // Simulate Input manually since tester.enterText expects w.EditableText widget
    // 1. w.Focus (optional for logic but good for state)
    // We can't access focusNode getter if we haven't updated the test file to match the updated code structure in memory?
    // The previous run updated text_field.dart.

    (renderObj).focusNode.requestFocus();
    await tester.pump();

    // 2. Simulate text change event
    controller.text = 'Ap';
    // Trigger the callback that RenderTextField would trigger on input
    renderObj.onChanged?.call('Ap');
    await tester.pump();

    // Expect w.Overlay
    // w.Overlay uses AutoCompleteList -> children -> w.Text
    // Wait, children are built via itemBuilder.
    // itemBuilder returns w.SizedBox(w.Text(item)).
    // So find.text('Apple') should work if the overlay is inserted.
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);

    // Tap item
    await tester.tap(find.text('Apple'));
    await tester.pump();

    expect(selected, 'Apple');
    expect(controller.text, 'Apple');
    expect(find.text('Apple'), findsNothing); // w.Overlay closed
  });
}
