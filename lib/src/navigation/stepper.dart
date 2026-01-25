import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';
import '../controls/buttons/button.dart';
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';

/// A step in the stepper.
class Step {
  const Step({
    required this.title,
    required this.content,
    this.subtitle,
    this.isActive = false,
    this.state = StepState.indexed,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget content;
  final bool isActive;
  final StepState state;
}

enum StepState { indexed, editing, complete, disabled, error }

enum StepperPart { title, subtitle, content, continueButton, cancelButton }

/// A Stepper widget.
class Stepper extends MultiChildRenderObjectWidget {
  Stepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.tag,
  }) : super(
         children: _buildChildren(
           steps,
           currentStep,
           onStepContinue,
           onStepCancel,
         ),
       );

  final List<Step> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;
  final String? tag;

  static List<Widget> _buildChildren(
    List<Step> steps,
    int currentStep,
    VoidCallback? onStepContinue,
    VoidCallback? onStepCancel,
  ) {
    final List<Widget> children = [];
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];

      // Title
      children.add(
        StepperSlot(index: i, part: StepperPart.title, child: step.title),
      );

      // Subtitle
      if (step.subtitle != null) {
        children.add(
          StepperSlot(
            index: i,
            part: StepperPart.subtitle,
            child: step.subtitle!,
          ),
        );
      }

