import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Heatmap data point.
class HeatmapCell {
  const HeatmapCell({
    required this.row,
    required this.col,
    required this.value,
  });
  final int row;
  final int col;
  final double value;
}

/// A heatmap visualization widget.
class Heatmap extends LeafRenderObjectWidget {
  const Heatmap({
    super.key,
    required this.data,
    this.rowLabels,
    this.colLabels,
    this.minColor = const Color(0xFFE3F2FD),
    this.maxColor = const Color(0xFF1565C0),
    this.onCellTap,
    this.tag,
  });

  final List<HeatmapCell> data;
  final List<String>? rowLabels;
  final List<String>? colLabels;
  final Color minColor;
  final Color maxColor;
  final void Function(HeatmapCell cell)? onCellTap;
  final String? tag;

  @override
  RenderHeatmap createRenderObject(BuildContext context) {
    return RenderHeatmap(
      data: data,
      rowLabels: rowLabels,
      colLabels: colLabels,
      minColor: minColor,
      maxColor: maxColor,
      onCellTap: onCellTap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderHeatmap renderObject) {
    renderObject
      ..data = data
      ..rowLabels = rowLabels
      ..colLabels = colLabels
      ..minColor = minColor
      ..maxColor = maxColor
      ..onCellTap = onCellTap;
  }
}

class RenderHeatmap extends RenderBox {
  RenderHeatmap({
    required List<HeatmapCell> data,
    List<String>? rowLabels,
    List<String>? colLabels,
    required Color minColor,
    required Color maxColor,
    void Function(HeatmapCell cell)? onCellTap,
  }) : _data = data,
       _rowLabels = rowLabels,
       _colLabels = colLabels,
       _minColor = minColor,
       _maxColor = maxColor,
       _onCellTap = onCellTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<HeatmapCell> _data;
  set data(List<HeatmapCell> value) {
    _data = value;
    markNeedsLayout();
  }

  List<String>? _rowLabels;
  set rowLabels(List<String>? value) {
    _rowLabels = value;
    markNeedsPaint();
  }

  List<String>? _colLabels;
  set colLabels(List<String>? value) {
    _colLabels = value;
    markNeedsPaint();
  }

  Color _minColor;
  set minColor(Color value) {
    _minColor = value;
    markNeedsPaint();
  }

  Color _maxColor;
  set maxColor(Color value) {
    _maxColor = value;
    markNeedsPaint();
  }

  void Function(HeatmapCell cell)? _onCellTap;
  set onCellTap(void Function(HeatmapCell cell)? value) => _onCellTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredRow;
  int? _hoveredCol;

  static const double _labelWidth = 50.0;
  static const double _labelHeight = 24.0;

  int get _rows =>
      _data.isEmpty ? 0 : _data.map((c) => c.row).reduce(math.max) + 1;
  int get _cols =>
      _data.isEmpty ? 0 : _data.map((c) => c.col).reduce(math.max) + 1;
  double get _minValue =>
      _data.isEmpty ? 0 : _data.map((c) => c.value).reduce(math.min);
  double get _maxValue =>
      _data.isEmpty ? 1 : _data.map((c) => c.value).reduce(math.max);

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final cellSize = ((size.width - _labelWidth) / _cols).clamp(20.0, 50.0);
    final height = _rows * cellSize + _labelHeight;
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final cellSize = (size.width - _labelWidth) / _cols;
    final gridOffset = Offset(
      offset.dx + _labelWidth,
      offset.dy + _labelHeight,
    );

    // Column labels
    if (_colLabels != null) {
      for (int c = 0; c < _cols && c < _colLabels!.length; c++) {
        textPainter.text = TextSpan(
          text: _colLabels![c],
          style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            gridOffset.dx + c * cellSize + cellSize / 2 - textPainter.width / 2,
            offset.dy + 4,
          ),
        );
      }
    }

    // Row labels
    if (_rowLabels != null) {
      for (int r = 0; r < _rows && r < _rowLabels!.length; r++) {
        textPainter.text = TextSpan(
          text: _rowLabels![r],
          style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            offset.dx + _labelWidth - textPainter.width - 4,
            gridOffset.dy +
                r * cellSize +
                cellSize / 2 -
                textPainter.height / 2,
          ),
        );
      }
    }

    // Cells
    for (final cell in _data) {
      final normalized = _maxValue > _minValue
          ? (cell.value - _minValue) / (_maxValue - _minValue)
          : 0.5;
      final color = Color.lerp(_minColor, _maxColor, normalized) ?? _minColor;
      final isHovered = _hoveredRow == cell.row && _hoveredCol == cell.col;

      final cellRect = Rect.fromLTWH(
        gridOffset.dx + cell.col * cellSize + 1,
        gridOffset.dy + cell.row * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(2)),
        Paint()..color = color,
      );

      if (isHovered) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(cellRect, const Radius.circular(2)),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = const Color(0xFF333333)
            ..strokeWidth = 2,
        );

        // Value tooltip
        textPainter.text = TextSpan(
          text: cell.value.toStringAsFixed(1),
          style: const TextStyle(fontSize: 9, color: Color(0xFFFFFFFF)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          cellRect.center -
              Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    final cellSize = (size.width - _labelWidth) / _cols;

    final col = ((local.dx - _labelWidth) / cellSize).floor();
    final row = ((local.dy - _labelHeight) / cellSize).floor();

    final cell = _data.where((c) => c.row == row && c.col == col).firstOrNull;
    if (cell != null) _onCellTap?.call(cell);
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    final cellSize = (size.width - _labelWidth) / _cols;

    final col = ((local.dx - _labelWidth) / cellSize).floor();
    final row = ((local.dy - _labelHeight) / cellSize).floor();

    if (_hoveredRow != row || _hoveredCol != col) {
      _hoveredRow = row;
      _hoveredCol = col;
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
