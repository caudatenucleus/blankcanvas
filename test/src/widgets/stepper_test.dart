import 'package:flutter/widgets.dart' as w;
import 'package:flutter_test/flutter_test.dart';
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('Stepper renders steps and content', (WidgetTester tester) async {
    int currentStep = 0;

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: w.StatefulBuilder(
          builder: (context, setState) {
            return w.Center(
              child: w.SizedBox(
                width: 400,
                height: 600,
                child: Stepper(
                  currentStep: currentStep,
                  onStepTapped: (index) {
                    setState(() {
                      currentStep = index;
                    });
                  },
                  onStepContinue: () {
                    if (currentStep < 2) setState(() => currentStep++);
                  },
                  onStepCancel: () {
                    if (currentStep > 0) setState(() => currentStep--);
                  },
                  steps: [
                    Step(
                      title: const w.Text('Step 1'),
                      content: const w.Text('Content 1'),
                      isActive: currentStep == 0,
                    ),
                    Step(
                      title: const w.Text('Step 2'),
                      content: const w.Text('Content 2'),
                      isActive: currentStep == 1,
                    ),
                    Step(
                      title: const w.Text('Step 3'),
                      content: const w.Text('Content 3'),
                      isActive: currentStep == 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    // Check initial state
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('Step 3'), findsOneWidget);

    expect(find.text('Content 1'), findsOneWidget);
    // Content 2 and 3 should NOT be present (isActive = false) based on Stepper's logic (i == currentStep || isActive)
    expect(find.text('Content 2'), findsNothing);
    expect(find.text('Content 3'), findsNothing);

    // Tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(currentStep, 1);
    expect(
      find.text('Content 1'),
      findsNothing,
    ); // Step 1 displayed? Only if active?
    // Logic: if (i == currentStep || step.isActive)
    // Step 0: i=0 != 1. isActive=false (passed in builder).
    // So Content 1 should disappear.

    expect(find.text('Content 2'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(currentStep, 0);
    expect(find.text('Content 1'), findsOneWidget);

    // Tap Step 2 Header
    // We need to tap the header. Tests can find w.Text 'Step 2'.
    // RenderStepper handles taps on header area.
    // Tapping 'Step 2' text should propagate to RenderStepper's hit test if hitTestChildren returns true?
    // In RenderStepper, hitTestChildren returns defaultHitTestChildren.
    // w.Text widget is a child.
    // If I tap w.Text, the w.Text widget handles it? No, w.Text is not interactive.
    // The touch event bubbles up?
    // In w.RenderBox, if child returns true for hitTest, it claims it.
    // w.Text widget (RichText) returns true for hitTestSelf if onSelection is set etc? Usually false/true.
    // RenderParagraph returns true for hitTestSelf.
    // So the click is consumed by the child?
    // RenderStepper needs to intercept?
    // RenderStepper.handleEvent checks for PointerDown.
    // It hit tests manually against header rects.
    // If Child consumes it, RenderStepper.handleEvent still gets called?
    // `handleEvent` is called if `hitTest` returns true.
    // `hitTest` returns true if `hitTestChildren` returns true OR `hitTestSelf` returns true.
    // RenderStepper: hitTestSelf returns true.
    // So RenderStepper is in the hit path.
    // `handleEvent` is called.

    await tester.tap(find.text('Step 2'));
    await tester.pumpAndSettle();

    expect(currentStep, 1);
  });
}
