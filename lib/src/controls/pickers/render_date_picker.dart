// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/customization.dart';
import 'package:blankcanvas/src/theme/theme.dart';

class RenderDatePicker extends RenderBox {
  RenderDatePicker({
    DateTime? selectedDate,
    required ValueChanged<DateTime> onChanged,
    required DateTime firstDate,
    required DateTime lastDate,
    String? tag,
    DatePickerCustomization? customization,
  }) : _selectedDate = selectedDate,
       _onChanged = onChanged,
       _firstDate = firstDate,
       _lastDate = lastDate,
       _tag = tag,
       _customization = customization {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;

    // Init Displayed Month
    _displayedMonth = _selectedDate ?? DateTime.now();
    if (_displayedMonth.isBefore(_firstDate)) _displayedMonth = _firstDate;
  }

  late DateTime _displayedMonth;

  DateTime? _selectedDate;
  set selectedDate(DateTime? value) {
    if (_selectedDate != value) {
      _selectedDate = value;
      markNeedsPaint();
    }
  }

  ValueChanged<DateTime> _onChanged;
  set onChanged(ValueChanged<DateTime> value) {
    _onChanged = value;
  }

  DateTime _firstDate;
  set firstDate(DateTime value) {
    _firstDate = value;
    markNeedsPaint();
  }

  DateTime _lastDate;
  set lastDate(DateTime value) {
    _lastDate = value;
    markNeedsPaint();
  }

  String? _tag;
  set tag(String? value) {
    if (_tag != value) {
      _tag = value;
      markNeedsPaint();
    }
  }

  DatePickerCustomization? _customization;
  set customization(DatePickerCustomization? value) {
    if (_customization != value) {
      _customization = value;
      markNeedsLayout(); // Padding might change
    }
  }

  late TapGestureRecognizer _tap;

  // Layout Metrics
  final double _headerHeight = 40.0;
  final double _weekdaysHeight = 30.0;
  double _cellWidth = 40.0;
  double _cellHeight = 40.0;
  Rect _prevRect = Rect.zero;
  Rect _nextRect = Rect.zero;
  Rect _gridRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final customization = _customization ?? DatePickerCustomization.simple();
    final padding =
        customization.cellPadding?.resolve(TextDirection.ltr) ??
        const EdgeInsets.all(16.0); // Outer padding really

    // Fixed width preferred? Or constrained?
    // Grid is 7 cols.
    _cellWidth = (constraints.maxWidth - padding.horizontal) / 7;
    // Clamp cell width?
    if (_cellWidth > 50) _cellWidth = 50;

    final contentWidth = _cellWidth * 7;
    final totalWidth = contentWidth + padding.horizontal;

    // Heights
    // Header: 40
    // Weekdays: 30
    // Grid: 6 rows * _cellWidth (aspect ratio 1:1 usually) or fixed 40?
    _cellHeight = _cellWidth;
    final gridHeight = _cellHeight * 6;

    final totalHeight =
        padding.vertical +
        _headerHeight +
        10 +
        _weekdaysHeight +
        10 +
        gridHeight;

    // Calculate rects
    final top = padding.top;

    // Header Buttons
    _prevRect = Rect.fromLTWH(padding.left, top, 40, 40);
    _nextRect = Rect.fromLTWH(totalWidth - padding.right - 40, top, 40, 40);

    _gridRect = Rect.fromLTWH(
      padding.left,
      top + _headerHeight + 10 + _weekdaysHeight + 10,
      contentWidth,
      gridHeight,
    );

    size = constraints.constrain(Size(totalWidth, totalHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final customization = _customization ?? DatePickerCustomization.simple();
    final padding =
        customization.cellPadding?.resolve(TextDirection.ltr) ??
        const EdgeInsets.all(16.0);

    // Background
    final status = DatePickerControlStatus(); // basic status
    final decoration = customization.decoration(status);
    if (decoration is BoxDecoration) {
      final paint = Paint()
        ..color = decoration.color ?? const Color(0xFFFFFFFF);
      canvas.drawRect(offset & size, paint); // Bg
    }

    // Header
    _paintHeader(canvas, offset);

    // Weekdays
    _paintWeekdays(
      canvas,
      offset + Offset(padding.left, padding.top + _headerHeight + 10),
    );

    // Grid
    _paintGrid(canvas, offset + Offset(_gridRect.left, _gridRect.top));
  }

  void _paintHeader(Canvas canvas, Offset offset) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Prev Button
    textPainter.text = TextSpan(
      text: "<",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF757575),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      offset + _prevRect.center - (textPainter.size / 2).getOffset(),
    );

