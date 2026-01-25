import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';


/// A widget for selecting a date range.
class DateRangePicker extends LeafRenderObjectWidget {
  const DateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onRangeSelected,
    this.firstDate,
    this.lastDate,
    this.tag,
  });

  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final void Function(DateTime start, DateTime end) onRangeSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? tag;

  @override
  RenderDateRangePicker createRenderObject(BuildContext context) {
    return RenderDateRangePicker(
      startDate: initialStartDate,
      endDate: initialEndDate,
      onRangeSelected: onRangeSelected,
      firstDate: firstDate,
      lastDate: lastDate,
      tag: tag,
      // customization...
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDateRangePicker renderObject,
  ) {
    renderObject
      ..startDate =
          initialStartDate // note: only updating if changed from outside?
      ..endDate = initialEndDate
      ..onRangeSelected = onRangeSelected
      ..firstDate = firstDate
      ..lastDate = lastDate
      ..tag = tag;
  }
}

class RenderDateRangePicker extends RenderBox {
  RenderDateRangePicker({
    DateTime? startDate,
    DateTime? endDate,
    required void Function(DateTime, DateTime) onRangeSelected,
    DateTime? firstDate,
    DateTime? lastDate,
    String? tag,
  }) : _startDate = startDate,
       _endDate = endDate,
       _onRangeSelected = onRangeSelected,
       _firstDate = firstDate,
       _lastDate = lastDate,
       _tag = tag {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _displayMonth = _startDate ?? DateTime.now();
  }

  DateTime? _startDate;
  set startDate(DateTime? value) {
    // If controlled externally?
    if (_startDate != value) {
      _startDate = value;
      markNeedsPaint();
    }
  }

  DateTime? _endDate;
  set endDate(DateTime? value) {
    if (_endDate != value) {
      _endDate = value;
      markNeedsPaint();
    }
  }

  void Function(DateTime, DateTime) _onRangeSelected;
  set onRangeSelected(void Function(DateTime, DateTime) value) {
    _onRangeSelected = value;
  }

  DateTime? _firstDate;
  set firstDate(DateTime? value) {
    _firstDate = value;
    markNeedsPaint();
  }

  DateTime? _lastDate;
  set lastDate(DateTime? value) {
    _lastDate = value;
    markNeedsPaint();
  }

  String? _tag;
  set tag(String? value) {
    _tag = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;

  late DateTime _displayMonth;
  bool _selectingStart = true;

  // Metrics
  Rect _headerStartRect = Rect.zero;
  Rect _headerEndRect = Rect.zero;
  Rect _prevRect = Rect.zero;
  Rect _nextRect = Rect.zero;
  Rect _gridRect = Rect.zero;

  double _cellWidth = 40;
  double _cellHeight = 40;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    // Width: constrained or fixed 320
    final w = constraints.constrainWidth(320);

    // Header: Start(Expanded) -> End(Expanded)
    // Height: 60
    final headerHeight = 60.0;

    // Nav: < Month >
    final navHeight = 40.0;

    // Grid: 7 cols
    _cellWidth = (w - 16) / 7; // 8 padding each side
    if (_cellWidth > 40) _cellWidth = 40;
    _cellHeight = _cellWidth;

    final gridHeight = _cellHeight * 6; // 6 rows

    final h = headerHeight + navHeight + 20 + gridHeight + 16;

    size = constraints.constrain(Size(w, h));

    // Rects
    final halfW = (w - 32) / 2; // minus padding/spacing
    _headerStartRect = Rect.fromLTWH(8, 8, halfW, 44);
    _headerEndRect = Rect.fromLTWH(w - 8 - halfW, 8, halfW, 44);

    final navTop = headerHeight + 8;
    _prevRect = Rect.fromLTWH(8, navTop, 40, 40);
    _nextRect = Rect.fromLTWH(w - 8 - 40, navTop, 40, 40);

    final gridTop = navTop + navHeight + 10;
    final gridContentW = _cellWidth * 7;
    _gridRect = Rect.fromLTWH(
      (w - gridContentW) / 2,
      gridTop,
      gridContentW,
      gridHeight,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    // Bg
    final paint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(offset & size, paint);

    // Draw Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFE0E0E0);
    canvas.drawRect(offset & size, borderPaint);

    // Header Background
    final headerBgRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, 60);
    canvas.drawRect(headerBgRect, Paint()..color = const Color(0xFFF5F5F5));
    canvas.drawLine(
      headerBgRect.bottomLeft,
      headerBgRect.bottomRight,
      borderPaint,
    );

    // Header Buttons
    _paintEndpoint(
      canvas,
      offset,
      _headerStartRect,
      "Start",
      _startDate,
      _selectingStart,
    );
    _paintEndpoint(
      canvas,
      offset,
      _headerEndRect,
      "End",
      _endDate,
      !_selectingStart,
    );

    // Nav
    _paintNav(canvas, offset);

    // Grid
    _paintGrid(canvas, offset);
  }

