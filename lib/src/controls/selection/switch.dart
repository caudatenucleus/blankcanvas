import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Switch.
class SwitchStatus extends ToggleControlStatus {}

/// A switch using lowest-level RenderObject APIs.
class Switch extends LeafRenderObjectWidget {
  const Switch({
    super.key,
    required this.value,
    required this.onChanged,
    this.tag,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? tag;

  @override
  RenderSwitch createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getSwitch(tag) ?? SwitchCustomization.simple();

    return RenderSwitch(
      value: value,
      onChanged: onChanged,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSwitch renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getSwitch(tag) ?? SwitchCustomization.simple();

    renderObject
      ..value = value
      ..onChanged = onChanged
      ..customization = customization;
  }
}

class RenderSwitch extends RenderBox implements TickerProvider {
  RenderSwitch({
    required bool value,
    ValueChanged<bool>? onChanged,
    required SwitchCustomization customization,
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
    _startTicker();
    markNeedsPaint();
  }

  ValueChanged<bool>? _onChanged;
  set onChanged(ValueChanged<bool>? v) {
    if (_onChanged == v) return;
    _onChanged = v;
    markNeedsSemanticsUpdate();
    markNeedsPaint();
  }

  SwitchCustomization _customization;
  set customization(SwitchCustomization v) {
    if (_customization == v) return;
    _customization = v;
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
  double _checkValue = 0.0;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
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

    // Animate check (thumb position)
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
    size = constraints.constrain(
      Size(_customization.width ?? 40.0, _customization.height ?? 20.0),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final SwitchStatus status = SwitchStatus()
      ..enabled = (_onChanged != null) ? 1.0 : 0.0
      ..hovered = _hoverValue
      ..checked = _checkValue;

    if (_isPressed) status.focused = 1.0;

    final decoration = _customization.decoration(status);
    final Rect rect = offset & size;

    // Draw Track
    if (decoration is BoxDecoration) {
      final Paint paint = Paint()
        ..color = decoration.color ?? const Color(0xffE0E0E0); // Fallback track

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

    // Draw Thumb
    // We get Thumb color from textStyle (as per Button/Switch customization pattern where thumb implies foreground)
    final Color thumbColor =
        _customization.textStyle(status).color ?? const Color(0xFFFFFFFF);
    final double thumbRadius = (size.height / 2) - 2; // Padding
    final double trackLength =
        size.width - size.height; // Usable track for center of thumb
    final double dx = (size.height / 2) + (trackLength * _checkValue);

    context.canvas.drawCircle(
      offset + Offset(dx, size.height / 2),
      thumbRadius,
      Paint()..color = thumbColor,
    );
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isToggled = _value;
    config.isEnabled = _onChanged != null;
    if (_onChanged != null) {
      config.onTap = () => _onChanged!(!_value);
    }
  }
}
