import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import '../foundation/status.dart';
import '../theme/customization.dart';
import '../theme/theme.dart';
import 'button.dart';
import 'layout.dart';

/// A Date Picker widget.
class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.tag,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? tag;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = widget.selectedDate ?? DateTime.now();
    if (_displayedMonth.isBefore(widget.firstDate)) {
      _displayedMonth = widget.firstDate;
    } else if (_displayedMonth.isAfter(widget.lastDate)) {
      _displayedMonth = widget.lastDate;
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + offset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDatePicker(widget.tag);

    final status = DatePickerControlStatus();
    final decoration =
        customization?.decoration(status) ??
        const BoxDecoration(color: Color(0xFFFFFFFF));
    final textStyle = customization?.textStyle(status) ?? const TextStyle();

    return LayoutBox(
      padding: customization?.cellPadding ?? const EdgeInsets.all(16),
      child: _DatePickerContainerRenderWidget(
        decoration: decoration is BoxDecoration
            ? decoration
            : const BoxDecoration(),
        child: FlexBox(
          direction: Axis.vertical,
          children: [
            // Header
            LayoutBox(
              padding: customization?.headerPadding ?? EdgeInsets.zero,
              child: FlexBox(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button(
                    tag: 'icon',
                    onPressed: () => _changeMonth(-1),
                    child: const Text("<"),
                  ),
                  DefaultTextStyle(
                    style: customization?.headerTextStyle ?? textStyle,
                    child: Text(_formatMonthYear(_displayedMonth)),
                  ),
                  Button(
                    tag: 'icon',
                    onPressed: () => _changeMonth(1),
                    child: const Text(">"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Weekdays
            FlexBox(
              direction: Axis.horizontal,
              children: _weekdays
                  .map(
                    (w) => LayoutBox(
                      width:
                          40, // Assuming fixed width for weekdays too or flexible
                      child: Center(
                        child: Text(
                          w,
                          style:
                              customization?.weekdayTextStyle ??
                              textStyle.copyWith(
                                color: textStyle.color?.withValues(alpha: 0.7),
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            // Days Grid (RenderObject)
            _DateGridRenderWidget(
              displayedMonth: _displayedMonth,
              selectedDate: widget.selectedDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              customization:
                  customization?.dayCustomization ??
                  DateCellCustomization(
                    decoration: (_) => const BoxDecoration(),
                    textStyle: (_) => const TextStyle(),
                  ),
              onDateSelected: widget.onChanged,
            ),
          ],
        ),
      ),
    );
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

  static const _weekdays = ["M", "T", "W", "T", "F", "S", "S"];
}

class _DatePickerContainerRenderWidget extends SingleChildRenderObjectWidget {
  const _DatePickerContainerRenderWidget({
    super.child,
    required this.decoration,
  });
  final BoxDecoration decoration;

  @override
  RenderDatePickerContainer createRenderObject(BuildContext context) =>
      RenderDatePickerContainer(decoration: decoration);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderDatePickerContainer renderObject,
  ) {
    renderObject.decoration = decoration;
  }
}

class RenderDatePickerContainer extends RenderProxyBox {
  RenderDatePickerContainer({required BoxDecoration decoration})
    : _decoration = decoration;
  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFFFFFFF);
    if (decoration.borderRadius != null) {
      context.canvas.drawRRect(
        decoration.borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
        paint,
      );
    } else {
      context.canvas.drawRect(rect, paint);
    }
    if (child != null) context.paintChild(child!, offset);
  }
}

class _DateGridRenderWidget extends LeafRenderObjectWidget {
  const _DateGridRenderWidget({
    required this.displayedMonth,
    this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.customization,
    required this.onDateSelected,
  });

  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateCellCustomization customization;
  final ValueChanged<DateTime> onDateSelected;

  @override
  RenderDateGrid createRenderObject(BuildContext context) {
    return RenderDateGrid(
      displayedMonth: displayedMonth,
      selectedDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      customization: customization,
      onDateSelected: onDateSelected,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderDateGrid renderObject,
  ) {
    renderObject
      ..displayedMonth = displayedMonth
      ..selectedDate = selectedDate
      ..firstDate = firstDate
      ..lastDate = lastDate
      ..customization = customization
      ..onDateSelected = onDateSelected;
  }
}

class RenderDateGrid extends RenderBox {
  RenderDateGrid({
    required DateTime displayedMonth,
    DateTime? selectedDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required DateCellCustomization customization,
    required this.onDateSelected,
  }) : _displayedMonth = displayedMonth,
       _selectedDate = selectedDate,
       _firstDate = firstDate,
       _lastDate = lastDate,
       _customization = customization;

  DateTime _displayedMonth;
  DateTime get displayedMonth => _displayedMonth;
  set displayedMonth(DateTime value) {
    if (_displayedMonth == value) return;
    _displayedMonth = value;
    markNeedsPaint();
  }

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;
  set selectedDate(DateTime? value) {
    if (_selectedDate == value) return;
    _selectedDate = value;
    markNeedsPaint();
  }

  DateTime _firstDate;
  DateTime get firstDate => _firstDate;
  set firstDate(DateTime value) {
    _firstDate = value;
    markNeedsPaint();
  }

  DateTime _lastDate;
  DateTime get lastDate => _lastDate;
  set lastDate(DateTime value) {
    _lastDate = value;
    markNeedsPaint();
  }

  DateCellCustomization _customization;
  DateCellCustomization get customization => _customization;
  set customization(DateCellCustomization value) {
    _customization = value;
    markNeedsPaint();
  }

  ValueChanged<DateTime> onDateSelected;

  int? _hoveredIndex;

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, 240),
    ); // Fixed height for 6 rows of 40
  }

  bool _isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double cellWidth = size.width / 7;
    final double cellHeight = size.height / 6;

    final firstDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    final weekdayOffset = firstDayOfMonth.weekday - 1;
    final start = firstDayOfMonth.subtract(Duration(days: weekdayOffset));

    for (int i = 0; i < 42; i++) {
      final date = start.add(Duration(days: i));
      final int row = i ~/ 7;
      final int col = i % 7;
      final Rect cellRect =
          (offset + Offset(col * cellWidth, row * cellHeight)) &
          Size(cellWidth, cellHeight);

      final status = DateCellControlStatus();
      status.selected = _isSameDay(date, selectedDate) ? 1.0 : 0.0;
      status.today = _isSameDay(date, DateTime.now()) ? 1.0 : 0.0;
      status.currentMonth = date.month == displayedMonth.month ? 1.0 : 0.0;
      status.enabled = (date.isBefore(firstDate) || date.isAfter(lastDate))
          ? 0.0
          : 1.0;
      status.hovered = _hoveredIndex == i ? 1.0 : 0.0;

      final decoration = customization.decoration(status);
      final textStyle = customization.textStyle(status);

      // Paint cell background
      final Paint paint = Paint();
      if (decoration is BoxDecoration) {
        paint.color = decoration.color ?? const Color(0x00000000);
        if (decoration.borderRadius != null) {
          context.canvas.drawRRect(
            decoration.borderRadius!
                .resolve(TextDirection.ltr)
                .toRRect(cellRect),
            paint,
          );
        } else {
          context.canvas.drawRect(cellRect, paint);
        }
      } else {
        context.canvas.drawRect(
          cellRect,
          paint..color = const Color(0x00000000),
        );
      }

      // Paint text
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: "${date.day}", style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        context.canvas,
        cellRect.center - (textPainter.size / 2).getOffset(),
      );
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent || event is PointerDownEvent) {
      final double cellWidth = size.width / 7;
      final double cellHeight = size.height / 6;
      final int col = (event.localPosition.dx / cellWidth).floor();
      final int row = (event.localPosition.dy / cellHeight).floor();
      final int index = (row * 7 + col).clamp(0, 41);

      if (event is PointerHoverEvent) {
        if (_hoveredIndex != index) {
          _hoveredIndex = index;
          markNeedsPaint();
        }
      } else if (event is PointerDownEvent) {
        final firstDayOfMonth = DateTime(
          displayedMonth.year,
          displayedMonth.month,
          1,
        );
        final weekdayOffset = firstDayOfMonth.weekday - 1;
        final date = firstDayOfMonth
            .subtract(Duration(days: weekdayOffset))
            .add(Duration(days: index));
        if (!date.isBefore(firstDate) && !date.isAfter(lastDate)) {
          onDateSelected(date);
        }
      }
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

extension on Size {
  Offset getOffset() => Offset(width, height);
}
