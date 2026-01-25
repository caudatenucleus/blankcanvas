import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Anchor navigates to section', (WidgetTester tester) async {
    final w.ScrollController controller = w.ScrollController();

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.SingleChildScrollView(
          controller: controller,
          child: w.Column(
            children: [
              Anchor(
                controller: controller,
                sectionId: 'section1',
                child: w.Text('Go to Section 1'),
              ),
              w.SizedBox(height: 1000), // Spacer
              AnchorTarget(id: 'section1', child: w.Text('Section 1 Content')),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go to Section 1'));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
  });
}
