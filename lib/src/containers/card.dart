import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Card.
class CardStatus extends CardControlStatus {}

/// A card using lowest-level RenderObject APIs.
class Card extends SingleChildRenderObjectWidget {
  const Card({super.key, required Widget child, this.tag})
    : super(child: child);

  final String? tag;

  @override
  RenderCard createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getCard(tag) ??
        CardCustomization(
          decoration: (status) => BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textStyle: (status) => const TextStyle(color: Color(0xFF000000)),
        );

    return RenderCard(customization: customization);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCard renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getCard(tag) ??
        CardCustomization(
          decoration: (status) => BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textStyle: (status) => const TextStyle(color: Color(0xFF000000)),
        );

    renderObject.customization = customization;
  }
}

class RenderCard extends RenderProxyBox implements TickerProvider {
  RenderCard({required CardCustomization customization, RenderBox? child})
    : _customization = customization,
      super(child);

  CardCustomization _customization;
  set customization(CardCustomization v) {
    if (_customization == v) return;
    _customization = v;
    markNeedsPaint();
  }

  // State
  bool _isHovered = false;

  // Animation
  Ticker? _ticker;
  double _hoverValue = 0.0;


  @override
  void detach() {
    _ticker?.dispose();
    super.detach();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void _startTicker() {
    if (_ticker == null) {
      _ticker = createTicker(_tick)..start();
    } else if (!_ticker!.isActive) {
      _ticker!.start();
    }
  }

  void _tick(Duration elapsed) {
    bool dirty = false;

    // Animate hover
    final double targetHover = _isHovered ? 1.0 : 0.0;
    if ((_hoverValue - targetHover).abs() > 0.01) {
      _hoverValue += (targetHover - _hoverValue) * 0.2;
      dirty = true;
    } else {
      _hoverValue = targetHover;
    }

    if (dirty) {
      markNeedsPaint();
    } else {
      _ticker?.stop();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true; // To catch hover

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent) {
      if (!_isHovered) {
        _isHovered = true;
        _startTicker();
      }
    } else if (event is PointerExitEvent) {
      if (_isHovered) {
        _isHovered = false;
        _startTicker();
      }
    }
    super.handleEvent(event, entry);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final CardStatus status = CardStatus()..hovered = _hoverValue;

    final decoration = _customization.decoration(status);
    final Rect rect = offset & size;

    // Draw Background/Decoration
    // We can't easily rely on decoration.createBoxPainter because we might want animation interpolation if we were advanced,
    // but here we just repaint with new decoration from status.

    if (decoration is BoxDecoration) {
      final Paint paint = Paint()
        ..color = decoration.color ?? const Color(0xFFFFFFFF);

      if (decoration.boxShadow != null) {
        for (final shadow in decoration.boxShadow!) {
          final Paint shadowPaint = shadow.toPaint();
          final Rect shadowRect = rect
              .shift(shadow.offset)
              .inflate(shadow.spreadRadius);
          // Blur is handled by toPaint's maskFilter usually, but drawRect with maskFilter might act differently on some platforms?
          // Standard flutter method:
          if (decoration.borderRadius != null) {
            final borderRadius = decoration.borderRadius!.resolve(
              TextDirection.ltr,
            );
            context.canvas.drawRRect(
              borderRadius.toRRect(shadowRect),
              shadowPaint,
            );
          } else {
            context.canvas.drawRect(shadowRect, shadowPaint);
          }
        }
      }

      if (decoration.borderRadius != null) {
        final borderRadius = decoration.borderRadius!.resolve(
          TextDirection.ltr,
        );
        context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
        decoration.border?.paint(
          context.canvas,
          rect,
          borderRadius: borderRadius,
        );
      } else {
        context.canvas.drawRect(rect, paint);
        decoration.border?.paint(context.canvas, rect);
      }
    } else {
      // Fallback
      final BoxPainter painter = decoration.createBoxPainter();
      painter.paint(context.canvas, offset, ImageConfiguration(size: size));
      painter.dispose();
    }

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
