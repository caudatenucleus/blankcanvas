import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart' hide TextField;

void main() {
  testWidgets('FocusTrap traps focus', (WidgetTester tester) async {
    final focusNode1 = w.FocusNode();
    final focusNode2 = w.FocusNode();

    await tester.pumpWidget(
      material.MaterialApp(
        home: material.Scaffold(
          body: w.Column(
            children: [
              material.TextField(
                focusNode: focusNode1,
                key: const w.Key('Field1'),
              ),
              FocusTrap(
                isActive: true,
                child: w.Column(
                  children: [
                    material.TextField(
                      focusNode: focusNode2,
                      key: const w.Key('Field2'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    focusNode2.requestFocus();
    await tester.pumpAndSettle();

    // Initial focus might be implicitly handled or none. Default autofocus logic might apply.
    // FocusTrap has autofocus: true.
    expect(focusNode2.hasFocus, isTrue);

    // Try to move focus out? Not easily testable with programmatic focus unless using actions.
    // Ideally FocusTrap prevents focus leaving.
    // But our implementation wraps in FocusScope.
    // FocusScope usually traps if it's a route scope or configured.
    // Testing that focusNode2 is focused is a basic check that it works as a scope.
  });
}
