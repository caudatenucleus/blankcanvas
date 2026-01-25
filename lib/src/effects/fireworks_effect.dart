import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

class FireworksEffect extends LeafRenderObjectWidget {
  const FireworksEffect({super.key, this.tag});

  final String? tag;

  @override
  RenderFireworksEffect createRenderObject(BuildContext context) {
    return RenderFireworksEffect();
  }
}

class FireworkParticle {
  Offset position;
  Offset velocity;
  Color color;
  double life;
  double decay;
  bool isSpark;

  FireworkParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.life,
    required this.decay,
    this.isSpark = false,
  });
}

class RenderFireworksEffect extends RenderBox {
  RenderFireworksEffect() {
    _ticker = Ticker(_onTick);
  }

  late Ticker _ticker;
  final List<FireworkParticle> _particles = [];
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
    // Launch rockets
    if (_random.nextDouble() < 0.05) {
      // 5% chance per tick to launch
      _launchRocket();
    }

    // Update
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life -= p.decay;

      if (p.life <= 0) {
        if (!p.isSpark) {
          _explode(p.position, p.color);
        }
        _particles.removeAt(i);
        continue;
      }

      p.velocity += Offset(0, 0.05); // Gravity
      p.position += p.velocity;
    }

    markNeedsPaint();
  }

  void _launchRocket() {
    final x = _random.nextDouble() * size.width;
    final speed = -(_random.nextDouble() * 3 + 4); // Upward speed
    _particles.add(
      FireworkParticle(
        position: Offset(x, size.height),
        velocity: Offset((_random.nextDouble() - 0.5) * 1, speed),
        color: Color(
          (_random.nextDouble() * 0xFFFFFF).toInt(),
        ).withValues(alpha: 1.0),
        life: 1.0,
        decay: _random.nextDouble() * 0.01 + 0.015,
      ),
    );
  }

  void _explode(Offset position, Color color) {
    final count = _random.nextInt(20) + 30;
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = _random.nextDouble() * 3;
      _particles.add(
        FireworkParticle(
          position: position,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          life: 1.0,
          decay: _random.nextDouble() * 0.03 + 0.02,
          isSpark: true,
        ),
      );
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    for (final p in _particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: (p.life).clamp(0.0, 1.0));
      if (p.isSpark) {
        canvas.drawCircle(p.position + offset, 2, paint);
      } else {
        // Rocket trail
        canvas.drawCircle(p.position + offset, 3, paint);
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => false;
}
