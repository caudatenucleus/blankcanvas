import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that displays a monthly calendar using lowest-level RenderObject APIs.
class Calendar extends LeafRenderObjectWidget {
  const Calendar({
    super.key,
    required this.initialDate,
    this.onDateSelected,
    this.events = const {},
    this.tag,
  });

  final DateTime initialDate;
  final ValueChanged<DateTime>? onDateSelected;
  final Map<DateTime, List<String>> events;
  final String? tag;

  @override
  RenderCalendar createRenderObject(BuildContext context) {
    return RenderCalendar(
      initialDate: initialDate,
      onDateSelected: onDateSelected,
      events: events,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCalendar renderObject) {
    renderObject
      ..onDateSelected = onDateSelected
      ..events = events;
    // Note: We don't update initialDate usually as it resets view.
    // Unless we want controlled component.
    // For now, assume initialDate is just that - initial.
  }
}

class RenderCalendar extends RenderBox {
  RenderCalendar({
    required DateTime initialDate,
    ValueChanged<DateTime>? onDateSelected,
    Map<DateTime, List<String>> events = const {},
  }) : _displayedMonth = DateTime(initialDate.year, initialDate.month),
       _selectedDate = initialDate,
       _onDateSelected = onDateSelected,
       _events = events {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  DateTime _displayedMonth;
  DateTime _selectedDate;

  ValueChanged<DateTime>? _onDateSelected;
  set onDateSelected(ValueChanged<DateTime>? value) {
    _onDateSelected = value;
  }

  Map<DateTime, List<String>> _events;
  set events(Map<DateTime, List<String>> value) {
    if (_events == value) return;
    _events = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;

  // Layout Constants
  static const double _headerHeight = 40.0;
  static const double _dayHeaderHeight = 24.0;

  // Hit regions
  Rect? _prevArrowRect;
  Rect? _nextArrowRect;
  final List<Rect> _dayRects = [];
  final List<DateTime> _dayDates = [];

  @override
  void performLayout() {
    double width = constraints.maxWidth;
    if (width.isInfinite) width = 320.0; // Default width

    // Grid calculations
    // 7 columns.
    final double cellWidth = width / 7;
    // Rows depend on month.
    final int daysInMonth = _getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final int firstWeekday =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;
    final int totalCells = firstWeekday + daysInMonth;
    final int rows = (totalCells / 7).ceil();

    final double height =
        _headerHeight +
        _dayHeaderHeight +
        (rows * cellWidth); // Aspect ratio 1:1 for cells?

    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final double width = size.width;
    final double cellWidth = width / 7;
    final double cellHeight = cellWidth; // Square cells

    // 1. Paint Header
    _paintHeader(canvas, offset, width);

    // 2. Paint Days Header
    _paintDaysHeader(canvas, offset, width, cellWidth);

    // 3. Paint Grid
    _dayRects.clear();
    _dayDates.clear();

    final int daysInMonth = _getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final int firstWeekday =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;

    final Paint selectedPaint = Paint()..color = const Color(0xFF2196F3);
    final Paint todayBorderPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint eventPaint = Paint()..color = const Color(0xFFFF5252);
    final Paint eventSelectedPaint = Paint()..color = const Color(0xFFFFFFFF);

    double currentY = offset.dy + _headerHeight + _dayHeaderHeight;

    for (int i = 0; i < daysInMonth; i++) {
      final int gridIndex = firstWeekday + i;
      final int row = gridIndex ~/ 7;
      final int col = gridIndex % 7;

      final double x = offset.dx + col * cellWidth;
      final double y = currentY + row * cellHeight;

      final Rect cellRect = Rect.fromLTWH(x, y, cellWidth, cellHeight);
      final DateTime date = DateTime(
        _displayedMonth.year,
        _displayedMonth.month,
        i + 1,
      );

      _dayRects.add(cellRect);
      _dayDates.add(date);

      // Check selection
      final bool isSelected = _isSameDay(date, _selectedDate);
      final bool isToday = _isSameDay(date, DateTime.now());
      final bool hasEvents = _events.keys.any((d) => _isSameDay(d, date));

      // Draw Selection
      if (isSelected) {
        canvas.drawCircle(cellRect.center, cellWidth / 2 - 4, selectedPaint);
      } else if (isToday) {
        canvas.drawCircle(cellRect.center, cellWidth / 2 - 4, todayBorderPaint);
      }

      // Draw Text
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF000000),
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        cellRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      // Draw Event Dot
      if (hasEvents) {
        final Paint dotPaint = isSelected ? eventSelectedPaint : eventPaint;
        canvas.drawCircle(
          cellRect.bottomCenter - const Offset(0, 6),
          2,
          dotPaint,
        );
      }
    }
  }

  void _paintHeader(Canvas canvas, Offset offset, double width) {
    // Month Name
    final String monthName = _getMonthName(_displayedMonth.month);
    final String text = '$monthName ${_displayedMonth.year}';

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF000000),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      offset + Offset((width - tp.width) / 2, (_headerHeight - tp.height) / 2),
    );

    // Arrows (Simple triangles or text "<" ">")
    final TextPainter prevTp = TextPainter(
      text: const TextSpan(
        text: '<',
        style: TextStyle(fontSize: 20, color: Color(0xFF000000)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final TextPainter nextTp = TextPainter(
      text: const TextSpan(
        text: '>',
        style: TextStyle(fontSize: 20, color: Color(0xFF000000)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset prevPos =
        offset + Offset(16, (_headerHeight - prevTp.height) / 2);
    final Offset nextPos =
        offset +
        Offset(width - 16 - nextTp.width, (_headerHeight - nextTp.height) / 2);

    prevTp.paint(canvas, prevPos);
    nextTp.paint(canvas, nextPos);

    // Hit/Touch targets (larger than text)
    _prevArrowRect = Rect.fromLTWH(offset.dx, offset.dy, 40, _headerHeight);
    _nextArrowRect = Rect.fromLTWH(
      offset.dx + width - 40,
      offset.dy,
      40,
      _headerHeight,
    );
  }

  void _paintDaysHeader(
    Canvas canvas,
    Offset offset,
    double width,
    double cellWidth,
  ) {
    const List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    double x = offset.dx;
    double y = offset.dy + _headerHeight;

    for (final day in days) {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: day,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF999999),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          x + (cellWidth - tp.width) / 2,
          y + (_dayHeaderHeight - tp.height) / 2,
        ),
      );
      x += cellWidth;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final Offset ps = details.localPosition;

    if (_prevArrowRect != null && _prevArrowRect!.contains(ps)) {
      _changeMonth(-1);
    } else if (_nextArrowRect != null && _nextArrowRect!.contains(ps)) {
      _changeMonth(1);
    } else {
      // Check cells
      for (int i = 0; i < _dayRects.length; i++) {
        if (_dayRects[i].contains(ps)) {
          _selectDate(_dayDates[i]);
          break;
        }
      }
    }
  }

  void _changeMonth(int offset) {
    _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + offset,
    );
    markNeedsLayout(); // Number of rows might change
    markNeedsPaint();
  }

  void _selectDate(DateTime date) {
    _selectedDate = date;
    _onDateSelected?.call(date);
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

  // Helpers
  int _getDaysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1).difference(DateTime(year, 12)).inDays;
    }
    return DateTime(year, month + 1).difference(DateTime(year, month)).inDays;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
