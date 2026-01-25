import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:flutter/services.dart';
import 'package:blankcanvas/blankcanvas.dart';

class TestIntent extends w.Intent {
  const TestIntent();
}

class TestAction extends w.Action<TestIntent> {
  TestAction(this.onInvoke);
  final w.VoidCallback onInvoke;

  @override
  void invoke(TestIntent intent) {
    onInvoke();
  }
}

void main() {
  testWidgets('ShortcutsWrapper triggers action', (WidgetTester tester) async {
    bool invoked = false;
    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: ShortcutsWrapper(
          shortcuts: {
            w.SingleActivator(LogicalKeyboardKey.enter): const TestIntent(),
          },
          actions: {TestIntent: TestAction(() => invoked = true)},
          child: const w.Focus(autofocus: true, child: w.Text('Press Enter')),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(invoked, isTrue);
  });
}
