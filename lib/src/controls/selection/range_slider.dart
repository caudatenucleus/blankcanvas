import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// Range values for the slider.
class RangeValues {
  const RangeValues(this.start, this.end);
  final double start;
  final double end;
}

/// A range slider widget.
class RangeSlider extends LeafRenderObjectWidget {
  const RangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.tag,
  });

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  final String? tag;

  @override
  RenderRangeSlider createRenderObject(BuildContext context) {
    return RenderRangeSlider(
      values: values,
      min: min,
      max: max,
      onChanged: onChanged,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderRangeSlider renderObject,
  ) {
    renderObject
      ..values = values
      ..min = min
      ..max = max
      ..onChanged = onChanged;
  }
}

class RenderRangeSlider extends RenderBox {
  RenderRangeSlider({
    required RangeValues values,
    required double min,
    required double max,
    ValueChanged<RangeValues>? onChanged,
  }) : _values = values,
       _min = min,
       _max = max,
       _onChanged = onChanged {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  RangeValues _values;
  set values(RangeValues value) {
    if (_values.start != value.start || _values.end != value.end) {
      _values = value;
      markNeedsPaint();
    }
  }

  double _min;
  set min(double value) {
    if (_min != value) {
      _min = value;
      markNeedsPaint();
    }
  }

  double _max;
  set max(double value) {
    if (_max != value) {
      _max = value;
      markNeedsPaint();
    }
  }

  ValueChanged<RangeValues>? _onChanged;
  set onChanged(ValueChanged<RangeValues>? value) {
    _onChanged = value;
    markNeedsPaint();
  }

  late HorizontalDragGestureRecognizer _drag;
  int _activeThumb = 0; // 0=none, 1=start, 2=end

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(double.infinity, 24.0));
  }

  double _valueToPosition(double value) {
    final normalized = (value - _min) / (_max - _min);
    return normalized * size.width;
  }

  double _positionToValue(double x) {
    final normalized = (x / size.width).clamp(0.0, 1.0);
    return _min + normalized * (_max - _min);
  }

  void _handleDragStart(DragStartDetails details) {
    if (_onChanged == null) return;

    final x = details.localPosition.dx;
    final startX = _valueToPosition(_values.start);
    final endX = _valueToPosition(_values.end);

    if ((x - startX).abs() < (x - endX).abs()) {
      _activeThumb = 1;
    } else {
      _activeThumb = 2;
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_onChanged == null || _activeThumb == 0) return;

    final newValue = _positionToValue(details.localPosition.dx);
    var newStart = _values.start;
    var newEnd = _values.end;

    if (_activeThumb == 1) {
      newStart = newValue.clamp(_min, newEnd);
    } else {
      newEnd = newValue.clamp(newStart, _max);
    }

    _onChanged!(RangeValues(newStart, newEnd));
  }

  void _handleDragEnd(DragEndDetails details) {
    _activeThumb = 0;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;
    final enabled = _onChanged != null;

    // Track
    final trackHeight = 4.0;
    final trackTop = rect.center.dy - trackHeight / 2;
    final trackRect = Rect.fromLTWH(
      rect.left,
      trackTop,
      rect.width,
      trackHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(2)),
      Paint()
        ..color = enabled ? const Color(0xFFE0E0E0) : const Color(0xFFEEEEEE),
    );

    // Active range
    if (enabled) {
      final startX = rect.left + _valueToPosition(_values.start);
      final endX = rect.left + _valueToPosition(_values.end);
      final activeRect = Rect.fromLTRB(
        startX,
        trackTop,
        endX,
        trackTop + trackHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(activeRect, const Radius.circular(2)),
        Paint()..color = const Color(0xFF2196F3),
      );
    }

    // Thumbs
    final thumbRadius = 8.0;
    final thumbColor = enabled
        ? const Color(0xFF2196F3)
        : const Color(0xFFBDBDBD);
    final startThumb = Offset(
      rect.left + _valueToPosition(_values.start),
      rect.center.dy,
    );
    final endThumb = Offset(
      rect.left + _valueToPosition(_values.end),
      rect.center.dy,
    );

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(startThumb, thumbRadius, shadowPaint);
    canvas.drawCircle(endThumb, thumbRadius, shadowPaint);

    // Thumb circles
    canvas.drawCircle(startThumb, thumbRadius, Paint()..color = thumbColor);
    canvas.drawCircle(endThumb, thumbRadius, Paint()..color = thumbColor);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }
}
