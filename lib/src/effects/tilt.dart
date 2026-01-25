import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

/// A widget that tilts based on pointer position using lowest-level APIs.
class Tilt extends SingleChildRenderObjectWidget {
  const Tilt({
    super.key,
    required Widget child,
    this.maxTilt = 0.1,
    this.resetOnExit = true,
  }) : super(child: child);

  final double maxTilt;
  final bool resetOnExit;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTilt(maxTilt: maxTilt, resetOnExit: resetOnExit);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTilt renderObject) {
    renderObject
      ..maxTilt = maxTilt
      ..resetOnExit = resetOnExit;
  }
}

class RenderTilt extends RenderProxyBox {
  RenderTilt({required double maxTilt, required this.resetOnExit})
    : _maxTilt = maxTilt;

  double _rotationX = 0.0;
  double _rotationY = 0.0;

  double _maxTilt;
  double get maxTilt => _maxTilt;
  set maxTilt(double value) {
    if (_maxTilt == value) return;
    _maxTilt = value;
    markNeedsPaint();
  }

  bool resetOnExit;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent) {
      final normalizedX = (event.localPosition.dx / size.width) * 2 - 1;
      final normalizedY = (event.localPosition.dy / size.height) * 2 - 1;

      _rotationY = normalizedX * _maxTilt;
      _rotationX = -normalizedY * _maxTilt;
      markNeedsPaint();
    } else if (event is PointerExitEvent && resetOnExit) {
      _rotationX = 0.0;
      _rotationY = 0.0;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..translate(Vector3(size.width / 2, size.height / 2, 0.0))
      ..rotateX(_rotationX)
      ..rotateY(_rotationY)
      ..translate(Vector3(-size.width / 2, -size.height / 2, 0.0));

    context.pushTransform(needsCompositing, offset, transform, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    });
  }
}
