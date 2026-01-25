import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

class RainEffect extends LeafRenderObjectWidget {
  const RainEffect({super.key, this.tag});

  final String? tag;

  @override
  RenderRainEffect createRenderObject(BuildContext context) {
    return RenderRainEffect();
  }
}

class RainDrop {
  Offset position;
  double speed;
  double len;

  RainDrop({required this.position, required this.speed, required this.len});
}

class RenderRainEffect extends RenderBox {
  RenderRainEffect() {
    _ticker = Ticker(_onTick);
  }

  late Ticker _ticker;
  final List<RainDrop> _drops = [];
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
    if (_drops.length < 200) {
      // Spawn new drops from top
      for (int i = 0; i < 3; i++) {
        _drops.add(
          RainDrop(
            position: Offset(_random.nextDouble() * size.width, -20),
            speed: _random.nextDouble() * 5 + 10,
            len: _random.nextDouble() * 10 + 10,
          ),
        );
      }
    }

    for (int i = _drops.length - 1; i >= 0; i--) {
      final d = _drops[i];
      d.position += Offset(0, d.speed);
      if (d.position.dy > size.height) {
        _drops.removeAt(i);
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
    final paint = Paint()
      ..color = const Color(0x99AACDFF)
      ..strokeWidth = 1.5;

    for (final d in _drops) {
      canvas.drawLine(
        d.position + offset,
        d.position + offset + Offset(0, d.len),
        paint,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => false;
}
