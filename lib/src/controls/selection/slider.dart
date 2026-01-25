import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Slider.
class SliderStatus extends SliderControlStatus {}

/// A slider using lowest-level RenderObject APIs.
class Slider extends LeafRenderObjectWidget {
  const Slider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.tag,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final String? tag;

  @override
  RenderSlider createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getSlider(tag) ??
        const SliderCustomization(
          decoration: _defaultDecoration,
          textStyle: _defaultTextStyle,
        );

    return RenderSlider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSlider renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getSlider(tag) ??
        const SliderCustomization(
          decoration: _defaultDecoration,
          textStyle: _defaultTextStyle,
        );

    renderObject
      ..value = value
      ..onChanged = onChanged
      ..min = min
      ..max = max
      ..customization = customization;
  }
}

Decoration _defaultDecoration(SliderControlStatus status) {
  return BoxDecoration(
    color: const Color(0xffe0e0e0),
    borderRadius: BorderRadius.circular(2),
  );
}

TextStyle _defaultTextStyle(SliderControlStatus status) {
  return const TextStyle(color: Color(0xFF2196F3));
}

class RenderSlider extends RenderBox implements TickerProvider {
  RenderSlider({
    required double value,
    ValueChanged<double>? onChanged,
    required double min,
    required double max,
    required SliderCustomization customization,
  }) : _value = value,
       _onChanged = onChanged,
       _min = min,
       _max = max,
       _customization = customization {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
    _tap = TapGestureRecognizer()
      ..onTapUp = _handleTapUp
      ..onTapDown = _handleTapDown; // For press effect
  }

  double _value;
  set value(double v) {
    if (_value == v) return;
    _value = v;
    markNeedsPaint();
  }

  ValueChanged<double>? _onChanged;
  set onChanged(ValueChanged<double>? v) {
    if (_onChanged == v) return;
    _onChanged = v;
    markNeedsSemanticsUpdate();
    markNeedsPaint();
  }

  double _min;
  set min(double v) {
    if (_min == v) return;
    _min = v;
    markNeedsPaint();
  }

  double _max;
  set max(double v) {
    if (_max == v) return;
    _max = v;
    markNeedsPaint();
  }

  SliderCustomization _customization;
  set customization(SliderCustomization v) {
    if (_customization == v) return;
    _customization = v;
    markNeedsLayout();
    markNeedsPaint();
  }

  // State
  late HorizontalDragGestureRecognizer _drag;
  late TapGestureRecognizer _tap;

  bool _isHovered = false;
  bool _isDragging = false;

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
    final double targetHover = _isHovered || _isDragging ? 1.0 : 0.0;
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
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      if (_onChanged != null) {
        _drag.addPointer(event);
        _tap.addPointer(event);
      }
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

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _startTicker();
    _updateValueFromPos(details.localPosition.dx);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _updateValueFromPos(details.localPosition.dx);
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    _startTicker();
  }

  void _handleDragCancel() {
    _isDragging = false;
    _startTicker();
  }

  void _handleTapDown(TapDownDetails details) {
    // Just visual feedback if needed
  }

  void _handleTapUp(TapUpDetails details) {
    _updateValueFromPos(details.localPosition.dx);
  }

  void _updateValueFromPos(double dx) {
    if (size.width <= 0) return;
    final double normalized = (dx / size.width).clamp(0.0, 1.0);
    final double newValue = _min + (normalized * (_max - _min));
    if (newValue != _value) {
      _onChanged?.call(newValue);
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, _customization.trackHeight ?? 24.0),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double normalizedValue = (_max > _min)
        ? ((_value - _min) / (_max - _min)).clamp(0.0, 1.0)
        : 0.0;

    final SliderStatus status = SliderStatus()
      ..enabled = (_onChanged != null) ? 1.0 : 0.0
      ..hovered = _hoverValue
      ..value = normalizedValue
      ..dragging = _isDragging ? 1.0 : 0.0;

    // focused?

    final decoration = _customization.decoration(status);
    final Rect rect = offset & size;

    // Draw Track
    if (decoration is BoxDecoration) {
      final Paint paint = Paint()
        ..color = decoration.color ?? const Color(0xFFE0E0E0);

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

    // Draw Progress (Left part of track)
    // Often sliders have a filled track on the left.
    // If Customization doesn't support specific progress decoration, we might simulate it with "Thumb" or rely on decoration.
    // Assuming 'color' in textStyle is highlight color.
    final Color activeColor =
        _customization.textStyle(status).color ?? const Color(0xFF2196F3);

    final Paint activePaint = Paint()..color = activeColor;
    final Rect activeRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width * normalizedValue,
      size.height,
    );
    context.canvas.drawRect(activeRect, activePaint);

    // Draw Thumb
    // Thumb size?
    final double thumbSize = _customization.thumbSize ?? 12.0;
    final double thumbX = offset.dx + (size.width * normalizedValue);
    final double thumbY = offset.dy + (size.height / 2);

    context.canvas.drawCircle(Offset(thumbX, thumbY), thumbSize, activePaint);

    // Draw overlay circle if hovered/dragged
    if (_hoverValue > 0) {
      context.canvas.drawCircle(
        Offset(thumbX, thumbY),
        thumbSize + (8 * _hoverValue), // Expand
        activePaint..color = activeColor.withValues(alpha: 0.2 * _hoverValue),
      );
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSlider = true;
    config.textDirection = TextDirection.ltr;
    config.value = '${((_value - _min) / (_max - _min) * 100).round()}%';
    config.onIncrease = _increase;
    config.onDecrease = _decrease;
    config.isEnabled = _onChanged != null;
    if (_onChanged != null) {
      config.increasedValue =
          '${(((_value + (_max - _min) * 0.1).clamp(_min, _max) - _min) / (_max - _min) * 100).round()}%';
      config.decreasedValue =
          '${(((_value - (_max - _min) * 0.1).clamp(_min, _max) - _min) / (_max - _min) * 100).round()}%';
    }
  }

  void _increase() {
    if (_onChanged != null && _value < _max) {
      final double newValue = (_value + (_max - _min) * 0.1).clamp(_min, _max);
      _onChanged!(newValue);
    }
  }

  void _decrease() {
    if (_onChanged != null && _value > _min) {
      final double newValue = (_value - (_max - _min) * 0.1).clamp(_min, _max);
      _onChanged!(newValue);
    }
  }
}
