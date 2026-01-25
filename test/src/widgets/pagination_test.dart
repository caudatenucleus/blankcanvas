import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';
// verify path

void main() {
  testWidgets('Pagination renders and handles input', (
    WidgetTester tester,
  ) async {
    int page = 1;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Pagination(
          currentPage: 1,
          totalPages: 10,
          onPageChanged: (p) => page = p,
        ),
      ),
    );

    final finder = find.byType(Pagination);
    expect(finder, findsOneWidget);

    final RenderPagination renderObject = tester.renderObject(finder);
    expect(renderObject.currentPage, 1);
    expect(renderObject.totalPages, 10);

    // Layout: <, 1, 2, 3, ..., 10, >
    // Items: 7. Width: 7*32 + 6*4 = 248.
    // Next button index 6. X = 6 * (32+4) = 216.
    // w.Center of Next button: 216 + 16 = 232. Y = 16.

    final topLeft = tester.getTopLeft(finder);
    final nextBtnOffset = topLeft + const w.Offset(232, 16);

    // Tap Next
    await tester.tapAt(nextBtnOffset);
    await tester.pump(); // Process tap

    expect(page, 2);

    // Update widget
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: Pagination(
          currentPage: 2,
          totalPages: 10,
          onPageChanged: (p) => page = p,
        ),
      ),
    );
    expect(renderObject.currentPage, 2);
  });
}
