import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

import '../foundation/status.dart';

import '../theme/customization.dart';
import '../theme/theme.dart';
import 'button.dart';

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

/// A Stepper widget.
class Stepper extends StatefulWidget {
  const Stepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.tag,
  });

  final List<Step> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;
  final String? tag;

  @override
  State<Stepper> createState() => _StepperState();
}

class _StepperState extends State<Stepper> {
  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getStepper(widget.tag) ?? StepperCustomization.simple();

    return _StepperRenderWidget(
      steps: widget.steps,
      currentStep: widget.currentStep,
      customization: customization,
      onStepTapped: widget.onStepTapped,
      onStepContinue: widget.onStepContinue,
      onStepCancel: widget.onStepCancel,
    );
  }
}

class _StepperRenderWidget extends MultiChildRenderObjectWidget {
  _StepperRenderWidget({
    required this.steps,
    required this.currentStep,
    required this.customization,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
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
  final StepperCustomization customization;
  final ValueChanged<int>? onStepTapped;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;

  static List<Widget> _buildChildren(
    List<Step> steps,
    int currentStep,
    VoidCallback? onStepContinue,
    VoidCallback? onStepCancel,
  ) {
    final List<Widget> children = [];
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      // Header (Title + Subtitle)
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle(
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF000000),
              ),
              child: step.title,
            ),
            if (step.subtitle != null)
              DefaultTextStyle(
                style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                child: step.subtitle!,
              ),
          ],
        ),
      );
      // Content (only if active)
      if (i == currentStep || step.isActive) {
        children.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              step.content,
              const SizedBox(height: 16),
              Row(
                children: [
                  Button(
                    onPressed: onStepContinue,
                    child: const Text("Continue"),
                  ),
                  const SizedBox(width: 8),
                  Button(onPressed: onStepCancel, child: const Text("Cancel")),
                ],
              ),
            ],
          ),
        );
      } else {
        children.add(const SizedBox.shrink());
      }
    }
    return children;
  }

  @override
  RenderStepper createRenderObject(BuildContext context) {
    return RenderStepper(
      steps: steps,
      currentStep: currentStep,
      customization: customization,
      onStepTapped: onStepTapped,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderStepper renderObject,
  ) {
    renderObject
      ..steps = steps
      ..currentStep = currentStep
      ..customization = customization
      ..onStepTapped = onStepTapped;
  }
}

class StepperParentData extends ContainerBoxParentData<RenderBox> {
  bool isHeader = false;
  int stepIndex = 0;
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
  List<Step> get steps => _steps;
  set steps(List<Step> value) {
    _steps = value;
    markNeedsLayout();
  }

  int _currentStep;
  int get currentStep => _currentStep;
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
    double currentY = 0;

    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final int stepIndex = index ~/ 2;
      final bool isHeader = index % 2 == 0;
      final StepperParentData childParentData =
          child.parentData! as StepperParentData;
      childParentData.stepIndex = stepIndex;
      childParentData.isHeader = isHeader;

      if (isHeader) {
        child.layout(
          constraints.deflate(
            EdgeInsets.only(left: gutterWidth, top: currentY),
          ),
          parentUsesSize: true,
        );
        childParentData.offset = Offset(gutterWidth, currentY + 8);
        currentY += child.size.height + 16;
      } else {
        // Content
        child.layout(
          constraints.deflate(
            EdgeInsets.only(left: gutterWidth + 12, top: currentY),
          ),
          parentUsesSize: true,
        );
        childParentData.offset = Offset(gutterWidth + 12, currentY);
        if (child.size.height > 0) {
          currentY += child.size.height + 24;
        }
      }

      index++;
      child = childAfter(child);
    }

    size = constraints.constrain(Size(constraints.maxWidth, currentY));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    const double indicatorX = 24.0;

    // Draw indicators and connectors
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final isCompleted = i < currentStep || step.state == StepState.complete;
      final isActive = i == currentStep || step.isActive;
      final isLast = i == steps.length - 1;

      final status = StepControlStatus();
      status.active = isActive ? 1.0 : 0.0;
      status.completed = isCompleted ? 1.0 : 0.0;
      status.enabled = step.state != StepState.disabled ? 1.0 : 0.0;

      RenderBox? header = _getChild(i, true);
      if (header == null) continue;

      final StepperParentData headerPd =
          header.parentData! as StepperParentData;
      final Offset indicatorCenter =
          offset + Offset(indicatorX, headerPd.offset.dy + 8);
      final Rect indicatorRect = Rect.fromCircle(
        center: indicatorCenter,
        radius: 12,
      );

      // Connector line (before painting indicator)
      if (!isLast) {
        RenderBox? nextHeader = _getChild(i + 1, true);
        if (nextHeader != null) {
          final StepperParentData nextPd =
              nextHeader.parentData! as StepperParentData;
          final nextIndicatorY = offset.dy + nextPd.offset.dy + 8;
          final Paint connectorPaint = Paint()
            ..color = customization.connectorColor ?? const Color(0xFFE0E0E0)
            ..strokeWidth = 2;
          context.canvas.drawLine(
            indicatorCenter + const Offset(0, 12),
            Offset(offset.dx + indicatorX, nextIndicatorY - 12),
            connectorPaint,
          );
        }
      }

      // Paint indicator
      final decoration = customization.decoration(status);
      if (decoration is BoxDecoration) {
        final Paint paint = Paint()
          ..color = decoration.color ?? const Color(0xFFE0E0E0);
        if (decoration.shape == BoxShape.circle) {
          context.canvas.drawCircle(indicatorCenter, 12, paint);
        } else {
          context.canvas.drawRect(indicatorRect, paint);
        }
      }

      // Paint number/check
      final textStyle = customization.textStyle(status);
      final text = isCompleted ? "✓" : "${i + 1}";
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
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

  RenderBox? _getChild(int stepIndex, bool isHeader) {
    RenderBox? child = firstChild;
    while (child != null) {
      final StepperParentData pd = child.parentData! as StepperParentData;
      if (pd.stepIndex == stepIndex && pd.isHeader == isHeader) return child;
      child = childAfter(child);
    }
    return null;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      // Hit test headers/indicators
      for (int i = 0; i < steps.length; i++) {
        RenderBox? header = _getChild(i, true);
        if (header != null) {
          final StepperParentData pd = header.parentData! as StepperParentData;
          final Rect headerArea = Rect.fromLTRB(
            0,
            pd.offset.dy - 8,
            size.width,
            pd.offset.dy + header.size.height + 8,
          );
          if (headerArea.contains(event.localPosition)) {
            onStepTapped?.call(i);
            return;
          }
        }
      }
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

extension on Size {
  Offset getOffset() => Offset(width, height);
}
