import 'dart:math' as dart_math;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A widget that displays a rating (stars, etc) and allows interaction.
class Ratings extends LeafRenderObjectWidget {
  const Ratings({
    super.key,
    required this.value,
    this.count = 5,
    this.onChanged,
    this.activeColor = const Color(0xFFFFC107), // Amber
    this.inactiveColor = const Color(0xFFE0E0E0), // Grey
    this.starSize = 24.0,

    this.spacing = 4.0,
  });

  final double value;
  final int count;
  final ValueChanged<double>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double starSize;
  final double spacing;

  @override
  RenderRatings createRenderObject(BuildContext context) {
    return RenderRatings(
      value: value,
      count: count,
      onChanged: onChanged,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      starSize: starSize,

      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderRatings renderObject,
  ) {
    renderObject
      ..value = value
      ..count = count
      ..onChanged = onChanged
      ..activeColor = activeColor
      ..inactiveColor = inactiveColor
      ..starSize = starSize
      ..spacing = spacing;
  }
}

class RenderRatings extends RenderBox {
  RenderRatings({
    required double value,
    required int count,
    ValueChanged<double>? onChanged,
    required Color activeColor,
    required Color inactiveColor,
    required double starSize,

    required double spacing,
  }) : _value = value,
       _count = count,
       _onChanged = onChanged,
       _activeColor = activeColor,
       _inactiveColor = inactiveColor,
       _starSize = starSize,
       _spacing = spacing;

  double _value;
  set value(double value) {
    if (_value != value) {
      _value = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  int _count;
  set count(int value) {
    if (_count != value) {
      _count = value;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  ValueChanged<double>? _onChanged;
  set onChanged(ValueChanged<double>? value) {
    _onChanged = value;
    markNeedsSemanticsUpdate();
  }

  Color _activeColor;
  set activeColor(Color value) {
    if (_activeColor != value) {
      _activeColor = value;
      markNeedsPaint();
    }
  }

  Color _inactiveColor;
  set inactiveColor(Color value) {
    if (_inactiveColor != value) {
      _inactiveColor = value;
      markNeedsPaint();
    }
  }

  double _starSize;
  set starSize(double value) {
    if (_starSize != value) {
      _starSize = value;
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

  @override
  void performLayout() {
    final width =
        (_count * _starSize) +
        ((_count - 1).clamp(0, double.infinity) * _spacing);
    size = constraints.constrain(Size(width, _starSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Draw stars
    for (int i = 0; i < _count; i++) {
      final double starLeft = offset.dx + (i * (_starSize + _spacing));
      final double starTop = offset.dy;
      final double fillPercentage = (_value - i).clamp(0.0, 1.0);

      final starPath = _createStarPath(starLeft, starTop, _starSize);

      // Inactive background
      canvas.drawPath(starPath, Paint()..color = _inactiveColor);

      // Active foreground (clipped)
      if (fillPercentage > 0.0) {
        canvas.save();
        canvas.clipRect(
          Rect.fromLTWH(
            starLeft,
            starTop,
            _starSize * fillPercentage,
            _starSize,
          ),
        );
        canvas.drawPath(starPath, Paint()..color = _activeColor);
        canvas.restore();
      }
    }
  }

  Path _createStarPath(double x, double y, double size) {
    // Simple 5-point star path
    final path = Path();
    final double cx = x + size / 2;
    final double cy = y + size / 2;
    final double outerRadius = size / 2;
    final double innerRadius = size / 5;

    // Calculate star points (starts at top, goes clockwise)
    for (int i = 0; i < 10; i++) {
      final double radius = (i % 2 == 0) ? outerRadius : innerRadius;
      final double angle =
          (i * 36) * 3.14159 / 180 - (3.14159 / 2); // Start at -90 deg (top)
      final double px = cx + radius * dart_math.cos(angle);
      final double py = cy + radius * dart_math.sin(angle);

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    if (event is PointerUpEvent && _onChanged != null) {
      final double localX = event.localPosition.dx;

      // Round to nearest half or full star for better UX usually,
      // but here we can just do nearest integer + 1 for simple click
      // Or if we want to allow selecting "3 stars", if they click on the 3rd star (index 2), we set value to 3.

      int clickedIndex = (localX / (_starSize + _spacing)).floor();
      double finalValue = (clickedIndex + 1).toDouble().clamp(
        1.0,
        _count.toDouble(),
      );

      // If clicked on left half of star, maybe we want floating, but standard ratings usually 1-5 integer steps on click
      _onChanged!(finalValue);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSlider = true;
    config.value = '$_value';
    config.label = 'Rating';
    config.textDirection = TextDirection.ltr;
  }
}
