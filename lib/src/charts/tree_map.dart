import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A tree map data item.
class TreeMapItem {
  const TreeMapItem({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;
}

/// A tree map visualization widget.
class TreeMap extends LeafRenderObjectWidget {
  const TreeMap({super.key, required this.items, this.onItemTap, this.tag});

  final List<TreeMapItem> items;
  final void Function(TreeMapItem item)? onItemTap;
  final String? tag;

  @override
  RenderTreeMap createRenderObject(BuildContext context) {
    return RenderTreeMap(items: items, onItemTap: onItemTap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTreeMap renderObject) {
    renderObject
      ..items = items
      ..onItemTap = onItemTap;
  }
}

class RenderTreeMap extends RenderBox {
  RenderTreeMap({
    required List<TreeMapItem> items,
    void Function(TreeMapItem item)? onItemTap,
  }) : _items = items,
       _onItemTap = onItemTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<TreeMapItem> _items;
  set items(List<TreeMapItem> value) {
    _items = value;
    markNeedsLayout();
  }

  void Function(TreeMapItem item)? _onItemTap;
  set onItemTap(void Function(TreeMapItem item)? value) => _onItemTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF3F51B5),
    Color(0xFFFFEB3B),
  ];

  final List<Rect> _itemRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _itemRects.clear();
    size = constraints.constrain(Size(constraints.maxWidth, 300));
    _calculateLayout(
      Rect.fromLTWH(0, 0, size.width, size.height),
      List.from(_items),
      0,
    );
  }

  void _calculateLayout(Rect area, List<TreeMapItem> items, int depth) {
    if (items.isEmpty) return;

    final total = items.fold<double>(0, (sum, i) => sum + i.value);
    final isHorizontal = area.width > area.height;

    double offset = 0;
    for (int i = 0; i < items.length; i++) {
      final ratio = items[i].value / total;
      Rect rect;

      if (isHorizontal) {
        final width = area.width * ratio;
        rect = Rect.fromLTWH(area.left + offset, area.top, width, area.height);
        offset += width;
      } else {
        final height = area.height * ratio;
        rect = Rect.fromLTWH(area.left, area.top + offset, area.width, height);
        offset += height;
      }

      _itemRects.add(rect);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < _items.length && i < _itemRects.length; i++) {
      final item = _items[i];
      final rect = _itemRects[i].shift(offset);
      final isHovered = _hoveredIndex == i;
      final color = item.color ?? _colors[i % _colors.length];

      // Cell
      canvas.drawRect(
        rect.deflate(1),
        Paint()..color = isHovered ? color : color.withValues(alpha: 0.85),
      );

      // Border
      canvas.drawRect(
        rect.deflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = 2,
      );

      // Label
      if (rect.width > 40 && rect.height > 30) {
        textPainter.text = TextSpan(
          text: item.label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        );
        textPainter.layout(maxWidth: rect.width - 8);
        textPainter.paint(canvas, Offset(rect.left + 4, rect.top + 4));

        // Value
        textPainter.text = TextSpan(
          text: item.value.toStringAsFixed(0),
          style: const TextStyle(fontSize: 9, color: Color(0xDDFFFFFF)),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(rect.left + 4, rect.top + 18));
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _itemRects.length; i++) {
      if (_itemRects[i].contains(local)) {
        _onItemTap?.call(_items[i]);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _itemRects.length; i++) {
      if (_itemRects[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_hoveredIndex != hovered) {
      _hoveredIndex = hovered;
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
