import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

/// A dedicated loading spinner that paints directly to canvas.
class Spinner extends LeafRenderObjectWidget {
  const Spinner({
    super.key,
    this.color = const Color(0xFF2196F3),
    this.size = 24.0,
    this.strokeWidth = 3.0,
    this.percent,
  });

  final Color color;
  final double size;
  final double strokeWidth;

  /// If non-null, deterministic mode. If null, indeterminate (spinning).
  final double? percent;

  @override
  RenderSpinner createRenderObject(BuildContext context) {
    return RenderSpinner(
      color: color,
      size: size,
      strokeWidth: strokeWidth,
      percent: percent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSpinner renderObject) {
    renderObject
      ..color = color
      ..targetSize = size
      ..strokeWidth = strokeWidth
      ..percent = percent;
  }
}

class RenderSpinner extends RenderBox {
  RenderSpinner({
    required Color color,
    required double size,
    required double strokeWidth,
    double? percent,
  }) : _color = color,
       _targetSize = size,
       _strokeWidth = strokeWidth,
       _percent = percent {
    _ticker = Ticker(_onTick);
    if (_percent == null) _ticker.start();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_percent == null && !_ticker.isActive) _ticker.start();
  }

  @override
  void detach() {
    _ticker.stop();
    super.detach();
  }

  late Ticker _ticker;
  double _rotation = 0.0;

  void _onTick(Duration elapsed) {
    if (_percent != null) return;
    // 1 rotation per second
    _rotation = (elapsed.inMilliseconds % 1000) / 1000 * 2 * math.pi;
    markNeedsPaint();
  }

  Color _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  double _targetSize;
  set targetSize(double value) {
    if (_targetSize != value) {
      _targetSize = value;
      markNeedsLayout();
    }
  }

  double _strokeWidth;
  set strokeWidth(double value) {
    if (_strokeWidth != value) {
      _strokeWidth = value;
      markNeedsLayout(); // Might affect visual bounds if we were strict
      markNeedsPaint();
    }
  }

  double? _percent;
  set percent(double? value) {
    if (_percent != value) {
      bool wasIndeterminate = _percent == null;
      _percent = value;
      if (wasIndeterminate && value != null) {
        _ticker.stop();
      } else if (!wasIndeterminate && value == null) {
        _ticker.start();
      }
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(_targetSize, _targetSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final center = offset + Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - _strokeWidth) / 2;

    final Paint paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    if (_percent != null) {
      // Deterministic
      final sweepAngle = 2 * math.pi * _percent!.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start at top
        sweepAngle,
        false,
        paint,
      );
    } else {
      // Indeterminate spinning arc
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(_rotation);
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        0.0,
        math.pi * 1.5, // 3/4 circle
        false,
        paint,
      );
      canvas.restore();
    }
  }
}
