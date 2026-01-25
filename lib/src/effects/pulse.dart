import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A pulsing animation effect using lowest-level APIs.
class Pulse extends SingleChildRenderObjectWidget {
  const Pulse({
    super.key,
    required Widget child,
    this.pulseColor = const Color(0x40000000),
    this.duration = const Duration(milliseconds: 1500),
    this.maxScale = 1.5,
    this.repeat = true,
  }) : super(child: child);

  final Color pulseColor;
  final Duration duration;
  final double maxScale;
  final bool repeat;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPulse(
      pulseColor: pulseColor,
      duration: duration,
      maxScale: maxScale,
      repeat: repeat,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPulse renderObject) {
    renderObject
      ..pulseColor = pulseColor
      ..duration = duration
      ..maxScale = maxScale
      ..repeat = repeat;
  }
}

class RenderPulse extends RenderProxyBox {
  RenderPulse({
    required Color pulseColor,
    required this.duration,
    required double maxScale,
    required this.repeat,
  }) : _pulseColor = pulseColor,
       _maxScale = maxScale;

  Ticker? _ticker;
  double _progress = 0.0;
  // ignore: unused_field
  Duration _elapsed = Duration.zero;

  Color _pulseColor;
  Color get pulseColor => _pulseColor;
  set pulseColor(Color value) {
    if (_pulseColor == value) return;
    _pulseColor = value;
    markNeedsPaint();
  }

  Duration duration;

  double _maxScale;
  double get maxScale => _maxScale;
  set maxScale(double value) {
    if (_maxScale == value) return;
    _maxScale = value;
    markNeedsPaint();
  }

  bool repeat;

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
    _elapsed = elapsed;
    final ms = elapsed.inMilliseconds % duration.inMilliseconds;
    _progress = ms / duration.inMilliseconds;

    if (!repeat && elapsed >= duration) {
      _ticker?.stop();
      _progress = 1.0;
    }

    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final center = offset + Offset(size.width / 2, size.height / 2);

    // Draw pulse ring
    final scale = 1.0 + (_progress * (_maxScale - 1.0));
    final opacity = 1.0 - _progress;
    final radius = 25.0 * scale;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = _pulseColor.withValues(alpha: _pulseColor.a * opacity),
    );

    // Paint child on top
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
