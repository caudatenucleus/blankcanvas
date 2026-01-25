import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/foundation/time_of_day.dart';
import 'package:flutter/gestures.dart';

/// A time range picker for selecting start and end times.
class TimeRangePicker extends LeafRenderObjectWidget {
  const TimeRangePicker({
    super.key,
    this.startTime,
    this.endTime,
    this.onChanged,
    this.use24Hour = false,
    this.tag,
  });

  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final void Function(TimeOfDay start, TimeOfDay end)? onChanged;
  final bool use24Hour;
  final String? tag;

  @override
  RenderTimeRangePicker createRenderObject(BuildContext context) {
    return RenderTimeRangePicker(
      startTime: startTime ?? const TimeOfDay(hour: 9, minute: 0),
      endTime: endTime ?? const TimeOfDay(hour: 17, minute: 0),
      onChanged: onChanged,
      use24Hour: use24Hour,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTimeRangePicker renderObject,
  ) {
    renderObject
      ..startTime = startTime ?? const TimeOfDay(hour: 9, minute: 0)
      ..endTime = endTime ?? const TimeOfDay(hour: 17, minute: 0)
      ..onChanged = onChanged
      ..use24Hour = use24Hour;
  }
}

class RenderTimeRangePicker extends RenderBox {
  RenderTimeRangePicker({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    void Function(TimeOfDay start, TimeOfDay end)? onChanged,
    required bool use24Hour,
  }) : _startTime = startTime,
       _endTime = endTime,
       _onChanged = onChanged,
       _use24Hour = use24Hour {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  TimeOfDay _startTime;
  set startTime(TimeOfDay value) {
    _startTime = value;
    markNeedsPaint();
  }

  TimeOfDay _endTime;
  set endTime(TimeOfDay value) {
    _endTime = value;
    markNeedsPaint();
  }

  // ignore: unused_field
  void Function(TimeOfDay start, TimeOfDay end)? _onChanged;
  set onChanged(void Function(TimeOfDay start, TimeOfDay end)? value) =>
      _onChanged = value;

  bool _use24Hour;
  set use24Hour(bool value) {
    if (_use24Hour != value) {
      _use24Hour = value;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;
  int _focusedField = 0; // 0=startHour, 1=startMin, 2=endHour, 3=endMin
  int? _hoveredField;

  static const double _height = 48.0;
  static const double _timeBoxWidth = 100.0;

  Rect _startRect = Rect.zero;
  Rect _endRect = Rect.zero;
  Rect _arrowRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(_timeBoxWidth * 2 + 60, _height));
    _startRect = Rect.fromLTWH(0, 0, _timeBoxWidth, _height);
    _arrowRect = Rect.fromLTWH(_timeBoxWidth + 10, 0, 40, _height);
    _endRect = Rect.fromLTWH(_timeBoxWidth + 60, 0, _timeBoxWidth, _height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Start time box
    _drawTimeBox(
      canvas,
      _startRect.shift(offset),
      _startTime.format(_use24Hour),
      _focusedField < 2,
      _hoveredField == 0,
    );

    // Arrow
    textPainter.text = const TextSpan(
      text: '→',
      style: TextStyle(fontSize: 20, color: Color(0xFF999999)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      _arrowRect.shift(offset).center -
          Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // End time box
    _drawTimeBox(
      canvas,
      _endRect.shift(offset),
      _endTime.format(_use24Hour),
      _focusedField >= 2,
      _hoveredField == 1,
    );

    // Duration
    final durationMinutes =
        (_endTime.hour * 60 + _endTime.minute) -
        (_startTime.hour * 60 + _startTime.minute);
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    textPainter.text = TextSpan(
      text: '${hours}h ${mins}m',
      style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx + size.width / 2 - textPainter.width / 2,
        offset.dy + _height + 4,
      ),
    );
  }

  void _drawTimeBox(
    Canvas canvas,
    Rect rect,
    String text,
    bool isFocused,
    bool isHovered,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = isHovered ? const Color(0xFFF5F5F5) : const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = isFocused ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0)
        ..strokeWidth = isFocused ? 2 : 1,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    if (_startRect.contains(local)) {
      _focusedField = 0;
    } else if (_endRect.contains(local)) {
      _focusedField = 2;
    }
    markNeedsPaint();
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    if (_startRect.contains(local)) {
      hovered = 0;
    } else if (_endRect.contains(local))
      hovered = 1;

    if (_hoveredField != hovered) {
      _hoveredField = hovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
