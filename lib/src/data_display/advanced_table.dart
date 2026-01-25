import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Column definition for AdvancedTable.
class AdvancedTableColumn {
  const AdvancedTableColumn({
    required this.id,
    required this.title,
    this.width = 100.0,
  });
  final String id;
  final String title;
  final double width;
}

/// Row data for AdvancedTable.
class AdvancedTableRow {
  const AdvancedTableRow({required this.id, required this.cells});
  final String id;
  final Map<String, String> cells;
}

/// An advanced table widget with sticky header and horizontal scrolling.
class AdvancedTable extends LeafRenderObjectWidget {
  const AdvancedTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.headerColor = const Color(0xFFE0E0E0),
    this.rowColor = const Color(0xFFFFFFFF),
    this.hoverColor = const Color(0xFFF5F5F5),
    this.tag,
  });

  final List<AdvancedTableColumn> columns;
  final List<AdvancedTableRow> rows;
  final void Function(AdvancedTableRow row)? onRowTap;
  final Color headerColor;
  final Color rowColor;
  final Color hoverColor;
  final String? tag;

  @override
  RenderAdvancedTable createRenderObject(BuildContext context) {
    return RenderAdvancedTable(
      columns: columns,
      rows: rows,
      onRowTap: onRowTap,
      headerColor: headerColor,
      rowColor: rowColor,
      hoverColor: hoverColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAdvancedTable renderObject,
  ) {
    renderObject
      ..columns = columns
      ..rows = rows
      ..onRowTap = onRowTap
      ..headerColor = headerColor
      ..rowColor = rowColor
      ..hoverColor = hoverColor;
  }
}

class RenderAdvancedTable extends RenderBox {
  RenderAdvancedTable({
    required List<AdvancedTableColumn> columns,
    required List<AdvancedTableRow> rows,
    void Function(AdvancedTableRow row)? onRowTap,
    required Color headerColor,
    required Color rowColor,
    required Color hoverColor,
  }) : _columns = columns,
       _rows = rows,
       _onRowTap = onRowTap,
       _headerColor = headerColor,
       _rowColor = rowColor,
       _hoverColor = hoverColor {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _pan = PanGestureRecognizer()..onUpdate = _handlePanUpdate;
  }

  List<AdvancedTableColumn> _columns;
  set columns(List<AdvancedTableColumn> value) {
    _columns = value;
    markNeedsLayout();
  }

  List<AdvancedTableRow> _rows;
  set rows(List<AdvancedTableRow> value) {
    _rows = value;
    markNeedsLayout();
  }

  void Function(AdvancedTableRow row)? _onRowTap;
  set onRowTap(void Function(AdvancedTableRow row)? value) => _onRowTap = value;

  Color _headerColor;
  set headerColor(Color value) {
    _headerColor = value;
    markNeedsPaint();
  }

  Color _rowColor;
  set rowColor(Color value) {
    _rowColor = value;
    markNeedsPaint();
  }

  Color _hoverColor;
  set hoverColor(Color value) {
    _hoverColor = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  late PanGestureRecognizer _pan;
  int? _hoveredRow;

  double _scrollX = 0;
  double _scrollY = 0;
  static const double _headerHeight = 40.0;
  static const double _rowHeight = 30.0;

  @override
  void detach() {
    _tap.dispose();
    _pan.dispose();
    super.detach();
  }

  double get _totalWidth => _columns.fold(0, (sum, col) => sum + col.width);
  double get _totalHeight => _headerHeight + _rows.length * _rowHeight;

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxHeight.clamp(200, 500)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    canvas.save();
    canvas.clipRect(offset & size);

    // Draw rows
    final visibleRowsStart = (_scrollY / _rowHeight).floor().clamp(
      0,
      _rows.length,
    );
    final visibleRowsEnd = ((_scrollY + size.height) / _rowHeight).ceil().clamp(
      0,
      _rows.length,
    );

    for (int i = visibleRowsStart; i < visibleRowsEnd; i++) {
      final row = _rows[i];
      final y = offset.dy + _headerHeight + i * _rowHeight - _scrollY;
      final isHovered = _hoveredRow == i;
      final rowRect = Rect.fromLTWH(
        offset.dx,
        y,
        math.max(size.width, _totalWidth),
        _rowHeight,
      );

      // Row background
      canvas.drawRect(
        rowRect,
        Paint()..color = isHovered ? _hoverColor : _rowColor,
      );
      canvas.drawLine(
        Offset(offset.dx, y + _rowHeight),
        Offset(offset.dx + math.max(size.width, _totalWidth), y + _rowHeight),
        Paint()..color = const Color(0xFFEEEEEE),
      );

      double x = offset.dx - _scrollX;
      for (final col in _columns) {
        if (x + col.width > offset.dx && x < offset.dx + size.width) {
          final cellText = row.cells[col.id] ?? '';
          textPainter.text = TextSpan(
            text: cellText,
            style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
          );
          textPainter.layout(maxWidth: col.width - 16);
          textPainter.paint(
            canvas,
            Offset(x + 8, y + _rowHeight / 2 - textPainter.height / 2),
          );
        }
        x += col.width;
      }
    }

    // Sticky Header
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, _headerHeight),
      Paint()..color = _headerColor,
    );
    canvas.drawLine(
      Offset(offset.dx, offset.dy + _headerHeight),
      Offset(offset.dx + size.width, offset.dy + _headerHeight),
      Paint()..color = const Color(0xFFBDBDBD),
    );

    double hx = offset.dx - _scrollX;
    for (final col in _columns) {
      if (hx + col.width > offset.dx && hx < offset.dx + size.width) {
        textPainter.text = TextSpan(
          text: col.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF000000),
          ),
        );
        textPainter.layout(maxWidth: col.width - 16);
        textPainter.paint(
          canvas,
          Offset(
            hx + 8,
            offset.dy + _headerHeight / 2 - textPainter.height / 2,
          ),
        );

        // Separator
        canvas.drawLine(
          Offset(hx + col.width, offset.dy + 8),
          Offset(hx + col.width, offset.dy + _headerHeight - 8),
          Paint()..color = const Color(0xFFBDBDBD),
        );
      }
      hx += col.width;
    }

    canvas.restore();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_hoveredRow != null && _hoveredRow! < _rows.length) {
      _onRowTap?.call(_rows[_hoveredRow!]);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _scrollX = (_scrollX - details.delta.dx).clamp(
      0.0,
      math.max(0.0, _totalWidth - size.width),
    );
    _scrollY = (_scrollY - details.delta.dy).clamp(
      0.0,
      math.max(0.0, _totalHeight - size.height),
    );
    markNeedsPaint();
  }

  void _handleHover(PointerHoverEvent event) {
    final localY = event.localPosition.dy;
    if (localY <= _headerHeight) {
      _hoveredRow = null;
    } else {
      final y = localY - _headerHeight + _scrollY;
      final index = (y / _rowHeight).floor();
      if (index >= 0 && index < _rows.length) {
        _hoveredRow = index;
      } else {
        _hoveredRow = null;
      }
    }
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
      _pan.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
