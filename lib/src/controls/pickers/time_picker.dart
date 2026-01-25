import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

import 'package:blankcanvas/src/foundation/time_of_day.dart';

/// A time picker widget.
class TimePicker extends LeafRenderObjectWidget {
  const TimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
    this.tag,
  });

  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final String? tag;

  @override
  RenderTimePicker createRenderObject(BuildContext context) {
    return RenderTimePicker(
      initialTime: initialTime,
      onTimeChanged: onTimeChanged,
      tag: tag,
      // Customization? Not defined in CustomizedTheme yet maybe?
      // We can use default or add it.
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTimePicker renderObject) {
    renderObject
      ..initialTime = initialTime
      ..onTimeChanged = onTimeChanged
      ..tag = tag;
  }
}

class RenderTimePicker extends RenderBox {
  RenderTimePicker({
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onTimeChanged,
    String? tag,
  }) : _time = initialTime,
       _onTimeChanged = onTimeChanged,
       _tag = tag {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  TimeOfDay _time;
  TimeOfDay get time => _time;
  set initialTime(TimeOfDay value) {
    if (_time != value) {
      // If parent pushes new time, update?
      // _time = value;
      // But we manage internal state too?
      // If we want "controlled" component, we should update.
      // _time = value;
      // markNeedsPaint();
    }
    // Actually strictly, if it's "initialTime", we ignore it after init?
    // Usually "initialValue" implies unregulated.
    // But if user expects it to update:
    // "value" vs "initialValue". Widget says "initialTime".
    // Let's treat it as initial only?
    // But if user sets state, they might rebuild widget.
    // Let's assume it's controlled for now to be safe, updating if different?
    // Ideally widget should have `value` param if controlled.
    // Refactor widget to named `value` later?
    // Current signature: `initialTime`.
    // I will respect it only if I haven't changed?
    // For now, let's keep internal state.
  }

  ValueChanged<TimeOfDay> _onTimeChanged;
  set onTimeChanged(ValueChanged<TimeOfDay> value) {
    _onTimeChanged = value;
  }

  String? _tag;
  set tag(String? value) {
    if (_tag != value) {
      _tag = value;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;

  // Layout constants
  static const double _digitWidth = 40.0;
  static const double _digitHeight = 40.0;
  static const double _arrowSize = 24.0;

  static const double _colonWidth = 20.0;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    // Structure:
    //  [ ^ ]       [ ^ ]
    //  [ HH ]  :   [ MM ]
    //  [ v ]       [ v ]

    // width was unused
    // (_digitWidth * 2) + ...

    // Let's say: Arrow(40) HH(40) Arrow(40) -> Vertical stack
    // Total Width = DigitWidth + Colon + DigitWidth = 40 + 20 + 40 = 100
    // Height = Arrow + Spacing + Digit + Spacing + Arrow = 24 + 4 + 40 + 4 + 24 = 96

    size = constraints.constrain(Size(100, 96));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Hour Column
    _paintColumn(context, offset, _time.hour, 0, 23, true);

    // Colon
    textPainter.text = const TextSpan(
      text: ":",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      offset +
          Offset(
            _digitWidth + (_colonWidth - textPainter.width) / 2,
            (_arrowSize * 2 + 8 + _digitHeight) / 2 - textPainter.height / 2,
          ),
    );

    // Minute Column
    _paintColumn(
      context,
      offset + Offset(_digitWidth + _colonWidth, 0),
      _time.minute,
      0,
      59,
      false,
    );
  }

  void _paintColumn(
    PaintingContext context,
    Offset baseOffset,
    int value,
    int min,
    int max,
    bool isHour,
  ) {
    final canvas = context.canvas;
    // Up Arrow
    _paintArrow(
      canvas,
      baseOffset + Offset((_digitWidth - _arrowSize) / 2, 0),
      true,
    );

    // Value Box
    final boxRect = Rect.fromLTWH(
      baseOffset.dx,
      baseOffset.dy + _arrowSize + 4,
      _digitWidth,
      _digitHeight,
    );
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFE0E0E0);
    canvas.drawRect(boxRect, borderPaint);

    // Value Text
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: value.toString().padLeft(2, '0'),
      style: const TextStyle(fontSize: 24, color: Color(0xFF000000)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      boxRect.center - (textPainter.size / 2).getOffset(),
    );

    // Down Arrow
    _paintArrow(
      canvas,
      baseOffset + Offset((_digitWidth - _arrowSize) / 2, boxRect.bottom + 4),
      false,
    );
  }

  void _paintArrow(Canvas canvas, Offset offset, bool up) {
    final paint = Paint()..color = const Color(0xFF000000);
    final path = Path();
    if (up) {
      path.moveTo(offset.dx + _arrowSize / 2, offset.dy);
      path.lineTo(offset.dx, offset.dy + _arrowSize);
      path.lineTo(offset.dx + _arrowSize, offset.dy + _arrowSize);
    } else {
      path.moveTo(offset.dx, offset.dy);
      path.lineTo(offset.dx + _arrowSize, offset.dy);
      path.lineTo(offset.dx + _arrowSize / 2, offset.dy + _arrowSize);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    // Check Hour Column
    if (local.dx >= 0 && local.dx <= _digitWidth) {
      _handleColumnTap(local.dy, true);
    }
    // Check Minute Column
    else if (local.dx >= _digitWidth + _colonWidth &&
        local.dx <= _digitWidth + _colonWidth + _digitWidth) {
      _handleColumnTap(local.dy, false);
    }
  }

  void _handleColumnTap(double dy, bool isHour) {
    // Up arrow area: 0 to _arrowSize
    // Down arrow area: _arrowSize + 4 + _digitHeight + 4 to end

    final downStart = _arrowSize + 4 + _digitHeight + 4;

    if (dy <= _arrowSize + 10) {
      // generous target
      _changeValue(isHour, 1);
    } else if (dy >= downStart - 10) {
      _changeValue(isHour, -1);
    }
  }

  void _changeValue(bool isHour, int delta) {
    if (isHour) {
      int v = _time.hour + delta;
      if (v > 23) v = 0;
      if (v < 0) v = 23;
      _time = _time.replacing(hour: v);
    } else {
      int v = _time.minute + delta;
      if (v > 59) v = 0;
      if (v < 0) v = 59;
      _time = _time.replacing(minute: v);
    }
    _onTimeChanged(_time);
    markNeedsPaint();
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

extension on Size {
  Offset getOffset() => Offset(width, height);
}
