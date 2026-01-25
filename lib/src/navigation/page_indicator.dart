import 'package:flutter/widgets.dart';

/// Customization for PageIndicator.
class PageIndicatorCustomization {
  const PageIndicatorCustomization({
    this.activeColor,
    this.inactiveColor,
    this.indicatorSize,
    this.spacing,
  });

  final Color? activeColor;
  final Color? inactiveColor;
  final double? indicatorSize;
  final double? spacing;

  factory PageIndicatorCustomization.simple({
    Color? activeColor,
    Color? inactiveColor,
    double? indicatorSize,
    double? spacing,
  }) {
    return PageIndicatorCustomization(
      activeColor: activeColor ?? const Color(0xFF2196F3),
      inactiveColor: inactiveColor ?? const Color(0xFFBDBDBD),
      indicatorSize: indicatorSize ?? 8,
      spacing: spacing ?? 8,
    );
  }
}

/// A dot-based page indicator.
class PageIndicator extends LeafRenderObjectWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.customization,
  });

  final int count;
  final int currentIndex;
  final PageIndicatorCustomization? customization;

  @override
  RenderPageIndicator createRenderObject(BuildContext context) {
    final resolved = customization ?? PageIndicatorCustomization.simple();
    return RenderPageIndicator(
      count: count,
      currentIndex: currentIndex,
      customization: resolved,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderPageIndicator renderObject,
  ) {
    final resolved = customization ?? PageIndicatorCustomization.simple();
    renderObject
      ..count = count
      ..currentIndex = currentIndex
      ..customization = resolved;
  }
}

class RenderPageIndicator extends RenderBox {
  RenderPageIndicator({
    required int count,
    required int currentIndex,
    required PageIndicatorCustomization customization,
  }) : _count = count,
       _currentIndex = currentIndex,
       _customization = customization;

  int _count;
  int get count => _count;
  set count(int value) {
    if (_count == value) return;
    _count = value;
    markNeedsLayout();
  }

  int _currentIndex;
  int get currentIndex => _currentIndex;
  set currentIndex(int value) {
    if (_currentIndex == value) return;
    _currentIndex = value;
    markNeedsPaint();
  }

  PageIndicatorCustomization _customization;
  PageIndicatorCustomization get customization => _customization;
  set customization(PageIndicatorCustomization value) {
    if (_customization == value) return;
    _customization = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final double indicatorSize = customization.indicatorSize ?? 8;
    final double spacing = customization.spacing ?? 8;
    final double totalWidth =
        (indicatorSize * count) +
        (spacing * (count - 1).clamp(0, double.infinity));
    size = constraints.constrain(Size(totalWidth, indicatorSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final double indicatorSize = customization.indicatorSize ?? 8;
    final double spacing = customization.spacing ?? 8;
    final Color activeColor =
        customization.activeColor ?? const Color(0xFF2196F3);
    final Color inactiveColor =
        customization.inactiveColor ?? const Color(0xFFBDBDBD);

    double currentX = offset.dx;
    for (int i = 0; i < count; i++) {
      final bool isActive = i == currentIndex;
      final Paint paint = Paint()
        ..color = isActive ? activeColor : inactiveColor;
      canvas.drawCircle(
        Offset(currentX + indicatorSize / 2, offset.dy + indicatorSize / 2),
        indicatorSize / 2,
        paint,
      );
      currentX += indicatorSize + spacing;
    }
  }
}
