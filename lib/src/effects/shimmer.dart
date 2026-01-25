import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A shimmer loading effect using lowest-level APIs.
class Shimmer extends SingleChildRenderObjectWidget {
  const Shimmer({
    super.key,
    required Widget child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
  }) : super(child: child);

  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final ShimmerDirection direction;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      direction: direction,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderShimmer renderObject) {
    renderObject
      ..baseColor = baseColor
      ..highlightColor = highlightColor
      ..duration = duration
      ..direction = direction;
  }
}

enum ShimmerDirection { ltr, rtl, ttb, btt }

class RenderShimmer extends RenderProxyBox {
  RenderShimmer({
    required Color baseColor,
    required Color highlightColor,
    required this.duration,
    required ShimmerDirection direction,
  }) : _baseColor = baseColor,
       _highlightColor = highlightColor,
       _direction = direction;

  Ticker? _ticker;
  double _progress = 0.0;

  Color _baseColor;
  Color get baseColor => _baseColor;
  set baseColor(Color value) {
    if (_baseColor == value) return;
    _baseColor = value;
    markNeedsPaint();
  }

  Color _highlightColor;
  Color get highlightColor => _highlightColor;
  set highlightColor(Color value) {
    if (_highlightColor == value) return;
    _highlightColor = value;
    markNeedsPaint();
  }

  Duration duration;

  ShimmerDirection _direction;
  ShimmerDirection get direction => _direction;
  set direction(ShimmerDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsPaint();
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
    final ms = elapsed.inMilliseconds % duration.inMilliseconds;
    _progress = ms / duration.inMilliseconds;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    // Create gradient based on direction and progress
    Offset begin;
    Offset end;

    switch (_direction) {
      case ShimmerDirection.ltr:
        begin = Offset(-1.0 + (_progress * 3), 0.0);
        end = Offset(_progress * 3, 0.0);
        break;
      case ShimmerDirection.rtl:
        begin = Offset(1.0 - (_progress * 3), 0.0);
        end = Offset(-_progress * 3, 0.0);
        break;
      case ShimmerDirection.ttb:
        begin = Offset(0.0, -1.0 + (_progress * 3));
        end = Offset(0.0, _progress * 3);
        break;
      case ShimmerDirection.btt:
        begin = Offset(0.0, 1.0 - (_progress * 3));
        end = Offset(0.0, -_progress * 3);
        break;
    }

    final gradient = LinearGradient(
      begin: Alignment(begin.dx, begin.dy),
      end: Alignment(end.dx, end.dy),
      colors: [_baseColor, _highlightColor, _baseColor],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = offset & size;
    final shader = gradient.createShader(rect);

    // Paint child
    context.paintChild(child!, offset);

    // Apply shimmer overlay
    context.canvas.saveLayer(rect, Paint());
    context.canvas.drawRect(
      rect,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.srcATop,
    );
    context.canvas.restore();
  }
}
