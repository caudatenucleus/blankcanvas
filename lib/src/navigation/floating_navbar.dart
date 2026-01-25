import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';
import 'package:blankcanvas/src/rendering/icon_primitive.dart';

class FloatingNavbarItem {
  const FloatingNavbarItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// A floating navigation bar, typically placed at the bottom of the screen.
class FloatingNavbar extends MultiChildRenderObjectWidget {
  FloatingNavbar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor = const Color(0xFF222222),
    this.selectedItemColor = const Color(0xFFFFFFFF),
    this.unselectedItemColor = const Color(0xFF888888),
    this.borderRadius = 32,
    this.tag,
  }) : super(
         children: _buildItems(
           items,
           currentIndex,
           selectedItemColor,
           unselectedItemColor,
         ),
       );

  final List<FloatingNavbarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final double borderRadius;
  final String? tag;

  static List<Widget> _buildItems(
    List<FloatingNavbarItem> items,
    int currentIndex,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      final isSelected = i == currentIndex;
      final color = isSelected ? selectedColor : unselectedColor;
      children.add(
        layout.Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconPrimitive(icon: items[i].icon, color: color, size: 24),
            if (isSelected)
              ParagraphPrimitive(
                text: TextSpan(
                  text: items[i].label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return children;
  }

  @override
  RenderFloatingNavbar createRenderObject(BuildContext context) {
    return RenderFloatingNavbar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFloatingNavbar renderObject,
  ) {
    renderObject
      ..currentIndex = currentIndex
      ..onTap = onTap
      ..backgroundColor = backgroundColor
      ..borderRadius = borderRadius;
  }
}

class FloatingNavbarParentData extends ContainerBoxParentData<RenderBox> {
  int? index;
}

class RenderFloatingNavbar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FloatingNavbarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FloatingNavbarParentData> {
  RenderFloatingNavbar({
    required int currentIndex,
    ValueChanged<int>? onTap,
    required Color backgroundColor,
    required double borderRadius,
  }) : _currentIndex = currentIndex,
       _onTap = onTap,
       _backgroundColor = backgroundColor,
       _borderRadius = borderRadius;

  int _currentIndex;
  set currentIndex(int value) {
    if (_currentIndex != value) {
      _currentIndex = value;
      markNeedsLayout();
    }
  }

  ValueChanged<int>? _onTap;
  set onTap(ValueChanged<int>? value) {
    _onTap = value;
  }

  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  double _borderRadius;
  set borderRadius(double value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsPaint();
    }
  }

  static const double _itemWidth = 56.0;
  static const double _selectedItemWidth = 80.0;
  static const double _height = 56.0;
  static const double _hPadding = 24.0;
  static const double _vPadding = 8.0;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FloatingNavbarParentData) {
      child.parentData = FloatingNavbarParentData();
    }
  }

  @override
  void performLayout() {
    double x = _hPadding;
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      final isSelected = i == _currentIndex;
      final w = isSelected ? _selectedItemWidth : _itemWidth;
      final pd = child.parentData! as FloatingNavbarParentData;
      pd.index = i;

      child.layout(
        BoxConstraints.tightFor(width: w, height: _height - _vPadding * 2),
        parentUsesSize: true,
      );
      pd.offset = Offset(x, _vPadding);

      x += w;
      child = pd.nextSibling;
      i++;
    }
    size = constraints.constrain(Size(x + _hPadding, _height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Shadow
    final bgRect = offset & size;
    final shadowPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(bgRect, Radius.circular(_borderRadius)),
      );
    canvas.drawShadow(shadowPath, const Color(0xFF000000), 16, false);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, Radius.circular(_borderRadius)),
      Paint()..color = _backgroundColor,
    );

    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = firstChild;
    while (child != null) {
      final pd = child.parentData! as FloatingNavbarParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: pd.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        _onTap?.call(pd.index!);
        return true;
      }
      child = pd.nextSibling;
    }
    return false;
  }
}
