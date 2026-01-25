import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/foundation/control_status.dart';

/// A lowest-level widget that animates a decoration using a provided animation.
class AnimatedDecorationPrimitive extends SingleChildRenderObjectWidget {
  const AnimatedDecorationPrimitive({
    super.key,
    required this.decoration,
    super.child,
  });

  /// The animation that provides the current decoration.
  final Animation<Decoration> decoration;

  @override
  RenderAnimatedDecorationPrimitive createRenderObject(BuildContext context) {
    return RenderAnimatedDecorationPrimitive(decoration: decoration);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAnimatedDecorationPrimitive renderObject,
  ) {
    renderObject.decoration = decoration;
  }
}

class RenderAnimatedDecorationPrimitive extends RenderProxyBox {
  RenderAnimatedDecorationPrimitive({
    required Animation<Decoration> decoration,
    RenderBox? child,
  }) : _decoration = decoration,
       super(child);

  Animation<Decoration> _decoration;
  set decoration(Animation<Decoration> value) {
    if (_decoration == value) return;
    if (attached) _decoration.removeListener(_handleDecorationChange);
    _decoration = value;
    if (attached) _decoration.addListener(_handleDecorationChange);
    _handleDecorationChange();
  }

  BoxPainter? _painter;
  Decoration? _currentDecoration;

  void _handleDecorationChange() {
    final newDecoration = _decoration.value;
    if (newDecoration != _currentDecoration) {
      _currentDecoration = newDecoration;
      _painter?.dispose();
      _painter = _currentDecoration!.createBoxPainter(markNeedsPaint);
      markNeedsPaint();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _decoration.addListener(_handleDecorationChange);
    _handleDecorationChange();
  }

  @override
  void detach() {
    _decoration.removeListener(_handleDecorationChange);
    _painter?.dispose();
    _painter = null;
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_painter != null) {
      _painter!.paint(context.canvas, offset, configuration);
    }
    super.paint(context, offset);
  }

  // Configuration for the painter
  ImageConfiguration get configuration => ImageConfiguration(
    size: size,
    devicePixelRatio: 1.0, // Should come from context if possible
  );

  @override
  void performLayout() {
    super.performLayout();
  }
}

/// A Decoration that computes colors based on status.
/// Now intended to be driven by an external Animation if transition is needed.
class StatusBoxDecoration extends Decoration {
  const StatusBoxDecoration({
    required this.status,
    required this.enabledColor,
    required this.disabledColor,
    this.focusedBorderColor,
    this.hoveredColor,
    this.activeColor,
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 1.0,
  });

  final ControlStatus status;
  final Color enabledColor;
  final Color disabledColor;
  final Color? focusedBorderColor;
  final Color? hoveredColor;
  final Color? activeColor;
  final BorderRadius borderRadius;
  final double borderWidth;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _StatusBoxPainter(this);
  }

  Color get _backgroundColor {
    final baseColor = Color.lerp(disabledColor, enabledColor, status.enabled)!;
    Color result = baseColor;

    if (hoveredColor != null) {
      result = Color.lerp(result, hoveredColor!, status.hovered)!;
    }
    if (activeColor != null) {
      result = Color.lerp(result, activeColor!, status.active)!;
    }

    return result;
  }

  Color? get _borderColor {
    if (focusedBorderColor == null) return null;
    return Color.lerp(
      const Color(0x00000000),
      focusedBorderColor!,
      status.focused,
    );
  }

  @override
  StatusBoxDecoration lerpTo(Decoration? b, double t) {
    if (b is StatusBoxDecoration) {
      return StatusBoxDecoration(
        status: status.lerpTo(b.status, t),
        enabledColor: Color.lerp(enabledColor, b.enabledColor, t)!,
        disabledColor: Color.lerp(disabledColor, b.disabledColor, t)!,
        focusedBorderColor: Color.lerp(
          focusedBorderColor,
          b.focusedBorderColor,
          t,
        ),
        hoveredColor: Color.lerp(hoveredColor, b.hoveredColor, t),
        activeColor: Color.lerp(activeColor, b.activeColor, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
        borderWidth: t < 0.5 ? borderWidth : b.borderWidth,
      );
    }
    return this;
  }
}

class _StatusBoxPainter extends BoxPainter {
  _StatusBoxPainter(this._decoration);

  final StatusBoxDecoration _decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & (configuration.size ?? Size.zero);
    final rrect = _decoration.borderRadius.toRRect(rect);

    // Background
    final bgPaint = Paint()
      ..color = _decoration._backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Focus border
    final borderColor = _decoration._borderColor;
    if (borderColor != null && borderColor.a > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _decoration.borderWidth;
      canvas.drawRRect(rrect, borderPaint);
    }
  }
}
