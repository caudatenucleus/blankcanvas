import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' as m;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('DragAndDropZone accepts drop', (WidgetTester tester) async {
    bool dropped = false;

    await tester.pumpWidget(
      m.MaterialApp(
        home: m.Scaffold(
          body: m.Center(
            child: m.Column(
              mainAxisSize: m.MainAxisSize.min,
              children: [
                DraggableItem<String>(
                  data: 'test',
                  feedback: const m.Material(
                    child: m.SizedBox(
                      width: 50,
                      height: 50,
                      child: m.Text('Dragging'),
                    ),
                  ),
                  child: const m.Text('Drag Me'),
                ),
                const m.SizedBox(height: 100),
                DragAndDropZone<String>(
                  onDrop: (data) => dropped = true,
                  builder: (context, candidate, rejected) {
                    return m.Container(
                      width: 100,
                      height: 100,
                      color: candidate
                          ? const m.Color(0xFF00FF00)
                          : const m.Color(0xFFCCCCCC),
                      child: const m.Text('Drop Here'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('Drag Me'), findsOneWidget);
    expect(find.text('Drop Here'), findsOneWidget);

    final dragTarget = find.text('Drag Me');

    // Drag
    final gesture = await tester.startGesture(tester.getCenter(dragTarget));
    await gesture.moveBy(const m.Offset(0, 150)); // Move down to drop zone
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(dropped, isTrue);
  });
}