  void _paintEndpoint(
    Canvas canvas,
    Offset offset,
    Rect rect,
    String label,
    DateTime? date,
    bool active,
  ) {
    final absRect = rect.shift(offset);
    final paint = Paint()
      ..color = active
          ? const Color(0xFFE3F2FD)
          : const Color(0x00000000); // Transparent if inactive? Or white?
    // box decoration
    canvas.drawRRect(
      RRect.fromRectAndRadius(absRect, const Radius.circular(4)),
      paint,
    );

    if (active) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF2196F3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(absRect, const Radius.circular(4)),
        p,
      );
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    // Label
    textPainter.text = TextSpan(
      text: label,
      style: TextStyle(
        fontSize: 10,
        color: active ? const Color(0xFF2196F3) : const Color(0xFF999999),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, absRect.topLeft + const Offset(8, 8));

    // Date
    String dText = date != null
        ? "${date.month}/${date.day}/${date.year}"
        : "--/--/----";
    textPainter.text = TextSpan(
      text: dText,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: active ? const Color(0xFF2196F3) : const Color(0xFF333333),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, absRect.topLeft + const Offset(8, 22));
  }

  void _paintNav(Canvas canvas, Offset offset) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Prev
    textPainter.text = const TextSpan(
      text: "<",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF757575),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      offset + _prevRect.center - (textPainter.size / 2).getOffset(),
    );

    // Next
    textPainter.text = const TextSpan(
      text: ">",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF757575),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      offset + _nextRect.center - (textPainter.size / 2).getOffset(),
    );

    // Title
    final title = _formatMonthYear(_displayMonth);
    textPainter.text = TextSpan(
      text: title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
    textPainter.layout();
    final titleY =
        offset.dy +
        _prevRect.top +
        _prevRect.height / 2 -
        textPainter.height / 2;
    final titleX = offset.dx + size.width / 2 - textPainter.width / 2;
    textPainter.paint(canvas, Offset(titleX, titleY));
  }

  void _paintGrid(Canvas canvas, Offset offset) {
    final firstDayOfMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month,
      1,
    );
    final weekdayOffset =
        firstDayOfMonth.weekday %
        7; // standard grid often starts Sunday? Weekdays list in prev file was M T W T F S S?
    // _RangeCalendarGrid used weekday%7 which usually implies Sunday start if M=1.
    // The list in previous file: S M T W T F S.
    // So Sunday start.

    // Header
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final headerY = offset.dy + _prevRect.bottom + 4;
    for (int i = 0; i < 7; i++) {
      textPainter.text = TextSpan(
        text: days[i],
        style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
      );
      textPainter.layout();
      final dx =
          offset.dx +
          _gridRect.left +
          (i * _cellWidth) +
          (_cellWidth - textPainter.width) / 2;
      textPainter.paint(canvas, Offset(dx, headerY));
    }

    // Cells
    final daysInMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month + 1,
      0,
    ).day;

    for (int i = 0; i < daysInMonth + weekdayOffset; i++) {
      if (i < weekdayOffset) continue;

      final day = i - weekdayOffset + 1;
      final date = DateTime(_displayMonth.year, _displayMonth.month, day);

      final int row = i ~/ 7;
      final int col = i % 7;
      final dx = offset.dx + _gridRect.left + (col * _cellWidth);
      final dy = offset.dy + _gridRect.top + (row * _cellHeight);
      final cellRect = Rect.fromLTWH(dx, dy, _cellWidth, _cellHeight);

      // Logic
      bool isStart = _startDate != null && _isSameDay(date, _startDate!);
      bool isEnd = _endDate != null && _isSameDay(date, _endDate!);
      bool inRange = _isInRange(date);
      bool isDisabled =
          (_firstDate != null && date.isBefore(_firstDate!)) ||
          (_lastDate != null && date.isAfter(_lastDate!));

      // Paint
      final paint = Paint();
      if (isStart || isEnd) {
        paint.color = const Color(0xFF2196F3);
        // Rounded corners logic
        // Simplified RRect
        canvas.drawRRect(
          RRect.fromRectAndRadius(cellRect, const Radius.circular(16)),
          paint,
        );
      } else if (inRange) {
        paint.color = const Color(0xFFE3F2FD);
        canvas.drawRect(cellRect, paint);
      }

      // Text
      textPainter.text = TextSpan(
        text: "$day",
        style: TextStyle(
          fontSize: 12,
          color: isDisabled
              ? const Color(0xFFBDBDBD)
              : (isStart || isEnd
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF000000)),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        cellRect.center - (textPainter.size / 2).getOffset(),
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime date) {
    if (_startDate == null) return false;
    if (_endDate == null) return _isSameDay(date, _startDate!);
    return !date.isBefore(_startDate!) && !date.isAfter(_endDate!);
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    if (_headerStartRect.contains(local)) {
      _selectingStart = true;
      markNeedsPaint();
    } else if (_headerEndRect.contains(local)) {
      _selectingStart = false;
      markNeedsPaint();
    } else if (_prevRect.contains(local)) {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
      markNeedsPaint();
    } else if (_nextRect.contains(local)) {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      markNeedsPaint();
    } else if (_gridRect.contains(local)) {
      final rel = local - _gridRect.topLeft;
      final col = (rel.dx / _cellWidth).floor();
      final row = (rel.dy / _cellHeight).floor();

      // Calc day
      final firstDayOfMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month,
        1,
      );
      final weekdayOffset = firstDayOfMonth.weekday % 7;
      final idx = row * 7 + col;
      final day = idx - weekdayOffset + 1;

      final daysInMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month + 1,
        0,
      ).day;

      if (day >= 1 && day <= daysInMonth) {
        final date = DateTime(_displayMonth.year, _displayMonth.month, day);
        _handleDateSelection(date);
      }
    }
  }

  void _handleDateSelection(DateTime date) {
    // Logic
    // If selecting start
    if (_selectingStart) {
      _startDate = date;
      _endDate = null;
      _selectingStart = false; // Auto switch to end
      markNeedsPaint();
    } else {
      if (_startDate != null && date.isBefore(_startDate!)) {
        _endDate = _startDate;
        _startDate = date;
      } else {
        _endDate = date;
      }
      _selectingStart = true;
      markNeedsPaint();

      if (_startDate != null && _endDate != null) {
        _onRangeSelected(_startDate!, _endDate!);
      }
    }
  }

  String _formatMonthYear(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[d.month - 1]} ${d.year}";
  }

  @override
  bool hitTestSelf(Offset position) => true; // To catch taps

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) _tap.addPointer(event);
  }
}

extension on Size {
  Offset getOffset() => Offset(width, height);
}
