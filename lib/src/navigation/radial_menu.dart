import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A radial menu item.
class RadialMenuItem {
  const RadialMenuItem({required this.icon, this.label, required this.onTap});
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
}

/// A circular/radial menu.
class RadialMenu extends LeafRenderObjectWidget {
  const RadialMenu({
    super.key,
    required this.items,
    this.isOpen = false,
    this.radius = 100.0,
    this.centerColor = const Color(0xFF2196F3),
    this.itemColor = const Color(0xFFFFFFFF),
    this.tag,
  });

  final List<RadialMenuItem> items;
  final bool isOpen;
  final double radius;
  final Color centerColor;
  final Color itemColor;
  final String? tag;

  @override
  RenderRadialMenu createRenderObject(BuildContext context) {
    return RenderRadialMenu(
      items: items,
      isOpen: isOpen,
      menuRadius: radius,
      centerColor: centerColor,
      itemColor: itemColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderRadialMenu renderObject) {
    renderObject
      ..items = items
      ..isOpen = isOpen
      ..menuRadius = radius
      ..centerColor = centerColor
      ..itemColor = itemColor;
  }
}

class RenderRadialMenu extends RenderBox {
  RenderRadialMenu({
    required List<RadialMenuItem> items,
    required bool isOpen,
    required double menuRadius,
    required Color centerColor,
    required Color itemColor,
  }) : _items = items,
       _isOpen = isOpen,
       _menuRadius = menuRadius,
       _centerColor = centerColor,
       _itemColor = itemColor {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<RadialMenuItem> _items;
  set items(List<RadialMenuItem> value) {
    _items = value;
    markNeedsPaint();
  }

  bool _isOpen;
  set isOpen(bool value) {
    if (_isOpen != value) {
      _isOpen = value;
      markNeedsPaint();
    }
  }

  double _menuRadius;
  set menuRadius(double value) {
    _menuRadius = value;
    markNeedsLayout();
  }

  Color _centerColor;
  set centerColor(Color value) {
    _centerColor = value;
    markNeedsPaint();
  }

  Color _itemColor;
  set itemColor(Color value) {
    _itemColor = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const double _centerRadius = 28.0;
  static const double _itemRadius = 24.0;

  final List<Offset> _itemPositions = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final totalSize = _menuRadius * 2 + _itemRadius * 2;
    size = constraints.constrain(Size(totalSize, totalSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    _itemPositions.clear();

    final center = offset + Offset(size.width / 2, size.height / 2);

    // Center button
    canvas.drawCircle(center, _centerRadius, Paint()..color = _centerColor);
    canvas.drawCircle(
      center,
      _centerRadius - 3,
      Paint()..color = _centerColor.withValues(alpha: 0.8),
    );

    // Menu icon (hamburger or X)
    textPainter.text = TextSpan(
      text: _isOpen ? '✕' : '☰',
      style: const TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    if (!_isOpen) return;

    // Items
    final angleStep = (2 * math.pi) / _items.length;
    for (int i = 0; i < _items.length; i++) {
      final angle = -math.pi / 2 + angleStep * i;
      final pos =
          center +
          Offset(math.cos(angle) * _menuRadius, math.sin(angle) * _menuRadius);
      _itemPositions.add(Offset(pos.dx - offset.dx, pos.dy - offset.dy));

      final isHovered = _hoveredIndex == i;

      // Item circle
      canvas.drawCircle(
        pos,
        _itemRadius + (isHovered ? 4 : 0),
        Paint()..color = _itemColor,
      );
      if (isHovered) {
        canvas.drawCircle(
          pos,
          _itemRadius + 4,
          Paint()
            ..color = _centerColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // Icon
      final item = _items[i];
      textPainter.text = TextSpan(
        text: String.fromCharCode(item.icon.codePoint),
        style: TextStyle(
          fontSize: 20,
          fontFamily: item.icon.fontFamily,
          color: const Color(0xFF333333),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      // Label
      if (item.label != null && isHovered) {
        textPainter.text = TextSpan(
          text: item.label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(pos.dx - textPainter.width / 2, pos.dy + _itemRadius + 4),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    final center = Offset(size.width / 2, size.height / 2);

    // Check center tap
    if ((local - center).distance < _centerRadius) {
      _isOpen = !_isOpen;
      markNeedsPaint();
      return;
    }

    // Check item taps
    if (_isOpen) {
      for (int i = 0; i < _itemPositions.length; i++) {
        if ((local - _itemPositions[i]).distance < _itemRadius) {
          _items[i].onTap();
          return;
        }
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    if (!_isOpen) return;
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _itemPositions.length; i++) {
      if ((local - _itemPositions[i]).distance < _itemRadius) {
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
