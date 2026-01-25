import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

/// A simple particle effect widget.
class ParticleEffect extends LeafRenderObjectWidget {
  const ParticleEffect({
    super.key,
    this.particleCount = 50,
    this.emissionRate = 0.5,
    this.gravity = 0.1,
    this.speed = 2.0,
    this.colors = const [Color(0xFF2196F3), Color(0xFFE91E63)],
    this.tag,
  });

  final int particleCount;
  final double emissionRate;
  final double gravity;
  final double speed;
  final List<Color> colors;
  final String? tag;

  @override
  RenderParticleEffect createRenderObject(BuildContext context) {
    return RenderParticleEffect(
      particleCount: particleCount,
      emissionRate: emissionRate,
      gravity: gravity,
      speed: speed,
      colors: colors,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderParticleEffect renderObject,
  ) {
    renderObject
      ..particleCount = particleCount
      ..emissionRate = emissionRate
      ..gravity = gravity
      ..speed = speed
      ..colors = colors;
  }
}

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double radius;
  double life;
  double decay;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
    required this.life,
    required this.decay,
  });
}

class RenderParticleEffect extends RenderBox {
  RenderParticleEffect({
    required int particleCount,
    required double emissionRate,
    required double gravity,
    required double speed,
    required List<Color> colors,
  }) : _particleCount = particleCount,
       _emissionRate = emissionRate,
       _gravity = gravity,
       _speed = speed,
       _colors = colors {
    _ticker = Ticker(_onTick);
  }

  int _particleCount;
  set particleCount(int value) {
    _particleCount = value;
  }

  double _emissionRate;
  set emissionRate(double value) {
    _emissionRate = value;
  }

  double _gravity;
  set gravity(double value) {
    _gravity = value;
  }

  double _speed;
  set speed(double value) {
    _speed = value;
  }

  List<Color> _colors;
  set colors(List<Color> value) {
    _colors = value;
  }

  late Ticker _ticker;
  final List<Particle> _particles = [];
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
    // Emission
    if (_particles.length < _particleCount &&
        _random.nextDouble() < _emissionRate) {
      _particles.add(_createParticle());
    }

    // Update
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life -= p.decay;
      if (p.life <= 0) {
        _particles.removeAt(i);
        continue;
      }

      p.velocity += Offset(0, _gravity);
      p.position += p.velocity;
    }

    markNeedsPaint();
  }

  Particle _createParticle() {
    final x = _random.nextDouble() * size.width;
    final y = _random.nextDouble() * size.height;
    final angle = _random.nextDouble() * 2 * math.pi;
    final speed = _random.nextDouble() * _speed;
    final velocity = Offset(math.cos(angle) * speed, math.sin(angle) * speed);

    return Particle(
      position: Offset(x, y),
      velocity: velocity,
      color: _colors[_random.nextInt(_colors.length)],
      radius: _random.nextDouble() * 4 + 2,
      life: 1.0,
      decay: _random.nextDouble() * 0.02 + 0.01,
    );
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
        ..color = p.color.withValues(alpha: p.life)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(p.position + offset, p.radius, paint);
    }
  }

  @override
  bool hitTestSelf(Offset position) => false; // Pass through clicks
}
