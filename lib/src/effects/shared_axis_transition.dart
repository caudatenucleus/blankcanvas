import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

enum SharedAxisType { x, y, z }

/// A pure RenderObject implementation of shared axis transition.
class SharedAxisTransition extends SingleChildRenderObjectWidget {
  const SharedAxisTransition({
    super.key,
    required Widget child,
    required this.animationValue,
    this.type = SharedAxisType.x,
  }) : super(child: child);

  final double animationValue; // 0.0 to 1.0
  final SharedAxisType type;

  @override
  RenderSharedAxis createRenderObject(BuildContext context) {
    return RenderSharedAxis(animationValue: animationValue, type: type);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSharedAxis renderObject) {
    renderObject
      ..animationValue = animationValue
      ..type = type;
  }
}

class RenderSharedAxis extends RenderProxyBox {
  RenderSharedAxis({
    required double animationValue,
    required SharedAxisType type,
    RenderBox? child,
  }) : _animationValue = animationValue,
       _type = type,
       super(child);

  double _animationValue;
  set animationValue(double value) {
    if (_animationValue != value) {
      _animationValue = value;
      markNeedsPaint();
    }
  }

  SharedAxisType _type;
  set type(SharedAxisType value) {
    if (_type != value) {
      _type = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    // Opacity
    final opacity = _animationValue.clamp(0.0, 1.0);

    // Transform
    final Matrix4 transform = Matrix4.identity();
    if (_type == SharedAxisType.x) {
      // Slide in from right (if entering) or whatever.
      // Let's assume 0->1 is Entering.
      // 0: Invisible, Offset 30.
      // 1: Visible, Offset 0.
      final dx = (1.0 - _animationValue) * 30.0;
      transform.translate(Vector3(dx, 0.0, 0.0));
    } else if (_type == SharedAxisType.y) {
      final dy = (1.0 - _animationValue) * 30.0;
      transform.translate(Vector3(0.0, dy, 0.0));
    } else if (_type == SharedAxisType.z) {
      final scale = 0.8 + (0.2 * _animationValue);
      // Scale from center
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      transform.translate(Vector3(centerX, centerY, 0.0));
      transform.scale(scale, scale, scale);
      transform.translate(Vector3(-centerX, -centerY, 0.0));
    }

    context.pushOpacity(offset, (opacity * 255).toInt(), (ctx, off) {
      ctx.pushTransform(needsCompositing, off, transform, (c, o) {
        c.paintChild(child!, o);
      });
    });
  }
}
