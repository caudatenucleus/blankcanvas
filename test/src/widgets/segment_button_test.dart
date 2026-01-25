import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('SegmentedButton renders and handles selection', (
    WidgetTester tester,
  ) async {
    Set<int> selected = {1};

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.StatefulBuilder(
          builder: (context, setState) {
            return w.Center(
              child: SegmentedButton<int>(
                segments: const [
                  Segment(value: 1, label: w.Text('One')),
                  Segment(value: 2, label: w.Text('Two')),
                  Segment(value: 3, label: w.Text('Three')),
                ],
                selected: selected,
                onChanged: (val) {
                  setState(() => selected = val);
                },
              ),
            );
          },
        ),
      ),
    );

    expect(find.byType(SegmentedButton<int>), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);

    // Tap Two
    await tester.tap(find.text('Two'));
    await tester.pump();

    expect(selected, {2});

    // Tap Three
    await tester.tap(find.text('Three'));
    await tester.pump();
    expect(selected, {3});
  });

  testWidgets('SegmentedButton MultiSelect', (WidgetTester tester) async {
    Set<int> selected = {1};

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.StatefulBuilder(
          builder: (context, setState) {
            return w.Center(
              child: SegmentedButton<int>(
                multiSelect: true,
                segments: const [
                  Segment(value: 1, label: w.Text('A')),
                  Segment(value: 2, label: w.Text('B')),
                ],
                selected: selected,
                onChanged: (selection) => setState(() => selected = selection),
              ),
            );
          },
        ),
      ),
    );

    // Tap B
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(selected, {1, 2});

    // Tap A
    await tester.tap(find.text('A'));
    await tester.pump();
    expect(selected, {2});
  });
}
