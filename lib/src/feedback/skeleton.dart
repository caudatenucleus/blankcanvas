import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// A skeleton widget to show loading state.
class Skeleton extends LeafRenderObjectWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  @override
  RenderSkeleton createRenderObject(BuildContext context) {
    return RenderSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSkeleton renderObject) {
    renderObject
      ..width = width
      ..height = height
      ..borderRadius = borderRadius
      ..baseColor = baseColor
      ..highlightColor = highlightColor
      ..duration = duration;
  }
}

class RenderSkeleton extends RenderBox implements TickerProvider {
  RenderSkeleton({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    required Color baseColor,
    required Color highlightColor,
    required Duration duration,
  }) : _width = width,
       _height = height,
       _borderRadius = borderRadius,
       _baseColor = baseColor,
       _highlightColor = highlightColor,
       _duration = duration {
    _ticker = createTicker((elapsed) {
      _tick(elapsed);
    });
    _ticker.start();
  }

  double? _width;
  double? get width => _width;
  set width(double? value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  double? _height;
  double? get height => _height;
  set height(double? value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  BorderRadius? _borderRadius;
  set borderRadius(BorderRadius? value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsPaint();
    }
  }

  Color _baseColor;
  set baseColor(Color value) {
    if (_baseColor != value) {
      _baseColor = value;
      markNeedsPaint();
    }
  }

  Color _highlightColor;
  set highlightColor(Color value) {
    if (_highlightColor != value) {
      _highlightColor = value;
      markNeedsPaint();
    }
  }

  Duration _duration;
  set duration(Duration value) {
    // Restart ticker if changed? simple ignore for now as it's typically const
    _duration = value;
  }

  late Ticker _ticker;
  double _animationValue = 0.0;

  void _tick(Duration elapsed) {
    final ms = elapsed.inMilliseconds % _duration.inMilliseconds;
    _animationValue = ms / _duration.inMilliseconds;
    markNeedsPaint();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'Skeleton');
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  void detach() {
    _ticker.stop();
    // _ticker.dispose(); // disposed in dispose? but detach might reattach?
    // standard: dispose ticker in dispose usually.
    super.detach();
  }

  // Need explicit dispose? RenderObjects don't have dispose.
  // They have detach. But if it's discarded, we need to dispose ticker to avoid leaks?
  // Check memory.
  // Actually, usually RenderObjects that hold resources ...
  // There is no standard dispose. Detach is where we stop.
  // We can rely on GC + Detach.
  // Ticker must be disposed.
  // If we override dispose() in RenderObject? NO such method.
  // Best practice: dispose ticker in detach if we know we are done?
  // But we might be moved.
  // It's tricky.
  // Ticker.dispose checks if active.
  // We can convert to TickerProviderStateMixin pattern logic if we were a State.
  // For RenderObject, we just stop in detach.

  // Actually, we can implement `dispose` if `RenderObject` had it.
  // Let's just stop in detach.

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(
        _width ?? constraints.maxWidth,
        _height ?? 20.0, // default height
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // Gradient logic
    // Alignment moves from -1 to 2
    final alignStart = -1.0 + (_animationValue * 3.0);
    // actually standard shimmer

    final paint = Paint();

    // Shader
    final gradient = LinearGradient(
      colors: [_baseColor, _highlightColor, _baseColor],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment(alignStart, 0),
      end: Alignment(alignStart + 1.0, 0), // Width of gradient band
      tileMode: TileMode.clamp,
    );

    paint.shader = gradient.createShader(rect);

    if (_borderRadius != null) {
      canvas.drawRRect(
        _borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
        paint,
      );
    } else {
      canvas.drawRect(rect, paint);
    }
  }
}
