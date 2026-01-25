import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A simpler color picker that offers a palette of presets.
class ColorPalette extends LeafRenderObjectWidget {
  const ColorPalette({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorChanged,
    this.itemSize = 32.0,
    this.spacing = 8.0,
    this.tag,
  });

  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorChanged;
  final double itemSize;
  final double spacing;
  final String? tag;

  @override
  RenderColorPalette createRenderObject(BuildContext context) {
    return RenderColorPalette(
      colors: colors,
      selectedColor: selectedColor,
      onColorChanged: onColorChanged,
      itemSize: itemSize,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderColorPalette renderObject,
  ) {
    renderObject
      ..colors = colors
      ..selectedColor = selectedColor
      ..onColorChanged = onColorChanged
      ..itemSize = itemSize
      ..spacing = spacing;
  }
}

class RenderColorPalette extends RenderBox {
  RenderColorPalette({
    required List<Color> colors,
    Color? selectedColor,
    required ValueChanged<Color> onColorChanged,
    required double itemSize,
    required double spacing,
  }) : _colors = colors,
       _selectedColor = selectedColor,
       _onColorChanged = onColorChanged,
       _itemSize = itemSize,
       _spacing = spacing {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<Color> _colors;
  set colors(List<Color> value) {
    if (_colors != value) {
      _colors = value;
      markNeedsLayout();
    }
  }

  Color? _selectedColor;
  set selectedColor(Color? value) {
    if (_selectedColor != value) {
      _selectedColor = value;
      markNeedsPaint();
    }
  }

  ValueChanged<Color> _onColorChanged;
  set onColorChanged(ValueChanged<Color> value) {
    _onColorChanged = value;
  }

  double _itemSize;
  set itemSize(double value) {
    if (_itemSize != value) {
      _itemSize = value;
      markNeedsLayout();
    }
  }

  double _spacing;
  set spacing(double value) {
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;
  final List<Rect> _itemRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _itemRects.clear();
    final maxWidth = constraints.maxWidth;
    final itemsPerRow = ((maxWidth + _spacing) / (_itemSize + _spacing))
        .floor();
    final rows = (_colors.length / itemsPerRow).ceil();

    double x = 0;
    double y = 0;
    for (int i = 0; i < _colors.length; i++) {
      _itemRects.add(Rect.fromLTWH(x, y, _itemSize, _itemSize));
      x += _itemSize + _spacing;
      if ((i + 1) % itemsPerRow == 0) {
        x = 0;
        y += _itemSize + _spacing;
      }
    }

    final height = rows * _itemSize + (rows - 1) * _spacing;
    size = constraints.constrain(
      Size(maxWidth, height.clamp(0, double.infinity)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    for (int i = 0; i < _colors.length; i++) {
      if (i >= _itemRects.length) break;
      final rect = _itemRects[i].shift(offset);
      final color = _colors[i];
      final isSelected = color == _selectedColor;
      final isHovered = i == _hoveredIndex;

      // Circle background
      final center = rect.center;
      final radius = _itemSize / 2;

      canvas.drawCircle(center, radius, Paint()..color = color);

      // Border
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.0
        ..color = isSelected
            ? const Color(0xFF000000)
            : const Color(0xFFE0E0E0);
      canvas.drawCircle(
        center,
        radius - (isSelected ? 1.25 : 0.5),
        borderPaint,
      );

      // Hover effect
      if (isHovered && !isSelected) {
        canvas.drawCircle(
          center,
          radius,
          Paint()..color = const Color(0x22000000),
        );
      }

      // Check mark for selected
      if (isSelected) {
        final textPainter = TextPainter(
          text: const TextSpan(
            text: '✓',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _itemRects.length; i++) {
      if (_itemRects[i].contains(local)) {
        _onColorChanged(_colors[i]);
        break;
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
