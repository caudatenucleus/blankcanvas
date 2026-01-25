import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A touch ripple effect using lowest-level APIs.
class Ripple extends SingleChildRenderObjectWidget {
  const Ripple({
    super.key,
    required Widget child,
    this.rippleColor = const Color(0x40000000),
    this.duration = const Duration(milliseconds: 400),
    this.onTap,
  }) : super(child: child);

  final Color rippleColor;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRipple(
      rippleColor: rippleColor,
      duration: duration,
      onTap: onTap,
      vsync: TickerProvider.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderRipple renderObject) {
    renderObject
      ..rippleColor = rippleColor
      ..duration = duration
      ..onTap = onTap;
  }
}

/// TickerProvider from context
class TickerProvider {
  static TickerProvider of(BuildContext context) {
    return _ContextTickerProvider(context);
  }

  Ticker createTicker(TickerCallback onTick) {
    throw UnimplementedError();
  }
}

class _ContextTickerProvider extends TickerProvider {
  _ContextTickerProvider(this.context);
  final BuildContext context;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

class RenderRipple extends RenderProxyBox {
  RenderRipple({
    required Color rippleColor,
    required this.duration,
    this.onTap,
    required TickerProvider vsync,
  }) : _rippleColor = rippleColor,
       _vsync = vsync {
    _tap = TapGestureRecognizer()
      ..onTapDown = _handleTapDown
      ..onTap = _handleTap;
  }

  late TapGestureRecognizer _tap;
  final TickerProvider _vsync;
  Ticker? _ticker;
  double _progress = 0.0;
  Offset _tapPosition = Offset.zero;
  bool _animating = false;

  Color _rippleColor;
  Color get rippleColor => _rippleColor;
  set rippleColor(Color value) {
    if (_rippleColor == value) return;
    _rippleColor = value;
    markNeedsPaint();
  }

  Duration duration;

  VoidCallback? onTap;

  @override
  void detach() {
    _tap.dispose();
    _ticker?.dispose();
    super.detach();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _tapPosition = details.localPosition;
    _startAnimation();
  }

  void _handleTap() {
    onTap?.call();
  }

  void _startAnimation() {
    _progress = 0.0;
    _animating = true;
    _ticker?.dispose();
    _ticker = _vsync.createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMilliseconds / duration.inMilliseconds;
    if (t >= 1.0) {
      _progress = 1.0;
      _animating = false;
      _ticker?.stop();
      markNeedsPaint();
    } else {
      _progress = t;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }

    if (_animating || _progress > 0) {
      final canvas = context.canvas;
      final maxRadius = size.longestSide;
      final radius = _progress * maxRadius;
      final opacity = (1.0 - _progress).clamp(0.0, 1.0);

      canvas.drawCircle(
        offset + _tapPosition,
        radius,
        Paint()
          ..color = _rippleColor.withValues(alpha: _rippleColor.a * opacity),
      );
    }
  }
}
