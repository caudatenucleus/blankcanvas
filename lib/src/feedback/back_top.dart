import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A back-to-top button that appears on scroll.
class BackTop extends LeafRenderObjectWidget {
  const BackTop({
    super.key,
    required this.scrollController,
    this.visibilityThreshold = 300.0,
    this.duration = const Duration(milliseconds: 300),
    this.right = 20.0,
    this.bottom = 20.0,
    this.buttonSize = 44.0,
    this.color = const Color(0xFF2196F3),
    this.iconColor = const Color(0xFFFFFFFF),
    this.tag,
  });

  final ScrollController scrollController;
  final double visibilityThreshold;
  final Duration duration;
  final double right;
  final double bottom;
  final double buttonSize;
  final Color color;
  final Color iconColor;
  final String? tag;

  @override
  RenderBackTop createRenderObject(BuildContext context) {
    return RenderBackTop(
      scrollController: scrollController,
      visibilityThreshold: visibilityThreshold,
      duration: duration,
      buttonSize: buttonSize,
      color: color,
      iconColor: iconColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBackTop renderObject) {
    renderObject
      ..scrollController = scrollController
      ..visibilityThreshold = visibilityThreshold
      ..duration = duration
      ..buttonSize = buttonSize
      ..color = color
      ..iconColor = iconColor;
  }
}

class RenderBackTop extends RenderBox {
  RenderBackTop({
    required ScrollController scrollController,
    required double visibilityThreshold,
    required Duration duration,
    required double buttonSize,
    required Color color,
    required Color iconColor,
  }) : _scrollController = scrollController,
       _visibilityThreshold = visibilityThreshold,
       _duration = duration,
       _buttonSize = buttonSize,
       _color = color,
       _iconColor = iconColor {
    _tap = TapGestureRecognizer()..onTap = _scrollToTop;
    _scrollController.addListener(_handleScroll);
  }

  ScrollController _scrollController;
  set scrollController(ScrollController value) {
    if (_scrollController != value) {
      _scrollController.removeListener(_handleScroll);
      _scrollController = value;
      _scrollController.addListener(_handleScroll);
    }
  }

  double _visibilityThreshold;
  set visibilityThreshold(double value) => _visibilityThreshold = value;

  Duration _duration;
  set duration(Duration value) => _duration = value;

  double _buttonSize;
  set buttonSize(double value) {
    if (_buttonSize != value) {
      _buttonSize = value;
      markNeedsLayout();
    }
  }

  Color _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  Color _iconColor;
  set iconColor(Color value) {
    if (_iconColor != value) {
      _iconColor = value;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;
  bool _isVisible = false;

  void _handleScroll() {
    final shouldBeVisible = _scrollController.offset > _visibilityThreshold;
    if (shouldBeVisible != _isVisible) {
      _isVisible = shouldBeVisible;
      markNeedsPaint();
    }
  }

  void _scrollToTop() {
    if (_isVisible) {
      _scrollController.animateTo(
        0,
        duration: _duration,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void detach() {
    _scrollController.removeListener(_handleScroll);
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(_buttonSize, _buttonSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_isVisible) return;

    final canvas = context.canvas;
    final center = offset + Offset(_buttonSize / 2, _buttonSize / 2);

    // Shadow
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: _buttonSize / 2));
    canvas.drawShadow(shadowPath, const Color(0xFF000000), 8, false);

    // Circle
    canvas.drawCircle(center, _buttonSize / 2, Paint()..color = _color);

    // Arrow icon (simplified)
    final textPainter = TextPainter(
      text: TextSpan(
        text: '↑',
        style: TextStyle(
          color: _iconColor,
          fontSize: _buttonSize * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool hitTestSelf(Offset position) => _isVisible;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent && _isVisible) {
      _tap.addPointer(event);
    }
  }
}
