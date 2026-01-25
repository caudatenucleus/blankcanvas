import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A vertical navigation rail.
class NavigationRail extends MultiChildRenderObjectWidget {
  NavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.leading,
    this.trailing,
    this.minWidth = 72.0,
    this.tag,
  }) : super(children: _buildChildren(destinations, leading, trailing));

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final Widget? leading;
  final Widget? trailing;
  final double minWidth;
  final String? tag;

  static List<Widget> _buildChildren(
    List<NavigationRailDestination> destinations,
    Widget? leading,
    Widget? trailing,
  ) {
    final children = <Widget>[];
    if (leading != null) {
      children.add(
        _NavigationRailSlot(slotType: _SlotType.leading, child: leading),
      );
    }
    for (int i = 0; i < destinations.length; i++) {
      children.add(
        _NavigationRailSlot(
          slotType: _SlotType.destination,
          index: i,
          child: destinations[i]
              .icon, // We'll paint custom, but need child for measurement
        ),
      );
    }
    if (trailing != null) {
      children.add(
        _NavigationRailSlot(slotType: _SlotType.trailing, child: trailing),
      );
    }
    return children;
  }

  @override
  RenderNavigationRail createRenderObject(BuildContext context) {
    return RenderNavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      minWidth: minWidth,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderNavigationRail renderObject,
  ) {
    renderObject
      ..selectedIndex = selectedIndex
      ..onDestinationSelected = onDestinationSelected
      ..destinations = destinations
      ..minWidth = minWidth;
  }
}

enum _SlotType { leading, destination, trailing }

class _NavigationRailParentData extends ContainerBoxParentData<RenderBox> {
  _SlotType? slotType;
  int? index;
}

class _NavigationRailSlot extends ParentDataWidget<_NavigationRailParentData> {
  const _NavigationRailSlot({
    required this.slotType,
    this.index,
    required super.child,
  });

  final _SlotType slotType;
  final int? index;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! _NavigationRailParentData) {
      renderObject.parentData = _NavigationRailParentData();
    }
    final pd = renderObject.parentData as _NavigationRailParentData;
    bool needsLayout = false;
    if (pd.slotType != slotType) {
      pd.slotType = slotType;
      needsLayout = true;
    }
    if (pd.index != index) {
      pd.index = index;
      needsLayout = true;
    }
    if (needsLayout) {
      final parent = renderObject.parent;
      if (parent is RenderObject) parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => NavigationRail;
}

class RenderNavigationRail extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _NavigationRailParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _NavigationRailParentData> {
  RenderNavigationRail({
    required int selectedIndex,
    required ValueChanged<int> onDestinationSelected,
    required List<NavigationRailDestination> destinations,
    required double minWidth,
  }) : _selectedIndex = selectedIndex,
       _onDestinationSelected = onDestinationSelected,
       _destinations = destinations,
       _minWidth = minWidth {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  int _selectedIndex;
  set selectedIndex(int value) {
    if (_selectedIndex != value) {
      _selectedIndex = value;
      markNeedsPaint();
    }
  }

  ValueChanged<int> _onDestinationSelected;
  set onDestinationSelected(ValueChanged<int> value) {
    _onDestinationSelected = value;
  }

  List<NavigationRailDestination> _destinations;
  set destinations(List<NavigationRailDestination> value) {
    _destinations = value;
    markNeedsLayout();
  }

  double _minWidth;
  set minWidth(double value) {
    if (_minWidth != value) {
      _minWidth = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  final List<Rect> _destinationRects = [];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _NavigationRailParentData) {
      child.parentData = _NavigationRailParentData();
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _destinationRects.clear();
    double currentY = 0;

    RenderBox? leading;
    RenderBox? trailing;
    final List<RenderBox> destChildren = [];

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _NavigationRailParentData;
      if (pd.slotType == _SlotType.leading) leading = child;
      if (pd.slotType == _SlotType.trailing) trailing = child;
      if (pd.slotType == _SlotType.destination) destChildren.add(child);
      child = childAfter(child);
    }

    // Layout leading
    if (leading != null) {
      leading.layout(BoxConstraints(maxWidth: _minWidth), parentUsesSize: true);
      final pd = leading.parentData as _NavigationRailParentData;
      pd.offset = Offset(0, currentY);
      currentY += leading.size.height + 16;
    }

    // Layout destinations
    const double itemHeight = 56.0;
    for (int i = 0; i < destChildren.length; i++) {
      final destChild = destChildren[i];
      destChild.layout(
        BoxConstraints(maxWidth: _minWidth, maxHeight: itemHeight),
        parentUsesSize: true,
      );
      final pd = destChild.parentData as _NavigationRailParentData;
      pd.offset = Offset(0, currentY);
      _destinationRects.add(Rect.fromLTWH(0, currentY, _minWidth, itemHeight));
      currentY += itemHeight;
    }

    // Layout trailing
    double trailingHeight = 0;
    if (trailing != null) {
      trailing.layout(
        BoxConstraints(maxWidth: _minWidth),
        parentUsesSize: true,
      );
      trailingHeight = trailing.size.height;
    }

    // Size
    final totalHeight = constraints.maxHeight;
    size = Size(_minWidth, totalHeight);

    // Position trailing at bottom
    if (trailing != null) {
      final pd = trailing.parentData as _NavigationRailParentData;
      pd.offset = Offset(0, totalHeight - trailingHeight);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Background
    final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(offset & size, bgPaint);

    // Paint children (for leading/trailing/icons)
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _NavigationRailParentData;
      if (pd.slotType == _SlotType.leading ||
          pd.slotType == _SlotType.trailing) {
        context.paintChild(child, pd.offset + offset);
      }
      child = childAfter(child);
    }

    // Paint destinations manually
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < _destinations.length; i++) {
      if (i >= _destinationRects.length) break;
      final rect = _destinationRects[i].shift(offset);
      final dest = _destinations[i];
      final isSelected = i == _selectedIndex;
      final isHovered = i == _hoveredIndex;

      // Hover/selection background
      if (isSelected || isHovered) {
        final bgColor = isSelected
            ? const Color(0x1F2196F3)
            : const Color(0x0F000000);
        canvas.drawRect(rect, Paint()..color = bgColor);
      }

      // Icon placeholder (center a circle or just text)
      final iconColor = isSelected
          ? const Color(0xFF2196F3)
          : const Color(0xFF757575);
      final labelColor = iconColor;

      // Paint icon symbol (simplified: use first char of label)
      textPainter.text = TextSpan(
        text: "●", // Placeholder icon
        style: TextStyle(color: iconColor, fontSize: 24),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.center.dx - textPainter.width / 2, rect.top + 8),
      );

      // Paint label
      textPainter.text = TextSpan(
        text: dest.label,
        style: TextStyle(color: labelColor, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.center.dx - textPainter.width / 2, rect.top + 36),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _destinationRects.length; i++) {
      if (_destinationRects[i].contains(local)) {
        _onDestinationSelected(i);
        break;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _destinationRects.length; i++) {
      if (_destinationRects[i].contains(local)) {
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
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}

class NavigationRailDestination {
  const NavigationRailDestination({
    required this.icon,
    required this.label,
    Widget? selectedIcon,
  }) : selectedIcon = selectedIcon ?? icon;

  final Widget icon;
  final Widget selectedIcon;
  final String label;
}
