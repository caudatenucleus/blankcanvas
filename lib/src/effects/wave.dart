import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// An animated wave overlay effect using lowest-level APIs.
class Wave extends SingleChildRenderObjectWidget {
  const Wave({
    super.key,
    required Widget child,
    this.waveColor = const Color(0x40000000),
    this.amplitude = 20.0,
    this.frequency = 1.5,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(child: child);

  final Color waveColor;
  final double amplitude;
  final double frequency;
  final Duration duration;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWave(
      waveColor: waveColor,
      amplitude: amplitude,
      frequency: frequency,
      duration: duration,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderWave renderObject) {
    renderObject
      ..waveColor = waveColor
      ..amplitude = amplitude
      ..frequency = frequency
      ..duration = duration;
  }
}

class RenderWave extends RenderProxyBox {
  RenderWave({
    required Color waveColor,
    required double amplitude,
    required double frequency,
    required Duration duration,
  }) : _waveColor = waveColor,
       _amplitude = amplitude,
       _frequency = frequency,
       _duration = duration;

  Ticker? _ticker;
  double _progress = 0.0;

  Color _waveColor;
  Color get waveColor => _waveColor;
  set waveColor(Color value) {
    if (_waveColor == value) return;
    _waveColor = value;
    markNeedsPaint();
  }

  double _amplitude;
  double get amplitude => _amplitude;
  set amplitude(double value) {
    if (_amplitude == value) return;
    _amplitude = value;
    markNeedsPaint();
  }

  double _frequency;
  double get frequency => _frequency;
  set frequency(double value) {
    if (_frequency == value) return;
    _frequency = value;
    markNeedsPaint();
  }

  Duration _duration;
  Duration get duration => _duration;
  set duration(Duration value) {
    _duration = value;
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
    final ms = elapsed.inMilliseconds % _duration.inMilliseconds;
    _progress = ms / _duration.inMilliseconds;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint child first
    if (child != null) {
      context.paintChild(child!, offset);
    }

    // Draw wave overlay
    final canvas = context.canvas;
    final paint = Paint()
      ..color = _waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(offset.dx, offset.dy + size.height);

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height -
          _amplitude -
          math.sin(
                (x / size.width * _frequency * math.pi * 2) +
                    (_progress * math.pi * 2),
              ) *
              _amplitude;
      path.lineTo(offset.dx + x, offset.dy + y);
    }

    path.lineTo(offset.dx + size.width, offset.dy + size.height);
    path.close();

    canvas.drawPath(path, paint);
  }
}