      // Content (Always add if active? Or only current/active?)
      // Original logic: `if (i == currentStep || step.isActive)`
      if (i == currentStep || step.isActive) {
        children.add(
          StepperSlot(index: i, part: StepperPart.content, child: step.content),
        );

        // Buttons
        children.add(
          StepperSlot(
            index: i,
            part: StepperPart.continueButton,
            child: Button(
              onPressed: onStepContinue,
              child: const ParagraphPrimitive(
                text: TextSpan(
                  text: "Continue",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        );

        children.add(
          StepperSlot(
            index: i,
            part: StepperPart.cancelButton,
            child: Button(
              onPressed: onStepCancel,
              child: const ParagraphPrimitive(
                text: TextSpan(text: "Cancel", style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        );
      }
    }
    return children;
  }

  @override
  RenderStepper createRenderObject(BuildContext context) {
    return RenderStepper(
      steps: steps,
      currentStep: currentStep,
      customization:
          CustomizedTheme.of(context).getStepper(tag) ??
          StepperCustomization.simple(),
      onStepTapped: onStepTapped,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStepper renderObject) {
    renderObject
      ..steps = steps
      ..currentStep = currentStep
      ..customization =
          CustomizedTheme.of(context).getStepper(tag) ??
          StepperCustomization.simple()
      ..onStepTapped = onStepTapped;
  }
}

class StepperParentData extends ContainerBoxParentData<RenderBox> {
  int stepIndex = 0;
  StepperPart part = StepperPart.title;
}

class StepperSlot extends ParentDataWidget<StepperParentData> {
  const StepperSlot({
    super.key,
    required this.index,
    required this.part,
    required super.child,
  });

  final int index;
  final StepperPart part;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! StepperParentData) {
      renderObject.parentData = StepperParentData();
    }
    final pd = renderObject.parentData as StepperParentData;
    bool needsLayout = false;
    if (pd.stepIndex != index) {
      pd.stepIndex = index;
      needsLayout = true;
    }
    if (pd.part != part) {
      pd.part = part;
      needsLayout = true;
    }
    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Stepper;
}

class RenderStepper extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StepperParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StepperParentData> {
  RenderStepper({
    required List<Step> steps,
    required int currentStep,
    required StepperCustomization customization,
    this.onStepTapped,
  }) : _steps = steps,
       _currentStep = currentStep,
       _customization = customization;

  List<Step> _steps;
  set steps(List<Step> value) {
    _steps = value;
    markNeedsLayout();
  }

  int _currentStep;
  set currentStep(int value) {
    if (_currentStep == value) return;
    _currentStep = value;
    markNeedsLayout();
  }

  StepperCustomization _customization;
  StepperCustomization get customization => _customization;
  set customization(StepperCustomization value) {
    _customization = value;
    markNeedsPaint();
  }

  ValueChanged<int>? onStepTapped;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! StepperParentData) {
      child.parentData = StepperParentData();
    }
  }

  @override
  void performLayout() {
    final double gutterWidth = 48.0;
    final double contentX = gutterWidth + 12.0;
    double currentY = 0;

    // Group children by index/part
    // Or just iterate linear if they are in order?
    // MultiChildRenderObjectWidget children order is preserved.
    // _buildChildren produces order: [Step0Title, Step0Sub?, Step0Content?, Step0Btns?, Step1Title...]

    // We can iterate children and track current step index.

    RenderBox? child = firstChild;

    int lastStepIndex = -1;

    while (child != null) {
      final StepperParentData pd = child.parentData! as StepperParentData;

      // If new step
      if (pd.stepIndex != lastStepIndex) {
        if (lastStepIndex != -1) {
          currentY += 16; // Gap between steps
        }
        lastStepIndex = pd.stepIndex;
      }

      final BoxConstraints innerC = constraints
          .deflate(EdgeInsets.only(left: contentX))
          .copyWith(minHeight: 0);

      if (pd.part == StepperPart.title) {
        child.layout(innerC, parentUsesSize: true);
        pd.offset = Offset(
          contentX,
          currentY,
        ); // Centered vertically with indicator?
        // Indicator is at currentY + 8?
        // Title usually aligns with indicator.
        // Let's say indicator is 24px diameter (radius 12). Center at Y+12?
        // Title height?
        // We'll align Title top to currentY.

        // If we want indicator to center on Title:
        // indicatorY = currentY + child.size.height / 2 - 12.
        // But we assume fixed layout for now: currentY + 8 for indicator top?
        // Let's stick to simple flow.

        currentY += child.size.height;
      } else if (pd.part == StepperPart.subtitle) {
        child.layout(innerC, parentUsesSize: true);
        pd.offset = Offset(contentX, currentY);
        currentY += child.size.height;
      } else if (pd.part == StepperPart.content) {
        currentY += 16; // Gap before content

        child.layout(innerC, parentUsesSize: true);
        pd.offset = Offset(contentX, currentY);
        currentY += child.size.height + 16; // Gap after content
      } else if (pd.part == StepperPart.continueButton) {
        // Continue button.
        // Should be in a row with Cancel.
        // We can layout Continue, then Cancel next to it.
        child.layout(
          BoxConstraints.loose(innerC.biggest),
          parentUsesSize: true,
        );
        pd.offset = Offset(contentX, currentY);

        // Don't advance Y yet, wait for Cancel.
      } else if (pd.part == StepperPart.cancelButton) {
        // Cancel button.
        // Find Continue button (previous child) to place next to it.
        final RenderBox? continueBtn = childBefore(child);
        // Safety check
        double offsetX = contentX;
        if (continueBtn != null) {
          final StepperParentData prevPd =
              continueBtn.parentData as StepperParentData;
          if (prevPd.part == StepperPart.continueButton &&
              prevPd.stepIndex == pd.stepIndex) {
            offsetX += continueBtn.size.width + 8;
          }
        }

        child.layout(
          BoxConstraints.loose(innerC.biggest),
          parentUsesSize: true,
        );
        pd.offset = Offset(offsetX, currentY);

        // Now advance Y based on max height of buttons
        double h = child.size.height;
        if (continueBtn != null) h = math.max(h, continueBtn.size.height);
        currentY +=
            h; // No extra gap after buttons, next step gap added at start handled above
      }

      child = childAfter(child);
    }

    size = constraints.constrain(Size(constraints.maxWidth, currentY));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    const double indicatorX = 24.0;

    // We need to paint indicators.
    // We iterate steps. We need to find the "Title" child for each step to determine Y position.

    final Map<int, RenderBox> titleChildren = {};
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as StepperParentData;
      if (pd.part == StepperPart.title) {
        titleChildren[pd.stepIndex] = child;
      }
      child = childAfter(child);
    }

    for (int i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      final RenderBox? title = titleChildren[i];
      if (title == null) continue;

      final StepperParentData titlePd = title.parentData as StepperParentData;

      // Indicator Center Y
      // Align with Title center? Or top + offset?
      // Let's use top + 12 (assuming line height ~24).
      // pd.offset is relative to this RenderBox (0,0).
      final double indicatorCenterY = titlePd.offset.dy + title.size.height / 2;
      final Offset indicatorCenter =
          offset + Offset(indicatorX, indicatorCenterY);

      final isCompleted = i < _currentStep || step.state == StepState.complete;
      final isActive = i == _currentStep || step.isActive;
      final isLast = i == _steps.length - 1;

      final status = StepControlStatus();
      status.active = isActive ? 1.0 : 0.0;
      status.completed = isCompleted ? 1.0 : 0.0;
      status.enabled = step.state != StepState.disabled ? 1.0 : 0.0;

      // Connector
      if (!isLast) {
        final RenderBox? nextTitle = titleChildren[i + 1];
        if (nextTitle != null) {
          final StepperParentData nextTitlePd =
              nextTitle.parentData as StepperParentData;
          final double nextIndicatorY =
              nextTitlePd.offset.dy + nextTitle.size.height / 2;

          final Paint connectorPaint = Paint()
            ..color = customization.connectorColor ?? const Color(0xFFE0E0E0)
            ..strokeWidth = 2;

          context.canvas.drawLine(
            indicatorCenter + const Offset(0, 12),
            Offset(offset.dx + indicatorX, offset.dy + nextIndicatorY - 12),
            connectorPaint,
          );
        }
      }

      // Indicator
      final decoration = customization.decoration(status);
      if (decoration is BoxDecoration) {
        final Paint paint = Paint()
          ..color = decoration.color ?? const Color(0xFFE0E0E0);
        if (decoration.shape == BoxShape.circle) {
          context.canvas.drawCircle(indicatorCenter, 12, paint);
        } else {
          context.canvas.drawRect(
            Rect.fromCircle(center: indicatorCenter, radius: 12),
            paint,
          );
        }
      }

      // Number/Check
      final textStyle = customization.textStyle(status);
      final String textStr = isCompleted ? "✓" : "${i + 1}";
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: textStr,
          style: textStyle.copyWith(
            color: const Color(0xFFFFFFFF),
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        context.canvas,
        indicatorCenter - (textPainter.size / 2).getOffset(),
      );
    }

    defaultPaint(context, offset);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      // Hit test indicators for tapping
      final Map<int, RenderBox> titleChildren = {};
      RenderBox? child = firstChild;
      while (child != null) {
        final pd = child.parentData as StepperParentData;
        if (pd.part == StepperPart.title) {
          titleChildren[pd.stepIndex] = child;
        }
        child = childAfter(child);
      }

      for (int i = 0; i < _steps.length; i++) {
        final RenderBox? title = titleChildren[i];
        if (title != null) {
          final StepperParentData pd = title.parentData as StepperParentData;
          // Define hit area for the header row
          // From x=0 to width? Or just indicator + title?
          final Rect headerRect = Rect.fromLTWH(
            0,
            pd.offset.dy,
            size.width,
            title.size.height,
          );
          if (headerRect.contains(event.localPosition)) {
            onStepTapped?.call(i);
            return;
          }
        }
      }
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

extension on Size {
  Offset getOffset() => Offset(width, height);
}