    // Next Button
    textPainter.text = TextSpan(
      text: ">",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF757575),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      offset + _nextRect.center - (textPainter.size / 2).getOffset(),
    );

    // Title
    final title = _formatMonthYear(_displayedMonth);
    textPainter.text = TextSpan(
      text: title,
      style:
          _customization?.headerTextStyle ??
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
          ),
    );
    textPainter.layout();

    final titleX = offset.dx + size.width / 2 - textPainter.width / 2;
    final titleY =
        offset.dy +
        _prevRect.top +
        _prevRect.height / 2 -
        textPainter.height / 2;
    textPainter.paint(canvas, Offset(titleX, titleY));
  }

  void _paintWeekdays(Canvas canvas, Offset offset) {
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final style =
        _customization?.weekdayTextStyle ??
        const TextStyle(color: Color(0xFF757575));

    for (int i = 0; i < 7; i++) {
      textPainter.text = TextSpan(text: days[i], style: style);
      textPainter.layout();
      final dx =
          offset.dx + (i * _cellWidth) + (_cellWidth - textPainter.width) / 2;
      final dy = offset.dy + (_weekdaysHeight - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  void _paintGrid(Canvas canvas, Offset offset) {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final weekdayOffset = firstDayOfMonth.weekday - 1;
    final start = firstDayOfMonth.subtract(Duration(days: weekdayOffset));

    for (int i = 0; i < 42; i++) {
      final date = start.add(Duration(days: i));
      final int row = i ~/ 7;
      final int col = i % 7;

      final dx = offset.dx + (col * _cellWidth);
      final dy = offset.dy + (row * _cellHeight);
      final cellRect = Rect.fromLTWH(dx, dy, _cellWidth, _cellHeight);

      bool isSelected = _isSameDay(date, _selectedDate);
      bool isToday = _isSameDay(date, DateTime.now());
      bool isCurrentMonth = date.month == _displayedMonth.month;
      bool isEnabled = !date.isBefore(_firstDate) && !date.isAfter(_lastDate);

      final status = DateCellControlStatus();
      status.selected = isSelected ? 1.0 : 0.0;
      status.today = isToday ? 1.0 : 0.0;
      status.currentMonth = isCurrentMonth ? 1.0 : 0.0;
      status.enabled = isEnabled ? 1.0 : 0.0;
      status.hovered = 0.0; // No hover effect

      final cust =
          _customization?.dayCustomization ?? DateCellCustomization.simple();
      final decoration = cust.decoration(status);
      final textStyle = cust.textStyle(status);

      final paint = Paint();

      if (decoration is BoxDecoration) {
        paint.color = decoration.color ?? const Color(0x00000000);
        if (decoration.borderRadius != null) {
          canvas.drawRRect(
            decoration.borderRadius!
                .resolve(TextDirection.ltr)
                .toRRect(cellRect),
            paint,
          );
        } else {
          canvas.drawRect(cellRect, paint);
        }
        if (decoration.border != null) {
          final border = decoration.border as Border;
          final borderPaint = Paint()
            ..style = PaintingStyle.stroke
            ..color = border.top.color;
          // Simplistic border handling
          if (decoration.shape == BoxShape.circle) {
            canvas.drawCircle(cellRect.center, cellRect.width / 2, borderPaint);
          }
        }
      }

      final textPainter = TextPainter(
        text: TextSpan(text: "${date.day}", style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        cellRect.center - (textPainter.size / 2).getOffset(),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    if (_prevRect.contains(local)) {
      _changeMonth(-1);
    } else if (_nextRect.contains(local)) {
      _changeMonth(1);
    } else if (_gridRect.contains(local)) {
      final rel = local - _gridRect.topLeft;
      final int col = (rel.dx / _cellWidth).floor();
      final int row = (rel.dy / _cellHeight).floor();
      final index = (row * 7 + col).clamp(0, 41);

      _selectSortOfIndex(index);
    }
  }

  void _changeMonth(int offset) {
    _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + offset,
    );
    // Ensure bound?
    if (_displayedMonth.isBefore(_firstDate)) {
      _displayedMonth = _firstDate; // Simplistic
    }
    // Actually month navigation can go freely, but selection is restricted.
    markNeedsPaint();
  }

  void _selectSortOfIndex(int index) {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final weekdayOffset = firstDayOfMonth.weekday - 1;
    final start = firstDayOfMonth.subtract(Duration(days: weekdayOffset));
    final date = start.add(Duration(days: index));

    if (!date.isBefore(_firstDate) && !date.isAfter(_lastDate)) {
      _onChanged(date);
    }
  }

  String _formatMonthYear(DateTime d) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${months[d.month - 1]} ${d.year}";
  }

  bool _isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
