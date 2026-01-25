import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';
import 'package:blankcanvas/src/rendering/icon_primitive.dart';

class QuickActionItem {
  const QuickActionItem({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
}

/// A row of quick action buttons using lowest-level RenderObject APIs.
class QuickActions extends MultiChildRenderObjectWidget {
  QuickActions({
    super.key,
    required this.actions,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.borderRadius = 8,
    this.tag,
  }) : super(children: _buildItems(actions));

  final List<QuickActionItem> actions;
  final Color backgroundColor;
  final double borderRadius;
  final String? tag;

  static List<Widget> _buildItems(List<QuickActionItem> actions) {
    return actions
        .map(
          (a) => layout.Center(
            child: layout.Column(
              children: [
                IconPrimitive(
                  icon: a.icon,
                  color: const Color(0xFF333333),
                  size: 24,
                ),
                ParagraphPrimitive(
                  text: TextSpan(
                    text: a.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  @override
  RenderQuickActions createRenderObject(BuildContext context) {
    return RenderQuickActions(
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderQuickActions renderObject,
  ) {
    renderObject
      ..backgroundColor = backgroundColor
      ..borderRadius = borderRadius;
  }
}

class QuickActionsParentData extends ContainerBoxParentData<RenderBox> {
  int? index;
}

class RenderQuickActions extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, QuickActionsParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, QuickActionsParentData> {
  RenderQuickActions({
    required Color backgroundColor,
    required double borderRadius,
  }) : _backgroundColor = backgroundColor,
       _borderRadius = borderRadius;

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

  static const double _itemWidth = 64.0;
  static const double _itemHeight = 60.0;
  static const double _padding = 4.0;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! QuickActionsParentData) {
      child.parentData = QuickActionsParentData();
    }
  }

  @override
  void performLayout() {
    double x = _padding;
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      final pd = child.parentData! as QuickActionsParentData;
      pd.index = i;
      child.layout(
        BoxConstraints.tightFor(width: _itemWidth, height: _itemHeight),
        parentUsesSize: true,
      );
      pd.offset = Offset(x, _padding);
      x += _itemWidth;
      child = pd.nextSibling;
      i++;
    }
    size = constraints.constrain(
      Size(x + _padding, _itemHeight + _padding * 2),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final bgRect = offset & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, Radius.circular(_borderRadius)),
      Paint()..color = _backgroundColor,
    );
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
