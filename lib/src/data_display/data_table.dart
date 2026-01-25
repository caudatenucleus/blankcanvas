import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// A column configuration for [DataTable].
class DataColumn {
  const DataColumn({required this.label, this.numeric = false, this.width});

  final Widget label;
  final bool numeric;
  final double? width;
}

/// A row of data for [DataTable].
class DataRow {
  const DataRow({
    required this.cells,
    this.selected = false,
    this.onSelectChanged,
  });

  final List<Widget> cells;
  final bool selected;
  final ValueChanged<bool?>? onSelectChanged;
}

/// A themed Data Table widget.
class DataTable extends MultiChildRenderObjectWidget {
  DataTable({super.key, required this.columns, required this.rows, this.tag})
    : super(children: _buildChildren(columns, rows));

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String? tag;

  static List<Widget> _buildChildren(
    List<DataColumn> columns,
    List<DataRow> rows,
  ) {
    final List<Widget> children = [];
    // Headers
    for (final col in columns) {
      children.add(col.label);
    }
    // Cells
    for (final row in rows) {
      for (final cell in row.cells) {
        children.add(cell); // Wrap in something if we need state? No.
      }
    }
    return children;
  }

  @override
  RenderDataTable createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDataTable(tag);

    // We can't pass BoxDecoration easily from here if customizer is inside?
    // Wait, RenderDataTable can handle decoration via customization.

    return RenderDataTable(
      columns: columns,
      rows: rows,
      customization: customization ?? DataTableCustomization.simple(),
      tag: tag,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderDataTable renderObject,
  ) {
    final customizations = CustomizedTheme.of(context);
    renderObject
      ..columns = columns
      ..rows = rows
      ..customization =
          customizations.getDataTable(tag) ?? DataTableCustomization.simple()
      ..tag = tag;
  }
}

class DataCellParentData extends ContainerBoxParentData<RenderBox> {
  int? flex;
  bool header = false;
  int colIndex = 0;
  int rowIndex = 0;
}

class RenderDataTable extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DataCellParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DataCellParentData> {
  RenderDataTable({
    required List<DataColumn> columns,
    required List<DataRow> rows,
    required DataTableCustomization customization,
    String? tag,
  }) : _columns = columns,
       _rows = rows,
       _customization = customization,
       _tag = tag;

  List<DataColumn> _columns;
  List<DataColumn> get columns => _columns;
  set columns(List<DataColumn> value) {
    _columns = value;
    markNeedsLayout();
  }

  List<DataRow> _rows;
  List<DataRow> get rows => _rows;
  set rows(List<DataRow> value) {
    _rows = value;
    markNeedsLayout();
  }

  DataTableCustomization _customization;
  DataTableCustomization get customization => _customization;
  set customization(DataTableCustomization value) {
    _customization = value;
    markNeedsPaint();
  }

  String? _tag;
  set tag(String? value) {
    if (_tag != value) {
      _tag = value;
      markNeedsPaint();
    }
  }

