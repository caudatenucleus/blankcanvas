import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('RichTextEditor renders toolbar and editor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.SizedBox(
          height: 300,
          child: RichTextEditor(
            initialValue: 'Hello World',
            onChanged: (val) {},
          ),
        ),
      ),
    );

    // Should find w.EditableText
    expect(find.byType(w.EditableText), findsOneWidget);

    // Should find toolbar icons (at least Bold, Italic, Underline by default)
    expect(find.byType(w.Icon), findsWidgets);
  });
}
