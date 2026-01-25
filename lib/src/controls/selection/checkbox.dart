import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Checkbox.
class CheckboxStatus extends ToggleControlStatus {}

/// A checkbox using lowest-level RenderObject APIs.
class Checkbox extends LeafRenderObjectWidget {
  const Checkbox({super.key, required this.value, this.onChanged, this.tag});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? tag;

  @override
  RenderCheckbox createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getCheckbox(tag) ?? CheckboxCustomization.simple();

    return RenderCheckbox(
      value: value,
      onChanged: onChanged,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCheckbox renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getCheckbox(tag) ?? CheckboxCustomization.simple();

    renderObject
      ..value = value
      ..onChanged = onChanged
      ..customization = customization;
  }
}

class RenderCheckbox extends RenderBox implements TickerProvider {
  RenderCheckbox({
    required bool value,
    ValueChanged<bool>? onChanged,
    required CheckboxCustomization customization,
  }) : _value = value,
       _onChanged = onChanged,
       _customization = customization {
    _tap = TapGestureRecognizer()
      ..onTapUp = _handleTapUp
      ..onTapDown = _handleTapDown
      ..onTapCancel = _handleTapCancel;
  }

  bool _value;
  set value(bool v) {
    if (_value == v) return;
    _value = v;
    _startTicker(); // Animate change
    markNeedsPaint();
  }

  ValueChanged<bool>? _onChanged;
  set onChanged(ValueChanged<bool>? v) {
    if (_onChanged == v) return;
    _onChanged = v;
    markNeedsSemanticsUpdate();
    markNeedsPaint(); // State change (enabled/disabled)
  }

  CheckboxCustomization _customization;
  set customization(CheckboxCustomization v) {
    if (_customization == v) return;
    _customization = v;
    markNeedsLayout();
    markNeedsPaint();
  }

  // State
  late TapGestureRecognizer _tap;
  bool _isHovered = false;
  bool _isPressed = false;

  // Animations
  Ticker? _ticker;
  double _hoverValue = 0.0;
  double _checkValue = 0.0; // 0.0 to 1.0

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // Init check value immediately
    _checkValue = _value ? 1.0 : 0.0;
  }

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

    // Animate check
    final double targetCheck = _value ? 1.0 : 0.0;
    if ((_checkValue - targetCheck).abs() > 0.01) {
      _checkValue += (targetCheck - _checkValue) * 0.2;
      dirty = true;
    } else {
      _checkValue = targetCheck;
    }

    if (dirty) {
      markNeedsPaint();
    } else {
      _ticker?.stop();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      if (_onChanged != null) _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
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
  }

  void _handleTapDown(TapDownDetails details) {
    _isPressed = true;
    markNeedsPaint();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      _isPressed = false;
      markNeedsPaint();
      _onChanged?.call(!_value);
    }
  }

  void _handleTapCancel() {
    _isPressed = false;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final double sizeVal = _customization.size ?? 18.0;
    size = constraints.constrain(Size.square(sizeVal));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final CheckboxStatus status = CheckboxStatus()
      ..enabled = (_onChanged != null) ? 1.0 : 0.0
      ..hovered = _hoverValue
      ..checked = _checkValue;

    // Map pressed to focused in status if needed?
    if (_isPressed) status.focused = 1.0;

    final decoration = _customization.decoration(status);
    final Rect rect = offset & size;

    if (decoration is BoxDecoration) {
      final Paint paint = Paint()
        ..color = decoration.color ?? const Color(0x00000000);

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

    // Draw Check Mark
    if (_checkValue > 0.0) {
      final Color checkColor =
          _customization.textStyle(status).color ?? const Color(0xFFFFFFFF);
      final Paint checkPaint = Paint()
        ..color = checkColor
            .withValues(alpha: _checkValue) // Fade in
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      // Draw simple check path
      final Path path = Path();
      // Defines key points for a checkmark relative to 0.0-1.0 coords
      // Start: 0.25, 0.5
      // Mid: 0.45, 0.7
      // End: 0.75, 0.3
      final double s = size.width;

      // Partial draw based on value? Or just fade opacity? Used opacity above.

      path.moveTo(offset.dx + s * 0.25, offset.dy + s * 0.5);
      path.lineTo(offset.dx + s * 0.45, offset.dy + s * 0.7);
      path.lineTo(offset.dx + s * 0.75, offset.dy + s * 0.3);

      context.canvas.drawPath(path, checkPaint);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isChecked = _value;
    config.isEnabled = _onChanged != null;
    if (_onChanged != null) {
      config.onTap = () => _onChanged!(!_value);
    }
  }
}
