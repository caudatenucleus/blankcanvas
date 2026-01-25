import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A horizontal carousel using lowest-level RenderObject APIs.
class Carousel extends MultiChildRenderObjectWidget {
  const Carousel({
    super.key,
    required super.children,
    this.showIndicator = true,
    this.onPageChanged,
    this.initialPage = 0,
    this.indicatorAlignment = Alignment.bottomCenter,
    this.indicatorPadding = const EdgeInsets.only(bottom: 16),
  });

  final bool showIndicator;
  final ValueChanged<int>? onPageChanged;
  final int initialPage;
  final Alignment indicatorAlignment;
  final EdgeInsets indicatorPadding;

  @override
  RenderCarousel createRenderObject(BuildContext context) {
    return RenderCarousel(
      showIndicator: showIndicator,
      initialPage: initialPage,
      onPageChanged: onPageChanged,
      indicatorAlignment: indicatorAlignment,
      indicatorPadding: indicatorPadding,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCarousel renderObject) {
    renderObject
      ..showIndicator = showIndicator
      ..onPageChanged = onPageChanged
      ..indicatorAlignment = indicatorAlignment
      ..indicatorPadding = indicatorPadding;
  }
}

class CarouselParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCarousel extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CarouselParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CarouselParentData>
    implements TickerProvider {
  RenderCarousel({
    required bool showIndicator,
    required int initialPage,
    ValueChanged<int>? onPageChanged,
    required Alignment indicatorAlignment,
    required EdgeInsets indicatorPadding,
  }) : _showIndicator = showIndicator,
       _currentPage = initialPage,
       _scrollOffset =
           0.0, // Will be set in layout if size known? Or initialPage * width
       _onPageChanged = onPageChanged,
       _indicatorAlignment = indicatorAlignment,
       _indicatorPadding = indicatorPadding {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  bool _showIndicator;
  set showIndicator(bool value) {
    if (_showIndicator == value) return;
    _showIndicator = value;
    markNeedsPaint();
  }

  ValueChanged<int>? _onPageChanged;
  set onPageChanged(ValueChanged<int>? value) {
    _onPageChanged = value;
  }

  Alignment _indicatorAlignment;
  set indicatorAlignment(Alignment value) {
    if (_indicatorAlignment == value) return;
    _indicatorAlignment = value;
    markNeedsPaint();
  }

  EdgeInsets _indicatorPadding;
  set indicatorPadding(EdgeInsets value) {
    if (_indicatorPadding == value) return;
    _indicatorPadding = value;
    markNeedsPaint();
  }

  late HorizontalDragGestureRecognizer _drag;

  // State
  int _currentPage;
  double _scrollOffset; // pixels
  Ticker? _ticker;
  double? _targetScrollOffset; // For animation

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! CarouselParentData) {
      child.parentData = CarouselParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    if (size.isEmpty) size = constraints.constrain(const Size(300, 200));

    // Layout all children at full size
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints.tight(size)); // Each page fills the carousel
      child = childAfter(child);
    }

    // Initial scroll offset setup if first layout
    if (_scrollOffset == 0.0 && _currentPage > 0) {
      _scrollOffset = _currentPage * size.width;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      _paintContents,
    );

    if (_showIndicator && childCount > 1) {
      _paintIndicator(context, offset);
    }
  }

  void _paintContents(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      // Child position relative to scrollOffset
      final double childOffset = i * size.width - _scrollOffset;

      // Optimization: Only paint visible children
      if (childOffset + size.width > 0 && childOffset < size.width) {
        context.paintChild(child, offset + Offset(childOffset, 0));
      }

      child = childAfter(child);
      i++;
    }
  }

  void _paintIndicator(PaintingContext context, Offset offset) {
    // Determine indicator position
    // Simple 3 dots for now or full count
    final int count = childCount;
    if (count <= 1) return;

    // Draw dots
    final double dotSize = 8.0;
    final double spacing = 8.0;
    final double totalWidth = count * dotSize + (count - 1) * spacing;

    // Resolve alignment
    final Offset center = _indicatorAlignment.alongSize(size);
    // Apply padding
    final double dx = center.dx - totalWidth / 2;
    final double dy =
        center.dy -
        dotSize / 2 -
        _indicatorPadding.bottom; // Simplified padding handling

    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      double opacity = 0.4;
      if (i == _currentPage) {
        opacity = 1.0;
      }
      // Smooth transition based on scrollOffset
      // current scroll page = _scrollOffset / size.width
      double pagePos = _scrollOffset / (size.width > 0 ? size.width : 1);
      double dist = (pagePos - i).abs();
      if (dist < 1.0) {
        opacity = 0.4 + (1.0 - dist) * 0.6;
      }

      paint.color = Color.fromRGBO(
        0,
        0,
        0,
        opacity.clamp(0.0, 1.0),
      ); // Black dots logic, customized later?
      // Use standard grey/white? Default material is usually semi-transparent white/grey.
      // Let's use white for visibility on typical images, or grey.
      paint.color = Color.fromRGBO(255, 255, 255, opacity.clamp(0.0, 1.0));

      context.canvas.drawCircle(
        offset +
            Offset(
              dx + i * (dotSize + spacing) + dotSize / 2,
              dy + dotSize / 2,
            ),
        dotSize / 2,
        paint,
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Transform position to child coordinates based on scroll
    // Find visible child
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      final double childOffset = i * size.width - _scrollOffset;
      if (childOffset + size.width > 0 && childOffset < size.width) {
        // Visible
        final Offset transformed = position - Offset(childOffset, 0);
        if (child.hitTest(result, position: transformed)) {
          return true;
        }
      }
      child = childAfter(child);
      i++;
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
    super.handleEvent(event, entry);
  }

  void _handleDragStart(DragStartDetails details) {
    _stopAnimation();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _scrollOffset -= details.delta.dx;
    // Clamp? Or elastic?
    // Clamp for now
    final double maxScroll = (childCount - 1) * size.width;
    _scrollOffset = _scrollOffset.clamp(0.0, maxScroll);
    markNeedsPaint();
  }

  void _handleDragEnd(DragEndDetails details) {
    // Snap to nearest
    final double velocity = details.primaryVelocity ?? 0.0;
    final int count = childCount;
    if (size.width == 0) return;

    int targetPage = (_scrollOffset / size.width).round();

    // Velocity fling
    if (velocity < -500 && targetPage < count - 1) {
      targetPage = (_scrollOffset / size.width).floor() + 1;
    } else if (velocity > 500 && targetPage > 0) {
      targetPage = (_scrollOffset / size.width).ceil() - 1;
    }

    targetPage = targetPage.clamp(0, count - 1);

    _animateToPage(targetPage);
  }

  void _handleDragCancel() {
    // Snap back to current
    _animateToPage(_currentPage);
  }

  void _animateToPage(int page) {
    _targetScrollOffset = page * size.width;

    _stopAnimation();
    _ticker = createTicker(_tick)..start();

    if (_currentPage != page) {
      _currentPage = page;
      _onPageChanged?.call(_currentPage);
    }
  }

  void _stopAnimation() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void _tick(Duration elapsed) {
    if (_targetScrollOffset == null) return;

    // Simple lerp for now, ideally physics based
    final double diff = _targetScrollOffset! - _scrollOffset;
    if (diff.abs() < 1.0) {
      _scrollOffset = _targetScrollOffset!;
      _stopAnimation();
    } else {
      _scrollOffset += diff * 0.2; // Smooth ease
    }
    markNeedsPaint();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
