import 'package:flutter/widgets.dart'
    hide
        FadeTransition,
        ScaleTransition,
        SlideTransition,
        RotationTransition,
        SizeTransition;
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

/// A lowest-level opacity transition.
class OpacityTransition extends SingleChildRenderObjectWidget {
  const OpacityTransition({super.key, required this.opacity, super.child});

  final Animation<double> opacity;

  @override
  RenderOpacityTransition createRenderObject(BuildContext context) {
    return RenderOpacityTransition(opacity: opacity);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOpacityTransition renderObject,
  ) {
    renderObject.opacity = opacity;
  }
}

class RenderOpacityTransition extends RenderProxyBox {
  RenderOpacityTransition({
    required Animation<double> opacity,
    RenderBox? child,
  }) : _opacity = opacity,
       super(child);

  Animation<double> _opacity;
  set opacity(Animation<double> value) {
    if (_opacity == value) return;
    if (attached) _opacity.removeListener(markNeedsPaint);
    _opacity = value;
    if (attached) _opacity.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _opacity.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _opacity.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final double alpha = _opacity.value.clamp(0.0, 1.0);
    if (alpha <= 0) return;
    if (alpha >= 1.0) {
      context.paintChild(child!, offset);
      return;
    }
    context.pushOpacity(offset, (255 * alpha).round(), (context, offset) {
      context.paintChild(child!, offset);
    });
  }
}

/// A lowest-level scale transition.
class ScaleTransition extends SingleChildRenderObjectWidget {
  const ScaleTransition({
    super.key,
    required this.scale,
    this.alignment = Alignment.center,
    super.child,
  });

  final Animation<double> scale;
  final Alignment alignment;

  @override
  RenderScaleTransition createRenderObject(BuildContext context) {
    return RenderScaleTransition(scale: scale, alignment: alignment);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderScaleTransition renderObject,
  ) {
    renderObject
      ..scale = scale
      ..alignment = alignment;
  }
}

class RenderScaleTransition extends RenderProxyBox {
  RenderScaleTransition({
    required Animation<double> scale,
    Alignment alignment = Alignment.center,
    RenderBox? child,
  }) : _scale = scale,
       _alignment = alignment,
       super(child);

  Animation<double> _scale;
  set scale(Animation<double> value) {
    if (_scale == value) return;
    if (attached) _scale.removeListener(markNeedsPaint);
    _scale = value;
    if (attached) _scale.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  Alignment _alignment;
  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scale.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _scale.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final double s = _scale.value;
    final Offset childOffset = _alignment.alongSize(size);
    final Matrix4 transform = Matrix4.identity()
      ..translate(Vector3(childOffset.dx, childOffset.dy, 0.0))
      ..scale(Vector3(s, s, 1.0))
      ..translate(Vector3(-childOffset.dx, -childOffset.dy, 0.0));
    context.pushTransform(needsCompositing, offset, transform, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    });
  }
}

/// A lowest-level sliding transition using direct RenderObject transformation.
class SlidingTransition extends SingleChildRenderObjectWidget {
  const SlidingTransition({super.key, required this.position, super.child});

  /// The animation that drives the child's position.
  /// The Offset is relative to the child's size.
  final Animation<Offset> position;

  @override
  RenderSlidingTransition createRenderObject(BuildContext context) {
    return RenderSlidingTransition(position: position);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSlidingTransition renderObject,
  ) {
    renderObject.position = position;
  }
}

class RenderSlidingTransition extends RenderProxyBox {
  RenderSlidingTransition({
    required Animation<Offset> position,
    RenderBox? child,
  }) : _position = position,
       super(child);

  Animation<Offset> _position;
  set position(Animation<Offset> value) {
    if (_position == value) return;
    if (attached) _position.removeListener(markNeedsPaint);
    _position = value;
    if (attached) _position.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _position.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _position.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final Offset p = _position.value;
    final Matrix4 transform = Matrix4.translationValues(
      p.dx * size.width,
      p.dy * size.height,
      0.0,
    );
    context.pushTransform(needsCompositing, offset, transform, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    });
  }
}

