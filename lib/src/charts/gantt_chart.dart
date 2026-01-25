import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A Gantt chart task.
class GanttTask {
  const GanttTask({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    this.progress = 0.0,
    this.color,
  });
  final String id;
  final String name;
  final DateTime start;
  final DateTime end;
  final double progress;
  final Color? color;
}

/// A Gantt chart widget.
class GanttChart extends LeafRenderObjectWidget {
  const GanttChart({
    super.key,
    required this.tasks,
    this.onTaskTap,
    this.startDate,
    this.endDate,
    this.tag,
  });

  final List<GanttTask> tasks;
  final void Function(GanttTask task)? onTaskTap;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? tag;

  @override
  RenderGanttChart createRenderObject(BuildContext context) {
    return RenderGanttChart(
      tasks: tasks,
      onTaskTap: onTaskTap,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderGanttChart renderObject) {
    renderObject
      ..tasks = tasks
      ..onTaskTap = onTaskTap
      ..startDate = startDate
      ..endDate = endDate;
  }
}

class RenderGanttChart extends RenderBox {
  RenderGanttChart({
    required List<GanttTask> tasks,
    void Function(GanttTask task)? onTaskTap,
    DateTime? startDate,
    DateTime? endDate,
  }) : _tasks = tasks,
       _onTaskTap = onTaskTap,
       _startDate = startDate,
       _endDate = endDate {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<GanttTask> _tasks;
  set tasks(List<GanttTask> value) {
    _tasks = value;
    markNeedsLayout();
  }

  void Function(GanttTask task)? _onTaskTap;
  set onTaskTap(void Function(GanttTask task)? value) => _onTaskTap = value;

  DateTime? _startDate;
  set startDate(DateTime? value) {
    _startDate = value;
    markNeedsPaint();
  }

  DateTime? _endDate;
  set endDate(DateTime? value) {
    _endDate = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  String? _hoveredId;

  static const double _labelWidth = 120.0;
  static const double _rowHeight = 36.0;
  static const double _headerHeight = 32.0;

  final Map<String, Rect> _taskRects = {};

  DateTime get _chartStart =>
      _startDate ??
      _tasks.map((t) => t.start).reduce((a, b) => a.isBefore(b) ? a : b);
  DateTime get _chartEnd =>
      _endDate ??
      _tasks.map((t) => t.end).reduce((a, b) => a.isAfter(b) ? a : b);
  int get _totalDays => _chartEnd.difference(_chartStart).inDays + 1;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _taskRects.clear();
    final height = _headerHeight + _tasks.length * _rowHeight;
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final chartWidth = size.width - _labelWidth;
    final dayWidth = chartWidth / _totalDays;

    // Header with dates
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, _headerHeight),
      Paint()..color = const Color(0xFFE0E0E0),
    );

    // Draw month markers
    for (int d = 0; d < _totalDays; d += 7) {
      final date = _chartStart.add(Duration(days: d));
      final x = offset.dx + _labelWidth + d * dayWidth;

      canvas.drawLine(
        Offset(x, offset.dy + _headerHeight),
        Offset(x, offset.dy + size.height),
        Paint()
          ..color = const Color(0xFFEEEEEE)
          ..strokeWidth = 1,
      );

      textPainter.text = TextSpan(
        text: '${date.month}/${date.day}',
        style: const TextStyle(fontSize: 9, color: Color(0xFF666666)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 2, offset.dy + 8));
    }

    // Tasks
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final rowY = offset.dy + _headerHeight + i * _rowHeight;

      // Row background
      canvas.drawRect(
        Rect.fromLTWH(offset.dx, rowY, size.width, _rowHeight),
        Paint()
          ..color = i % 2 == 0
              ? const Color(0xFFFAFAFA)
              : const Color(0xFFFFFFFF),
      );

      // Task name
      textPainter.text = TextSpan(
        text: task.name,
        style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
      );
      textPainter.layout(maxWidth: _labelWidth - 16);
      textPainter.paint(
        canvas,
        Offset(offset.dx + 8, rowY + _rowHeight / 2 - textPainter.height / 2),
      );

      // Task bar
      final startOffset = task.start.difference(_chartStart).inDays;
      final duration = task.end.difference(task.start).inDays + 1;
      final barX = offset.dx + _labelWidth + startOffset * dayWidth;
      final barWidth = duration * dayWidth;
      final barRect = Rect.fromLTWH(barX, rowY + 6, barWidth, _rowHeight - 12);

      _taskRects[task.id] = Rect.fromLTWH(
        barX - offset.dx,
        rowY - offset.dy + 6,
        barWidth,
        _rowHeight - 12,
      );

      final isHovered = _hoveredId == task.id;
      final color = task.color ?? const Color(0xFF2196F3);

      // Background bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
        Paint()..color = color.withValues(alpha: 0.3),
      );

      // Progress bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            barRect.left,
            barRect.top,
            barRect.width * task.progress,
            barRect.height,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = color,
      );

      if (isHovered) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = color
            ..strokeWidth = 2,
        );
      }

      // Progress text
      textPainter.text = TextSpan(
        text: '${(task.progress * 100).toInt()}%',
        style: const TextStyle(fontSize: 10, color: Color(0xFFFFFFFF)),
      );
      textPainter.layout();
      if (barWidth > 40) {
        textPainter.paint(
          canvas,
          Offset(
            barRect.center.dx - textPainter.width / 2,
            barRect.center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (final entry in _taskRects.entries) {
      if (entry.value.contains(local)) {
        final task = _tasks.firstWhere((t) => t.id == entry.key);
        _onTaskTap?.call(task);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    String? hovered;
    for (final entry in _taskRects.entries) {
      if (entry.value.contains(local)) {
        hovered = entry.key;
        break;
      }
    }
    if (_hoveredId != hovered) {
      _hoveredId = hovered;
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
