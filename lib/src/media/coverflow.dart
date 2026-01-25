import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A coverflow widget.
class Coverflow extends LeafRenderObjectWidget {
  const Coverflow({
    super.key,
    required this.itemCount,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.itemLabels = const [],
    this.tag,
  });

  final int itemCount;
  final int initialIndex;
  final void Function(int index)? onIndexChanged;
  final List<String> itemLabels;
  final String? tag;

  @override
  RenderCoverflow createRenderObject(BuildContext context) {
    return RenderCoverflow(
      itemCount: itemCount,
      initialIndex: initialIndex,
      onIndexChanged: onIndexChanged,
      itemLabels: itemLabels,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCoverflow renderObject) {
    renderObject
      ..itemCount = itemCount
      ..onIndexChanged = onIndexChanged
      ..itemLabels = itemLabels;
  }
}

class RenderCoverflow extends RenderBox {
  RenderCoverflow({
    required int itemCount,
    required int initialIndex,
    void Function(int index)? onIndexChanged,
    required List<String> itemLabels,
  }) : _itemCount = itemCount,
       _currentIndex = initialIndex,
       _onIndexChanged = onIndexChanged,
       _itemLabels = itemLabels {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _pan = PanGestureRecognizer()
      ..onUpdate = _handlePanUpdate
      ..onEnd = _handlePanEnd;
  }

  int _itemCount;
  set itemCount(int value) {
    _itemCount = value;
    markNeedsPaint();
  }

  int _currentIndex;
  double _panOffset = 0;

  void Function(int index)? _onIndexChanged;
  set onIndexChanged(void Function(int index)? value) =>
      _onIndexChanged = value;

  List<String> _itemLabels;
  set itemLabels(List<String> value) => _itemLabels = value;

  late TapGestureRecognizer _tap;
  late PanGestureRecognizer _pan;
  int? _hoveredIndex;

  static const double _itemWidth = 150.0;
  static const double _itemHeight = 180.0;
  static const double _spacing = 60.0;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];

  @override
  void detach() {
    _tap.dispose();
    _pan.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, _itemHeight + 60));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final centerX = offset.dx + size.width / 2;
    final centerY = offset.dy + size.height / 2 - 20;

    // Draw items from back to front
    final displayCount = 5;
    List<int> indices = [];
    for (int i = -displayCount ~/ 2; i <= displayCount ~/ 2; i++) {
      final idx = _currentIndex + i;
      if (idx >= 0 && idx < _itemCount) {
        indices.add(idx);
      }
    }

    // Sort by distance from center for proper z-ordering
    indices.sort(
      (a, b) => (a - _currentIndex).abs().compareTo((b - _currentIndex).abs()),
    );
    indices = indices.reversed.toList();

    for (final idx in indices) {
      final offset2 = idx - _currentIndex + _panOffset / 100;
      final absOffset = offset2.abs();

      // Calculate position and scale
      final x = centerX + offset2 * _spacing - _itemWidth / 2;
      final scale = 1.0 - absOffset * 0.15;
      final opacity = 1.0 - absOffset * 0.2;

      // Save canvas state
      canvas.save();

      // Apply transforms
      final itemCenterX = x + _itemWidth / 2;
      canvas.translate(itemCenterX, centerY);
      canvas.scale(scale);
      canvas.translate(-itemCenterX, -centerY);

      // Draw item
      final itemRect = Rect.fromLTWH(
        x,
        centerY - _itemHeight / 2 * scale,
        _itemWidth,
        _itemHeight * scale,
      );
      final isHovered = _hoveredIndex == idx;

      // Shadow
      final shadowPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            itemRect.translate(0, 8),
            const Radius.circular(8),
          ),
        );
      canvas.drawShadow(shadowPath, const Color(0xFF000000), 8, false);

      // Card
      canvas.drawRRect(
        RRect.fromRectAndRadius(itemRect, const Radius.circular(8)),
        Paint()
          ..color = (_colors[idx % _colors.length]).withValues(
            alpha: opacity.clamp(0.3, 1.0),
          ),
      );

      if (isHovered) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(itemRect, const Radius.circular(8)),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = const Color(0xFFFFFFFF)
            ..strokeWidth = 2,
        );
      }

      // Label
      if (idx < _itemLabels.length) {
        textPainter.text = TextSpan(
          text: _itemLabels[idx],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        );
        textPainter.layout(maxWidth: _itemWidth - 16);
        textPainter.paint(
          canvas,
          itemRect.center -
              Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      canvas.restore();
    }

    // Indicator dots
    final dotsY = offset.dy + size.height - 20;
    final dotsWidth = _itemCount * 12.0;
    for (int i = 0; i < _itemCount; i++) {
      final dotX = centerX - dotsWidth / 2 + i * 12 + 4;
      canvas.drawCircle(
        Offset(dotX, dotsY),
        i == _currentIndex ? 5 : 3,
        Paint()
          ..color = i == _currentIndex
              ? const Color(0xFF2196F3)
              : const Color(0xFFBDBDBD),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    final centerX = size.width / 2;

    if (local.dx < centerX - 50) {
      _currentIndex = (_currentIndex - 1).clamp(0, _itemCount - 1);
      _onIndexChanged?.call(_currentIndex);
      markNeedsPaint();
    } else if (local.dx > centerX + 50) {
      _currentIndex = (_currentIndex + 1).clamp(0, _itemCount - 1);
      _onIndexChanged?.call(_currentIndex);
      markNeedsPaint();
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _panOffset += details.delta.dx;
    markNeedsPaint();
  }

  void _handlePanEnd(DragEndDetails details) {
    final indexDelta = -(_panOffset / 100).round();
    _currentIndex = (_currentIndex + indexDelta).clamp(0, _itemCount - 1);
    _panOffset = 0;
    _onIndexChanged?.call(_currentIndex);
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
      _pan.addPointer(event);
    }
  }
}
