import 'package:flutter/widgets.dart';

/// A description item.
class DescriptionItem {
  const DescriptionItem({required this.label, required this.content});
  final String label;
  final String content;
}

/// A descriptions widget for key-value pairs.
class Descriptions extends LeafRenderObjectWidget {
  const Descriptions({
    super.key,
    required this.items,
    this.columnCount = 2,
    this.tag,
  });

  final List<DescriptionItem> items;
  final int columnCount;
  final String? tag;

  @override
  RenderDescriptions createRenderObject(BuildContext context) {
    return RenderDescriptions(items: items, columnCount: columnCount);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDescriptions renderObject,
  ) {
    renderObject
      ..items = items
      ..columnCount = columnCount;
  }
}

class RenderDescriptions extends RenderBox {
  RenderDescriptions({
    required List<DescriptionItem> items,
    required int columnCount,
  }) : _items = items,
       _columnCount = columnCount;

  List<DescriptionItem> _items;
  set items(List<DescriptionItem> value) {
    _items = value;
    markNeedsLayout();
  }

  int _columnCount;
  set columnCount(int value) {
    _columnCount = value;
    markNeedsLayout();
  }

  static const double _rowHeight = 40.0;
  static const double _labelWidthRatio = 0.3;

  @override
  void performLayout() {
    final rows = (_items.length / _columnCount).ceil();
    size = constraints.constrain(Size(constraints.maxWidth, rows * _rowHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final itemWidth = size.width / _columnCount;

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final col = i % _columnCount;
      final row = i ~/ _columnCount;
      final x = offset.dx + col * itemWidth;
      final y = offset.dy + row * _rowHeight;
      final labelWidth = itemWidth * _labelWidthRatio;
      final contentWidth = itemWidth * (1 - _labelWidthRatio);

      // Backgrounds
      canvas.drawRect(
        Rect.fromLTWH(x, y, labelWidth, _rowHeight),
        Paint()..color = const Color(0xFFF5F5F5),
      );
      canvas.drawRect(
        Rect.fromLTWH(x + labelWidth, y, contentWidth, _rowHeight),
        Paint()..color = const Color(0xFFFFFFFF),
      );

      // Borders
      canvas.drawRect(
        Rect.fromLTWH(x, y, itemWidth, _rowHeight),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFE0E0E0),
      );

      // Label
      textPainter.text = TextSpan(
        text: item.label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Color(0xFF666666),
        ),
      );
      textPainter.layout(maxWidth: labelWidth - 16);
      textPainter.paint(
        canvas,
        Offset(x + 8, y + _rowHeight / 2 - textPainter.height / 2),
      );

      // Content
      textPainter.text = TextSpan(
        text: item.content,
        style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
      );
      textPainter.layout(maxWidth: contentWidth - 16);
      textPainter.paint(
        canvas,
        Offset(x + labelWidth + 8, y + _rowHeight / 2 - textPainter.height / 2),
      );
    }
  }
}
