import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Button.
class ButtonStatus extends MutableControlStatus {}

/// A button that follows the BlankCanvas architecture using lowest-level RenderObject APIs.
class Button extends SingleChildRenderObjectWidget {
  const Button({
    super.key,
    required this.onPressed,
    required Widget child,
    this.tag,
  }) : super(child: child);

  final VoidCallback? onPressed;
  final String? tag;

  @override
  RenderButton createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getButton(tag) ??
        ButtonCustomization.simple(); // Fallback?

    return RenderButton(onPressed: onPressed, customization: customization);
  }

  @override
  void updateRenderObject(BuildContext context, RenderButton renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getButton(tag) ?? ButtonCustomization.simple();

    renderObject
      ..onPressed = onPressed
      ..customization = customization;
  }
}

class RenderButton extends RenderProxyBox implements TickerProvider {
  RenderButton({
    VoidCallback? onPressed,
    required ButtonCustomization customization,
  }) : _onPressed = onPressed,
       _customization = customization {
    _tap = TapGestureRecognizer()
      ..onTapDown = _handleTapDown
      ..onTapUp = _handleTapUp
      ..onTapCancel = _handleTapCancel;
  }

  // Properties
  VoidCallback? _onPressed;
  set onPressed(VoidCallback? value) {
    if (_onPressed == value) return;
    _onPressed = value;
    markNeedsSemanticsUpdate();
    markNeedsPaint(); // Enable/disable state change
  }

  ButtonCustomization _customization;
  set customization(ButtonCustomization value) {
    if (_customization == value) return;
    _customization = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  // State
  late TapGestureRecognizer _tap;
  bool _isHovered = false;
  bool _isPressed = false;

  // Animation
  Ticker? _ticker;
  double _hoverValue = 0.0;
  double _pressValue = 0.0;


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

    // Animate press
    final double targetPress = _isPressed ? 1.0 : 0.0;
    if ((_pressValue - targetPress).abs() > 0.01) {
      _pressValue += (targetPress - _pressValue) * 0.4; // Faster
      dirty = true;
    } else {
      _pressValue = targetPress;
    }

    if (dirty) {
      markNeedsPaint();
    } else {
      _ticker?.stop();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true; // Intercept for hover/tap

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      if (_onPressed != null) _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      if (!_isHovered) {
        _isHovered = true;
        _startTicker();
        // Update cursor?
        // Cursor management in RenderObject is usually via MouseTrackerAnnotation (hitTest).
        // OR explicit call? No, RenderObject doesn't have cursor API directly except via MouseRegion mechanism.
        // Since we want low level, we usually return a MouseTrackerAnnotation in `hitTest`.
        // But `RenderBox` implements `HitTestTarget`.
        // To change cursor, we need to return an entry that implements `MouseTrackerAnnotation`.
        // `RenderPointerListener` / `RenderMouseRegion` does this.
        // Embedding `MouseTrackerAnnotation` logic here is complex.
        // Skipping cursor for now or assuming default.
      }
    } else if (event is PointerExitEvent) {
      if (_isHovered) {
        _isHovered = false;
        _startTicker();
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _isPressed = true;
    _startTicker();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      _isPressed = false;
      _startTicker();
      _onPressed?.call();
    }
  }

  void _handleTapCancel() {
    _isPressed = false;
    _startTicker();
  }

  @override
  void performLayout() {
    // Customization might define width/height
    BoxConstraints childConstraints = constraints;
    if (_customization.width != null || _customization.height != null) {
      childConstraints = constraints.tighten(
        width: _customization.width,
        height: _customization.height,
      );
    }

    if (child != null) {
      child!.layout(childConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = childConstraints.constrain(
        Size(_customization.width ?? 0, _customization.height ?? 0),
      ); // Or min size
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // We need to resolve decoration based on current animated values.
    // Since customization gives us discrete decorations, we might need to paint multiple and blend?
    // Or just pick one based on threshold.
    // For simplicity:
    // Create status based on dominant state.

    // Or better: Map values to status properties.
    final status = MutableControlStatus()
      ..enabled = (_onPressed != null) ? 1.0 : 0.0
      ..hovered = _hoverValue
    // ..focused = _pressValue // Map press to focused for visual feedback
    ; // ignore focused for now or map press

    if (_pressValue > 0) {
      // Combine?
      // If customization logic uses priority (Press > Hover), strict values work.
      // If we want blend, Customization needs to support it.
      // Assuming it does:
      // status.pressed? No pressed prop in ControlStatus base?
      // `ControlStatus` has `focused`, `hovered`, `enabled`.
      // We can map `pressed` to `focused` as a hack or extend `ButtonStatus`.
      status.focused = _pressValue;
    }

    final decoration = _customization.decoration(status);
    final Rect rect = offset & size;

    if (decoration is BoxDecoration) {
      final Paint paint = Paint()
        ..color = decoration.color ?? const Color(0x00000000);
      // Paint shadow (simplified)
      if (decoration.boxShadow != null) {
        for (final shadow in decoration.boxShadow!) {
          context.canvas.drawRect(
            rect.shift(shadow.offset).inflate(shadow.spreadRadius),
            shadow.toPaint(),
          );
        }
      }
      // Paint shape
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
    }

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isButton = true;
    config.isEnabled = _onPressed != null;
    if (_onPressed != null) {
      config.onTap = _onPressed;
    }
  }
}
