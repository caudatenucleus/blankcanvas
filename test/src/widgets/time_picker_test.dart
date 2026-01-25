import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' as m;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('TimePicker updates hours and minutes', (
    WidgetTester tester,
  ) async {
    const initialTime = TimeOfDay(hour: 10, minute: 30);
    // ignore: unused_local_variable
    TimeOfDay? newTime;

    await tester.pumpWidget(
      m.MaterialApp(
        home: m.Scaffold(
          body: m.Center(
            child: TimePicker(
              initialTime: initialTime,
              onTimeChanged: (t) => newTime = t,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final renderTimePicker = tester.renderObject<RenderTimePicker>(
      find.byType(TimePicker),
    );
    expect(renderTimePicker.time.hour, 10);
    expect(renderTimePicker.time.minute, 30);
  });
}