/// A lowest-level rotation transition.
class RotationTransition extends SingleChildRenderObjectWidget {
  const RotationTransition({
    super.key,
    required this.turns,
    this.alignment = Alignment.center,
    super.child,
  });

  final Animation<double> turns;
  final Alignment alignment;

  @override
  RenderRotationTransition createRenderObject(BuildContext context) {
    return RenderRotationTransition(turns: turns, alignment: alignment);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderRotationTransition renderObject,
  ) {
    renderObject
      ..turns = turns
      ..alignment = alignment;
  }
}

class RenderRotationTransition extends RenderProxyBox {
  RenderRotationTransition({
    required Animation<double> turns,
    Alignment alignment = Alignment.center,
    RenderBox? child,
  }) : _turns = turns,
       _alignment = alignment,
       super(child);

  Animation<double> _turns;
  set turns(Animation<double> value) {
    if (_turns == value) return;
    if (attached) _turns.removeListener(markNeedsPaint);
    _turns = value;
    if (attached) _turns.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  Alignment _alignment;
  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _turns.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _turns.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final double t = _turns.value;
    final Offset childOffset = _alignment.alongSize(size);
    final Matrix4 transform = Matrix4.identity()
      ..translate(Vector3(childOffset.dx, childOffset.dy, 0.0))
      ..rotateZ(t * 2.0 * 3.1415926535897932)
      ..translate(Vector3(-childOffset.dx, -childOffset.dy, 0.0));
    context.pushTransform(needsCompositing, offset, transform, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    });
  }
}

/// A lowest-level size transition.
class SizeTransition extends SingleChildRenderObjectWidget {
  const SizeTransition({
    super.key,
    required this.sizeFactor,
    this.axis = Axis.vertical,
    this.axisAlignment = 0.0,
    super.child,
  });

  final Animation<double> sizeFactor;
  final Axis axis;
  final double axisAlignment;

  @override
  RenderSizeTransition createRenderObject(BuildContext context) {
    return RenderSizeTransition(
      sizeFactor: sizeFactor,
      axis: axis,
      axisAlignment: axisAlignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSizeTransition renderObject,
  ) {
    renderObject
      ..sizeFactor = sizeFactor
      ..axis = axis
      ..axisAlignment = axisAlignment;
  }
}

class RenderSizeTransition extends RenderProxyBox {
  RenderSizeTransition({
    required Animation<double> sizeFactor,
    Axis axis = Axis.vertical,
    double axisAlignment = 0.0,
    RenderBox? child,
  }) : _sizeFactor = sizeFactor,
       _axis = axis,
       _axisAlignment = axisAlignment,
       super(child);

  Animation<double> _sizeFactor;
  set sizeFactor(Animation<double> value) {
    if (_sizeFactor == value) return;
    if (attached) _sizeFactor.removeListener(markNeedsLayout);
    _sizeFactor = value;
    if (attached) _sizeFactor.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  Axis _axis;
  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsLayout();
  }

  double _axisAlignment;
  set axisAlignment(double value) {
    if (_axisAlignment == value) return;
    _axisAlignment = value;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _sizeFactor.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _sizeFactor.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      final double factor = _sizeFactor.value;
      if (_axis == Axis.vertical) {
        size = constraints.constrain(
          Size(child!.size.width, child!.size.height * factor),
        );
      } else {
        size = constraints.constrain(
          Size(child!.size.width * factor, child!.size.height),
        );
      }
    } else {
      size = constraints.smallest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
        context,
        offset,
      ) {
        double dx = 0.0;
        double dy = 0.0;
        if (_axis == Axis.vertical) {
          dy =
              (size.height - child!.size.height) * (_axisAlignment + 1.0) / 2.0;
        } else {
          dx = (size.width - child!.size.width) * (_axisAlignment + 1.0) / 2.0;
        }
        context.paintChild(child!, offset + Offset(dx, dy));
      });
    }
  }
}