  List<double> _columnWidths = [];
  List<double> _rowHeights = [];
  int? _hoveredRowIndex;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DataCellParentData) {
      child.parentData = DataCellParentData();
    }
  }

  @override
  void performLayout() {
    final int columnCount = columns.length;
    final int rowCount = rows.length + 1; // +1 for header

    _columnWidths = List.filled(columnCount, 0.0);
    _rowHeights = List.filled(rowCount, 0.0);

    // Initial pass to determine column widths and row heights
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final int colIndex = index % columnCount;
      final int rowIndex = index ~/ columnCount;

      final DataCellParentData childParentData =
          child.parentData! as DataCellParentData;
      childParentData.colIndex = colIndex;
      childParentData.rowIndex = rowIndex;
      childParentData.header = rowIndex == 0;

      final double? forcedWidth = columns[colIndex].width;
      child.layout(
        BoxConstraints(maxWidth: forcedWidth ?? constraints.maxWidth),
        parentUsesSize: true,
      );

      _columnWidths[colIndex] =
          forcedWidth ??
          (_columnWidths[colIndex] > child.size.width
              ? _columnWidths[colIndex]
              : child.size.width);
      _rowHeights[rowIndex] = _rowHeights[rowIndex] > child.size.height
          ? _rowHeights[rowIndex]
          : child.size.height;

      index++;
      child = childAfter(child);
    }

    // Add padding/spacing to widths
    const double padding = 12.0;
    for (int i = 0; i < _columnWidths.length; i++) {
      _columnWidths[i] += padding * 2;
    }
    for (int i = 0; i < _rowHeights.length; i++) {
      _rowHeights[i] += padding * 2;
    }

    double totalWidth = 0;
    for (final w in _columnWidths) {
      totalWidth += w;
    }
    double totalHeight = 0;
    for (final h in _rowHeights) {
      totalHeight += h;
    }

    size = constraints.constrain(Size(totalWidth, totalHeight));

    // Position children
    child = firstChild;
    index = 0;
    while (child != null) {
      final int colIndex = index % columnCount;
      final int rowIndex = index ~/ columnCount;
      final DataCellParentData childParentData =
          child.parentData! as DataCellParentData;

      double currentX = 0;
      for (int i = 0; i < colIndex; i++) {
        currentX += _columnWidths[i];
      }

      double y = 0;
      for (int i = 0; i < rowIndex; i++) {
        y += _rowHeights[i];
      }

      // Inner padding
      childParentData.offset = Offset(currentX + padding, y + padding);

      index++;
      child = childAfter(child);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final int rowCount = rows.length + 1;

    // Header decoration
    if (customization.headerDecoration != null && _rowHeights.isNotEmpty) {
      final Rect headerRect = offset & Size(size.width, _rowHeights[0]);
      final Paint headerPaint = Paint()
        ..color =
            customization.headerDecoration!.color ?? const Color(0xFFEEEEEE);
      context.canvas.drawRect(headerRect, headerPaint);
    }

    // Row backgrounds (hover/selection)
    if (_rowHeights.isNotEmpty) {
      double currentY = _rowHeights[0];
      for (int i = 1; i < rowCount; i++) {
        final int dataRowIndex = i - 1;
        final row = rows[dataRowIndex];
        final Rect rowRect =
            (offset + Offset(0, currentY)) & Size(size.width, _rowHeights[i]);

        final status = DataRowControlStatus();
        status.selected = row.selected ? 1.0 : 0.0;
        status.hovered = _hoveredRowIndex == i ? 1.0 : 0.0;
        status.enabled = 1.0;

        final decoration = customization.rowCustomization.decoration(status);
        if (decoration is BoxDecoration && decoration.color != null) {
          context.canvas.drawRect(rowRect, Paint()..color = decoration.color!);
        }
        currentY += _rowHeights[i];
      }
    }

    // Dividers
    final Paint dividerPaint = Paint()
      ..color = customization.dividerColor ?? const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    double dividerY = 0;
    for (int i = 0; i <= rowCount; i++) {
      context.canvas.drawLine(
        offset + Offset(0, dividerY),
        offset + Offset(size.width, dividerY),
        dividerPaint,
      );
      if (i < rowCount) dividerY += _rowHeights[i];
    }

    defaultPaint(context, offset);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent || event is PointerDownEvent) {
      double currentY = 0;
      int foundRowIndex = -1;
      for (int i = 0; i < _rowHeights.length; i++) {
        if (event.localPosition.dy >= currentY &&
            event.localPosition.dy < currentY + _rowHeights[i]) {
          foundRowIndex = i;
          break;
        }
        currentY += _rowHeights[i];
      }

      if (event is PointerHoverEvent) {
        if (_hoveredRowIndex != foundRowIndex) {
          _hoveredRowIndex = foundRowIndex;
          markNeedsPaint();
        }
      } else if (event is PointerDownEvent && foundRowIndex > 0) {
        final int dataRowIndex = foundRowIndex - 1;
        final row = rows[dataRowIndex];
        row.onSelectChanged?.call(!row.selected);
      }
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
