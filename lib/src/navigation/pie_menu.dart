import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart'; // Needed for Widget class definition
import 'package:vector_math/vector_math_64.dart' as vector;

/// A circular menu that expands around a center trigger, implemented as a pure RenderObject.
class PieMenu extends MultiChildRenderObjectWidget {
  PieMenu({
    super.key,
    required Widget trigger,
    required List<Widget> actions,
    this.radius = 100.0,
    this.tag,
  }) : super(children: [trigger, ...actions]);

  final double radius;
  final String? tag;

  @override
  RenderPieMenu createRenderObject(BuildContext context) {
    return RenderPieMenu(radius: radius);
  }

  @override
  void updateRenderObject(BuildContext context, RenderPieMenu renderObject) {
    renderObject.radius = radius;
  }
}

class PieMenuParentData extends ContainerBoxParentData<RenderBox> {}

class RenderPieMenu extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, PieMenuParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, PieMenuParentData>
    implements TickerProvider {
  RenderPieMenu({required double radius}) : _radius = radius {
    _tap = TapGestureRecognizer()..onTap = _toggle;
  }

  double _radius;
  set radius(double value) {
    if (_radius != value) {
      _radius = value;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;

  AnimationController? _controller;
  bool _isOpen = false;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'PieMenuTicker');
  }

  void _toggle() {
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(markNeedsPaint);

    _isOpen = !_isOpen;
    if (_isOpen) {
      _controller!.forward();
    } else {
      _controller!.reverse();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! PieMenuParentData) {
      child.parentData = PieMenuParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? trigger = firstChild;
    if (trigger != null) {
      trigger.layout(constraints.loosen(), parentUsesSize: true);
      final PieMenuParentData pd = trigger.parentData as PieMenuParentData;

      size = constraints.biggest;

      pd.offset = Offset(
        (size.width - trigger.size.width) / 2,
        (size.height - trigger.size.height) / 2,
      );
    } else {
      size = constraints.biggest;
    }

    RenderBox? child = (trigger == null) ? null : childAfter(trigger);
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      child = childAfter(child);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double mountProgress = _controller?.value ?? 0.0;

    RenderBox? trigger = firstChild;
    if (trigger == null) return;

    final PieMenuParentData triggerPd = trigger.parentData as PieMenuParentData;
    final center =
        triggerPd.offset +
        Offset(trigger.size.width / 2, trigger.size.height / 2);

    if (mountProgress > 0) {
      int actionCount = childCount - 1;
      if (actionCount > 0) {
        final anglePerItem = 2 * math.pi / actionCount;

        RenderBox? child = childAfter(trigger);
        int i = 0;
        while (child != null) {
          final angle = i * anglePerItem - math.pi / 2;
          final targetDx = _radius * math.cos(angle);
          final targetDy = _radius * math.sin(angle);

          final currentDx = targetDx * mountProgress;
          final currentDy = targetDy * mountProgress;

          final childX = center.dx + currentDx - child.size.width / 2;
          final childY = center.dy + currentDy - child.size.height / 2;

          context.paintChild(child, offset + Offset(childX, childY));

          child = childAfter(child);
          i++;
        }
      }
    }

    context.paintChild(trigger, offset + triggerPd.offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? trigger = firstChild;
    if (trigger != null) {
      final PieMenuParentData pd = trigger.parentData as PieMenuParentData;
      final bool triggerHit = result.addWithPaintOffset(
        offset: pd.offset,
        position: position,
        hitTest: (result, transformed) =>
            trigger.hitTest(result, position: transformed),
      );
      if (triggerHit) return true;
    }

    final double mountProgress = _controller?.value ?? 0.0;
    if (mountProgress > 0.001) {
      RenderBox? trigger = firstChild;
      if (trigger == null) return false;
      final PieMenuParentData triggerPd =
          trigger.parentData as PieMenuParentData;
      final center =
          triggerPd.offset +
          Offset(trigger.size.width / 2, trigger.size.height / 2);

      int actionCount = childCount - 1;
      if (actionCount > 0) {
        final anglePerItem = 2 * math.pi / actionCount;

        RenderBox? child = lastChild;
        int i = actionCount - 1;

        while (child != trigger && child != null) {
          final angle = i * anglePerItem - math.pi / 2;
          final targetDx = _radius * math.cos(angle);
          final targetDy = _radius * math.sin(angle);

          final currentDx = targetDx * mountProgress;
          final currentDy = targetDy * mountProgress;

          final childX = center.dx + currentDx - child.size.width / 2;
          final childY = center.dy + currentDy - child.size.height / 2;

          final bool isHit = result.addWithPaintOffset(
            offset: Offset(childX, childY),
            position: position,
            hitTest: (result, transformed) =>
                child!.hitTest(result, position: transformed),
          );
          if (isHit) return true;

          child = (child.parentData as PieMenuParentData).previousSibling;
          i--;
        }
      }
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      RenderBox? trigger = firstChild;
      if (trigger != null) {
        // Fix for vector math compilation error: Vector2 vs Offset
        // entry.transform!.getTranslation() returns Vector3 (from vector_math, but flutter uses it).
        // Actually checking if transform is available.

        Offset localPos = event.localPosition;

        if (entry.transform != null) {
          final t = entry.transform!; // Matrix4
          // Invert to get render object local
          final det = t.determinant();
          if (det != 0) {
            final inverse = Matrix4.copy(t)..invert();
            final v = vector.Vector3(event.position.dx, event.position.dy, 0);
            final res = inverse.transformed3(v);
            localPos = Offset(res.x, res.y);
          }
        }

        if (_isPointInTrigger(localPos)) {
          _tap.addPointer(event);
        }
      }
    }
  }

  bool _isPointInTrigger(Offset localPoint) {
    RenderBox? trigger = firstChild;
    if (trigger != null) {
      final PieMenuParentData pd = trigger.parentData as PieMenuParentData;
      final Rect triggerRect = pd.offset & trigger.size;
      return triggerRect.contains(localPoint);
    }
    return false;
  }

  @override
  void detach() {
    _controller?.dispose();
    _tap.dispose();
    super.detach();
  }
}
