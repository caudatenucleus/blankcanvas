import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A 3D flip transition widget using lowest-level APIs.
class Flip extends MultiChildRenderObjectWidget {
  Flip({
    super.key,
    required this.isFront,
    required Widget front,
    required Widget back,
    this.duration = const Duration(milliseconds: 500),
    this.axis = Axis.horizontal,
  }) : super(children: [front, back]);

  final bool isFront;
  final Duration duration;
  final Axis axis;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlip(isFront: isFront, duration: duration, axis: axis);
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlip renderObject) {
    renderObject
      ..isFront = isFront
      ..duration = duration
      ..axis = axis;
  }
}

class FlipParentData extends ContainerBoxParentData<RenderBox> {}

class RenderFlip extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlipParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlipParentData> {
  RenderFlip({
    required bool isFront,
    required this.duration,
    required Axis axis,
  }) : _isFront = isFront,
       _axis = axis,
       _targetValue = isFront ? 0.0 : 1.0,
       _currentValue = isFront ? 0.0 : 1.0;

  Ticker? _ticker;
  double _currentValue;
  double _targetValue;
  DateTime? _animationStart;

  bool _isFront;
  bool get isFront => _isFront;
  set isFront(bool value) {
    if (_isFront == value) return;
    _isFront = value;
    _targetValue = value ? 0.0 : 1.0;
    _animationStart = DateTime.now();
    markNeedsPaint();
  }

  Duration duration;

  Axis _axis;
  Axis get axis => _axis;
  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlipParentData) {
      child.parentData = FlipParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _ticker = Ticker(_onTick);
    _ticker!.start();
  }

  @override
  void detach() {
    _ticker?.dispose();
    _ticker = null;
    super.detach();
  }

  void _onTick(Duration elapsed) {
    if (_animationStart == null) return;

    final elapsedMs = DateTime.now()
        .difference(_animationStart!)
        .inMilliseconds;
    final progress = (elapsedMs / duration.inMilliseconds).clamp(0.0, 1.0);

    if (_targetValue > _currentValue) {
      _currentValue = progress;
    } else {
      _currentValue = 1.0 - progress;
    }

    if (progress >= 1.0) {
      _currentValue = _targetValue;
      _animationStart = null;
    }

    markNeedsPaint();
  }

  @override
  void performLayout() {
    RenderBox? frontChild = firstChild;
    RenderBox? backChild = childAfter(frontChild!);

    Size childSize = Size.zero;

    frontChild.layout(constraints, parentUsesSize: true);
    childSize = frontChild.size;

    if (backChild != null) {
      backChild.layout(constraints, parentUsesSize: true);
      if (backChild.size.width > childSize.width) {
        childSize = Size(backChild.size.width, childSize.height);
      }
      if (backChild.size.height > childSize.height) {
        childSize = Size(childSize.width, backChild.size.height);
      }
    }

    size = constraints.constrain(childSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final angle = _currentValue * math.pi;
    final isUnder = _currentValue > 0.5;

    RenderBox? frontChild = firstChild;
    RenderBox? backChild = frontChild != null ? childAfter(frontChild) : null;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..translate(Vector3(size.width / 2, size.height / 2, 0.0));

    if (_axis == Axis.horizontal) {
      transform.rotateY(angle);
    } else {
      transform.rotateX(angle);
    }

    transform.translate(Vector3(-size.width / 2, -size.height / 2, 0.0));

    context.pushTransform(needsCompositing, offset, transform, (
      context,
      offset,
    ) {
      if (isUnder) {
        // Show back, but flip it again so it's not mirrored
        if (backChild != null) {
          final backTransform = Matrix4.identity()
            ..translate(Vector3(size.width / 2, size.height / 2, 0.0));
          if (_axis == Axis.horizontal) {
            backTransform.rotateY(math.pi);
          } else {
            backTransform.rotateX(math.pi);
          }
          backTransform.translate(
            Vector3(-size.width / 2, -size.height / 2, 0.0),
          );

          context.pushTransform(needsCompositing, offset, backTransform, (
            context,
            offset,
          ) {
            context.paintChild(backChild, offset);
          });
        }
      } else {
        if (frontChild != null) {
          context.paintChild(frontChild, offset);
        }
      }
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
