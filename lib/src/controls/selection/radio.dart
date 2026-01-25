import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Radio button.
class RadioStatus extends RadioControlStatus {}

/// A radio button using lowest-level RenderObject APIs.
class Radio<T> extends LeafRenderObjectWidget {
  const Radio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.tag,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? tag;

  @override
  RenderRadio<T> createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getRadio(tag) ?? RadioCustomization.simple();

    return RenderRadio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderRadio<T> renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getRadio(tag) ?? RadioCustomization.simple();

    renderObject
      ..value = value
      ..groupValue = groupValue
      ..onChanged = onChanged
      ..customization = customization;
  }
}

class RenderRadio<T> extends RenderBox implements TickerProvider {
  RenderRadio({
    required T value,
    required T? groupValue,
    ValueChanged<T?>? onChanged,
    required RadioCustomization customization,
  }) : _value = value,
       _groupValue = groupValue,
       _onChanged = onChanged,
       _customization = customization {
    _tap = TapGestureRecognizer()
      ..onTapUp = _handleTapUp
      ..onTapDown = _handleTapDown
      ..onTapCancel = _handleTapCancel;
  }

  T _value;
  set value(T v) {
    if (_value == v) return;
    _value = v;
    _updateSelected();
  }

  T? _groupValue;
  set groupValue(T? v) {
    if (_groupValue == v) return;
    _groupValue = v;
    _updateSelected();
  }

  ValueChanged<T?>? _onChanged;
  set onChanged(ValueChanged<T?>? v) {
    if (_onChanged == v) return;
    _onChanged = v;
    markNeedsSemanticsUpdate();
    markNeedsPaint();
  }

  RadioCustomization _customization;
  set customization(RadioCustomization v) {
    if (_customization == v) return;
    _customization = v;
    markNeedsLayout();
    markNeedsPaint();
  }

  // State
  late TapGestureRecognizer _tap;
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isSelected = false;

  // Animation
  Ticker? _ticker;
  double _hoverValue = 0.0;
  double _selectValue = 0.0;

  void _updateSelected() {
    final bool newSelected = _value == _groupValue;
    if (_isSelected != newSelected) {
      _isSelected = newSelected;
      _startTicker();
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _isSelected = _value == _groupValue;
    _selectValue = _isSelected ? 1.0 : 0.0;
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

    // Animate select
    final double targetSelect = _isSelected ? 1.0 : 0.0;
    if ((_selectValue - targetSelect).abs() > 0.01) {
      _selectValue += (targetSelect - _selectValue) * 0.2;
      dirty = true;
    } else {
      _selectValue = targetSelect;
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
      _onChanged?.call(_value);
    }
  }

  void _handleTapCancel() {
    _isPressed = false;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size.square(_customization.size ?? 18.0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RadioStatus status = RadioStatus()
      ..enabled = (_onChanged != null) ? 1.0 : 0.0
      ..hovered = _hoverValue
      ..selected = _selectValue;

    if (_isPressed) status.focused = 1.0;

    final decoration = _customization.decoration(status);
    final Rect rect = offset & size;

    // Draw circle background/border
    // We assume customization provides simple decoration.
    // Draw decoration
    if (decoration is BoxDecoration) {
      final BoxDecoration boxDecoration = decoration;
      final Paint paint = Paint()
        ..color = boxDecoration.color ?? const Color(0x00000000);

      if (boxDecoration.shape == BoxShape.circle) {
        context.canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
        if (boxDecoration.border != null) {
          boxDecoration.border!.paint(
            context.canvas,
            rect,
            shape: BoxShape.circle,
          );
        }
      } else {
        if (boxDecoration.borderRadius != null) {
          final borderRadius = boxDecoration.borderRadius!.resolve(
            TextDirection.ltr,
          );
          context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
          boxDecoration.border?.paint(
            context.canvas,
            rect,
            borderRadius: borderRadius,
          );
        } else {
          context.canvas.drawRect(rect, paint);
          boxDecoration.border?.paint(context.canvas, rect);
        }
      }
    } else {
      // Fallback for generic decoration
      final BoxPainter painter = decoration.createBoxPainter();
      painter.paint(context.canvas, offset, ImageConfiguration(size: size));
      painter.dispose();
    }

    // Draw Dot
    if (_selectValue > 0) {
      Color dotColor = const Color(0xFF2196F3);
      if (decoration is BoxDecoration) {
        if ((decoration).color != null) {
          dotColor = (decoration).color!;
        }
      }

      // Override with text style color if present
      final TextStyle ts = _customization.textStyle(status);
      if (ts.color != null) {
        dotColor = ts.color!;
      }

      final double dotRadius = (rect.shortestSide / 2) * 0.5 * _selectValue;
      context.canvas.drawCircle(
        rect.center,
        dotRadius,
        Paint()..color = dotColor,
      );
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isInMutuallyExclusiveGroup = true;
    config.isSelected = _isSelected;
    config.isEnabled = _onChanged != null;
    if (_onChanged != null) {
      config.onTap = () => _onChanged!(_value);
    }
  }
}
