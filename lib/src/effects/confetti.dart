import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

/// A confetti animation widget.
class Confetti extends SingleChildRenderObjectWidget {
  const Confetti({
    super.key,
    this.isPlaying = false,
    this.particleCount = 50,
    this.colors = const [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
      Color(0xFF4ECDC4),
      Color(0xFF9B59B6),
      Color(0xFF3498DB),
    ],
    this.gravity = 0.1,
    super.child,
    this.tag,
  });

  final bool isPlaying;
  final int particleCount;
  final List<Color> colors;
  final double gravity;
  final String? tag;

  @override
  RenderConfetti createRenderObject(BuildContext context) {
    return RenderConfetti(
      isPlaying: isPlaying,
      particleCount: particleCount,
      colors: colors,
      gravity: gravity,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderConfetti renderObject) {
    renderObject
      ..isPlaying = isPlaying
      ..particleCount = particleCount
      ..colors = colors
      ..gravity = gravity;
  }
}

class _ConfettiParticle {
  double x, y, vx, vy, rotation, rotationSpeed;
  Color color;
  double size;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
  });
}

class RenderConfetti extends RenderProxyBox implements TickerProvider {
  RenderConfetti({
    required bool isPlaying,
    required int particleCount,
    required List<Color> colors,
    required double gravity,
  }) : _isPlaying = isPlaying,
       _particleCount = particleCount,
       _colors = colors,
       _gravity = gravity {
    _ticker = createTicker(_onTick);
    if (_isPlaying) {
      _spawnParticles();
      _ticker.start();
    }
  }

  bool _isPlaying;
  set isPlaying(bool value) {
    if (_isPlaying != value) {
      _isPlaying = value;
      if (_isPlaying) {
        _spawnParticles();
        _ticker.start();
      } else {
        _ticker.stop();
        _particles.clear();
        markNeedsPaint();
      }
    }
  }

  int _particleCount;
  set particleCount(int value) => _particleCount = value;

  List<Color> _colors;
  set colors(List<Color> value) => _colors = value;

  double _gravity;
  set gravity(double value) => _gravity = value;

  late Ticker _ticker;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'ConfettiTicker');
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        _ConfettiParticle(
          x: 0.5,
          y: 0.0,
          vx: (_random.nextDouble() - 0.5) * 0.03,
          vy: _random.nextDouble() * 0.02 + 0.005,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
          color: _colors[_random.nextInt(_colors.length)],
          size: _random.nextDouble() * 8 + 4,
        ),
      );
    }
  }

  void _onTick(Duration elapsed) {
    _particles.removeWhere((p) => p.y > 1.5);
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += _gravity * 0.001;
      p.rotation += p.rotationSpeed;
    }
    if (_particles.isEmpty && _isPlaying) {
      _spawnParticles();
    }
    markNeedsPaint();
  }

  @override
  void detach() {
    _ticker.dispose();
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    if (_isPlaying) {
      final canvas = context.canvas;
      for (final p in _particles) {
        final paint = Paint()..color = p.color;
        canvas.save();
        canvas.translate(
          offset.dx + p.x * size.width,
          offset.dy + p.y * size.height,
        );
        canvas.rotate(p.rotation);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }
}
