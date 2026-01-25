import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('DataTable renders columns and rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: DataTable(
          columns: [
            DataColumn(label: w.Text('Col 1')),
            DataColumn(label: w.Text('Col 2')),
          ],
          rows: [
            DataRow(cells: [w.Text('Cell 1'), w.Text('Cell 2')]),
          ],
        ),
      ),
    );

    expect(find.text('Col 1'), findsOneWidget);
    expect(find.text('Cell 1'), findsOneWidget);
  });
}
