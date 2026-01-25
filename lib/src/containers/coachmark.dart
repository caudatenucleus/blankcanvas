import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A coachmark overlay widget.
class Coachmark extends LeafRenderObjectWidget {
  const Coachmark({
    super.key,
    required this.targetRect,
    required this.text,
    this.onNext,
    this.onSkip,
    this.overlayColor = const Color(0xAA000000),
    this.tag,
  });

  final Rect targetRect;
  final String text;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final Color overlayColor;
  final String? tag;

  @override
  RenderCoachmark createRenderObject(BuildContext context) {
    return RenderCoachmark(
      targetRect: targetRect,
      text: text,
      onNext: onNext,
      onSkip: onSkip,
      overlayColor: overlayColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCoachmark renderObject) {
    renderObject
      ..targetRect = targetRect
      ..text = text
      ..onNext = onNext
      ..onSkip = onSkip
      ..overlayColor = overlayColor;
  }
}

class RenderCoachmark extends RenderBox {
  RenderCoachmark({
    required Rect targetRect,
    required String text,
    VoidCallback? onNext,
    VoidCallback? onSkip,
    required Color overlayColor,
  }) : _targetRect = targetRect,
       _text = text,
       _onNext = onNext,
       _onSkip = onSkip,
       _overlayColor = overlayColor {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  Rect _targetRect;
  set targetRect(Rect value) {
    _targetRect = value;
    markNeedsPaint();
  }

  String _text;
  set text(String value) {
    _text = value;
    markNeedsPaint();
  }

  VoidCallback? _onNext;
  set onNext(VoidCallback? value) => _onNext = value;

  VoidCallback? _onSkip;
  set onSkip(VoidCallback? value) => _onSkip = value;

  Color _overlayColor;
  set overlayColor(Color value) {
    _overlayColor = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  Rect? _nextButtonRect;
  Rect? _skipButtonRect;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Overlay with hole
    final path = Path()
      ..addRect(offset & size)
      ..addRRect(
        RRect.fromRectAndRadius(
          _targetRect.shift(offset),
          const Radius.circular(8),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = _overlayColor);

    // Border around target
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _targetRect.shift(offset),
        const Radius.circular(8),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFFFFFFF)
        ..strokeWidth = 2,
    );

    // Positioning logic (simplified: below target if possible, else above)
    final isBelow = (_targetRect.bottom + 100) < size.height;
    final anchorPoint = isBelow
        ? Offset(_targetRect.center.dx, _targetRect.bottom + 10)
        : Offset(_targetRect.center.dx, _targetRect.top - 10);

    // Text Bubble
    textPainter.text = TextSpan(
      text: _text,
      style: const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
    );
    textPainter.layout(maxWidth: size.width - 40);

    final textX = (anchorPoint.dx - textPainter.width / 2).clamp(
      20.0,
      size.width - textPainter.width - 20.0,
    );
    final textY = isBelow
        ? anchorPoint.dy + 20
        : anchorPoint.dy - 20 - textPainter.height;

    // Arrow
    final arrowPath = Path();
    if (isBelow) {
      arrowPath.moveTo(anchorPoint.dx + offset.dx, anchorPoint.dy + offset.dy);
      arrowPath.lineTo(
        anchorPoint.dx - 10 + offset.dx,
        anchorPoint.dy + 10 + offset.dy,
      );
      arrowPath.lineTo(
        anchorPoint.dx + 10 + offset.dx,
        anchorPoint.dy + 10 + offset.dy,
      );
    } else {
      arrowPath.moveTo(anchorPoint.dx + offset.dx, anchorPoint.dy + offset.dy);
      arrowPath.lineTo(
        anchorPoint.dx - 10 + offset.dx,
        anchorPoint.dy - 10 + offset.dy,
      );
      arrowPath.lineTo(
        anchorPoint.dx + 10 + offset.dx,
        anchorPoint.dy - 10 + offset.dy,
      );
    }
    arrowPath.close();
    canvas.drawPath(arrowPath, Paint()..color = const Color(0xFFFFFFFF));

    // Draw text
    textPainter.paint(canvas, Offset(textX + offset.dx, textY + offset.dy));

    // Buttons
    final buttonsY = isBelow ? textY + textPainter.height + 20 : textY - 50;

    // Next Button
    textPainter.text = const TextSpan(
      text: 'Next',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
    textPainter.layout();
    final nextRect = Rect.fromLTWH(
      size.width - 100 + offset.dx,
      buttonsY + offset.dy,
      80,
      36,
    );
    _nextButtonRect = nextRect;
    canvas.drawRRect(
      RRect.fromRectAndRadius(nextRect, const Radius.circular(18)),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    textPainter.paint(
      canvas,
      Offset(
        nextRect.center.dx - textPainter.width / 2,
        nextRect.center.dy - textPainter.height / 2,
      ),
    );

    // Skip Button
    textPainter.text = const TextSpan(
      text: 'Skip',
      style: TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
    );
    textPainter.layout();
    final skipRect = Rect.fromLTWH(
      20 + offset.dx,
      buttonsY + offset.dy,
      60,
      36,
    );
    _skipButtonRect = skipRect;
    textPainter.paint(
      canvas,
      Offset(
        skipRect.center.dx - textPainter.width / 2,
        skipRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    if (_nextButtonRect?.contains(details.localPosition) ?? false) {
      _onNext?.call();
    } else if (_skipButtonRect?.contains(details.localPosition) ?? false) {
      _onSkip?.call();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }
}
