import 'package:flutter/widgets.dart';

/// A pagination control.
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

class Pagination extends LeafRenderObjectWidget {
  const Pagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.visiblePages = 5,
    this.tag,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int visiblePages;
  final String? tag;

  @override
  RenderPagination createRenderObject(BuildContext context) {
    return RenderPagination(
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
      visiblePages: visiblePages,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPagination renderObject) {
    renderObject
      ..currentPage = currentPage
      ..totalPages = totalPages
      ..onPageChanged = onPageChanged
      ..visiblePages = visiblePages;
  }
}

class RenderPagination extends RenderBox {
  RenderPagination({
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageChanged,
    required int visiblePages,
  }) : _currentPage = currentPage,
       _totalPages = totalPages,
       _onPageChanged = onPageChanged,
       _visiblePages = visiblePages {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  int _currentPage;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    if (_currentPage != value) {
      _currentPage = value;
      markNeedsPaint();
    }
  }

  int _totalPages;
  int get totalPages => _totalPages;
  set totalPages(int value) {
    if (_totalPages != value) {
      _totalPages = value;
      markNeedsLayout();
    }
  }

  ValueChanged<int> _onPageChanged;
  set onPageChanged(ValueChanged<int> value) {
    _onPageChanged = value;
  }

  int _visiblePages;
  set visiblePages(int value) {
    if (_visiblePages != value) {
      _visiblePages = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;

  // Custom Hover handling implemented directly
  int? _hoveredIndex; // -1 for prev, -2 for next, >0 for page number

  // Using PointerHoverEvent handling directly now as instructed
  // late HoverGestureRecognizer _hover; // NO, direct handling

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  // Metrics
  final double _itemSize = 32.0;
  final double _spacing = 4.0;

  // Calculated regions
  final List<_PageItemRegion> _regions = [];

  @override
  void performLayout() {
    if (_totalPages <= 0) {
      size = Size.zero;
      return;
    }

    _regions.clear();
    double x = 0.0;

    // Prev Button
    _regions.add(
      _PageItemRegion(Rect.fromLTWH(x, 0, _itemSize, _itemSize), -1, "<"),
    );
    x += _itemSize + _spacing;

    // Page Numbers
    final pages = _buildPageList();
    for (final p in pages) {
      if (p == -1) {
        // Ellipsis
        _regions.add(
          _PageItemRegion(Rect.fromLTWH(x, 0, _itemSize, _itemSize), 0, "..."),
        );
      } else {
        _regions.add(
          _PageItemRegion(Rect.fromLTWH(x, 0, _itemSize, _itemSize), p, "$p"),
        );
      }
      x += _itemSize + _spacing;
    }

    // Next Button
    _regions.add(
      _PageItemRegion(Rect.fromLTWH(x, 0, _itemSize, _itemSize), -2, ">"),
    );
    x += _itemSize;

    size = constraints.constrain(Size(x, _itemSize));
  }

  List<int> _buildPageList() {
    if (_totalPages <= _visiblePages + 2) {
      return List.generate(_totalPages, (i) => i + 1);
    }
    final list = <int>[];
    list.add(1);
    if (_currentPage > 3) list.add(-1); // Ellipsis

    final start = (_currentPage - 1).clamp(2, _totalPages - 2);
    final end = (_currentPage + 1).clamp(3, _totalPages - 1);

    for (int i = start; i <= end; i++) {
      if (i > 1 && i < _totalPages) list.add(i);
    }

    if (_currentPage < _totalPages - 2) list.add(-1);
    list.add(_totalPages);
    return list;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_totalPages <= 0) return;
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final region in _regions) {
      final rect = region.rect.shift(offset);
      final isPrev = region.value == -1;
      final isNext = region.value == -2;
      final isEllipsis = region.label == "...";
      final isPage = !isPrev && !isNext && !isEllipsis;

      bool isSelected = isPage && region.value == _currentPage;
      bool isHovered = _hoveredIndex == region.value;
      bool isEnabled = true;
      if (isPrev) isEnabled = _currentPage > 1;
      if (isNext) isEnabled = _currentPage < _totalPages;
      if (isEllipsis) isEnabled = false;

      // Fix usage of value for hover on prev/next (-1, -2 clash with ellipsis 0? no)
      // Prev: -1. Next: -2. Ellipsis: 0 (unused value). Page: > 0.
      // Wait, define ellipsis value clearly. 0 is fine since pages start at 1.

      // Paint Bg
      final paint = Paint()..color = const Color(0x00000000);
      if (isSelected) {
        paint.color = const Color(0xFF2196F3);
      } else if (isHovered && isEnabled) {
        paint.color = const Color(0xFFE0E0E0);
      } else if (!isSelected && isEnabled) {
        paint.style = PaintingStyle.stroke;
        paint.color = const Color(0xFFE0E0E0);
      }

      // Draw Box
      if (!isEllipsis) {
        if (isSelected || (isHovered && isEnabled)) {
          // Fill
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            paint,
          );
        } else if (isEnabled) {
          // Border
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            paint,
          );
        }
      }

      // Text/Icon
      Color textColor = isSelected
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF000000);
      if (!isEnabled) textColor = const Color(0xFF9E9E9E);

      if (isPrev || isNext) {
        // simplified icon text
        textPainter.text = TextSpan(
          text: isPrev ? "<" : ">",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        );
      } else {
        textPainter.text = TextSpan(
          text: region.label,
          style: TextStyle(color: textColor, fontSize: 13),
        );
      }

      textPainter.layout();
      textPainter.paint(
        canvas,
        rect.center - (textPainter.size / 2).getOffset(),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (final region in _regions) {
      if (region.rect.contains(local)) {
        if (region.value == -1) {
          // Prev
          if (_currentPage > 1) _onPageChanged(_currentPage - 1);
        } else if (region.value == -2) {
          // Next
          if (_currentPage < _totalPages) _onPageChanged(_currentPage + 1);
        } else if (region.value > 0) {
          // Page
          if (region.value != _currentPage) _onPageChanged(region.value);
        }
        break;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (final region in _regions) {
      if (region.rect.contains(local)) {
        hovered = region.value;
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

class _PageItemRegion {
  final Rect rect;
  final int value; // -1 prev, -2 next, 0 ellipsis, >0 page
  final String label;
  _PageItemRegion(this.rect, this.value, this.label);
}

extension on Size {
  Offset getOffset() => Offset(width, height);
}
