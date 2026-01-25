import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

class BubblesEffect extends LeafRenderObjectWidget {
  const BubblesEffect({super.key, this.tag});

  final String? tag;

  @override
  RenderBubblesEffect createRenderObject(BuildContext context) {
    return RenderBubblesEffect();
  }
}

class Bubble {
  Offset position;
  double speed;
  double radius;
  double wobbleOffset;
  Color color;

  Bubble({
    required this.position,
    required this.speed,
    required this.radius,
    required this.wobbleOffset,
    required this.color,
  });
}

class RenderBubblesEffect extends RenderBox {
  RenderBubblesEffect() {
    _ticker = Ticker(_onTick);
  }

  late Ticker _ticker;
  final List<Bubble> _bubbles = [];
  final math.Random _random = math.Random();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _ticker.start();
  }

  @override
  void detach() {
    _ticker.stop();
    super.detach();
  }

  void _onTick(Duration elapsed) {
    if (_bubbles.length < 30 && _random.nextDouble() < 0.05) {
      _bubbles.add(
        Bubble(
          position: Offset(_random.nextDouble() * size.width, size.height + 20),
          speed: _random.nextDouble() * 1 + 0.5,
          radius: _random.nextDouble() * 10 + 5,
          wobbleOffset: _random.nextDouble() * 100,
          color: Color(
            (_random.nextDouble() * 0xFFFFFF).toInt(),
          ).withValues(alpha: 0.3 + _random.nextDouble() * 0.3),
        ),
      );
    }

    for (int i = _bubbles.length - 1; i >= 0; i--) {
      final b = _bubbles[i];
      final time = elapsed.inMilliseconds / 1000;
      b.position += Offset(math.sin(time + b.wobbleOffset) * 0.5, -b.speed);

      if (b.position.dy < -b.radius * 2) {
        _bubbles.removeAt(i);
      }
    }
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    for (final b in _bubbles) {
      final paint = Paint()
        ..color = b.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(b.position + offset, b.radius, paint);

      // Reflection
      final shinePaint = Paint()..color = const Color(0x66FFFFFF);
      canvas.drawCircle(
        b.position + offset - Offset(b.radius * 0.3, b.radius * 0.3),
        b.radius * 0.2,
        shinePaint,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => false;
}
