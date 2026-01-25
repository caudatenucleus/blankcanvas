import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

class SnowEffect extends LeafRenderObjectWidget {
  const SnowEffect({super.key, this.tag});

  final String? tag;

  @override
  RenderSnowEffect createRenderObject(BuildContext context) {
    return RenderSnowEffect();
  }
}

class Snowflake {
  Offset position;
  double speed;
  double radius;
  double sway;
  double offset; // For sine wave calculation

  Snowflake({
    required this.position,
    required this.speed,
    required this.radius,
    required this.sway,
    required this.offset,
  });
}

class RenderSnowEffect extends RenderBox {
  RenderSnowEffect() {
    _ticker = Ticker(_onTick);
  }

  late Ticker _ticker;
  final List<Snowflake> _flakes = [];
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
    if (_flakes.length < 100 && _random.nextDouble() < 0.1) {
      _flakes.add(
        Snowflake(
          position: Offset(_random.nextDouble() * size.width, -10),
          speed: _random.nextDouble() * 2 + 1,
          radius: _random.nextDouble() * 2 + 1,
          sway: _random.nextDouble() * 0.5,
          offset: _random.nextDouble() * 100,
        ),
      );
    }

    for (int i = _flakes.length - 1; i >= 0; i--) {
      final f = _flakes[i];
      f.position += Offset(
        math.sin(elapsed.inMilliseconds / 1000 + f.offset) * f.sway,
        f.speed,
      );

      if (f.position.dy > size.height) {
        _flakes.removeAt(i);
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
    final paint = Paint()..color = const Color(0xAAFFFFFF);
    for (final f in _flakes) {
      canvas.drawCircle(f.position + offset, f.radius, paint);
    }
  }

  @override
  bool hitTestSelf(Offset position) => false;
}
