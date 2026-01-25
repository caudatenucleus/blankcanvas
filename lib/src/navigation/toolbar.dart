import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

enum ToolbarSlotType { leading, middle, action }

class ToolbarParentData extends ContainerBoxParentData<RenderBox> {
  ToolbarSlotType? slot;
}

class ToolbarSlot extends ParentDataWidget<ToolbarParentData> {
  const ToolbarSlot({super.key, required this.slot, required super.child});
  final ToolbarSlotType slot;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as ToolbarParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Toolbar;
}

/// A typical application toolbar (action bar).
class Toolbar extends MultiChildRenderObjectWidget {
  Toolbar({
    super.key,
    Widget? leading,
    Widget? middle,
    List<Widget>? actions,
    this.height = 56.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.backgroundColor = const Color(0xFF2196F3),
  }) : super(children: _buildChildren(leading, middle, actions));

  final double height;
  final EdgeInsets padding;
  final Color backgroundColor;

  static List<Widget> _buildChildren(
    Widget? leading,
    Widget? middle,
    List<Widget>? actions,
  ) {
    final List<Widget> children = [];
    if (leading != null) {
      children.add(ToolbarSlot(slot: ToolbarSlotType.leading, child: leading));
    }
    if (middle != null) {
      children.add(ToolbarSlot(slot: ToolbarSlotType.middle, child: middle));
    }
    if (actions != null) {
      for (var action in actions) {
        children.add(ToolbarSlot(slot: ToolbarSlotType.action, child: action));
      }
    }
    return children;
  }

  @override
  RenderToolbar createRenderObject(BuildContext context) {
    return RenderToolbar(
      height: height,
      padding: padding,
      backgroundColor: backgroundColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderToolbar renderObject) {
    renderObject
      ..preferredHeight = height
      ..padding = padding
      ..backgroundColor = backgroundColor;
  }
}

class RenderToolbar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ToolbarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ToolbarParentData> {
  RenderToolbar({
    required double height,
    required EdgeInsets padding,
    required Color backgroundColor,
  }) : _preferredHeight = height,
       _padding = padding,
       _backgroundColor = backgroundColor;

  double _preferredHeight;
  set preferredHeight(double value) {
    if (_preferredHeight != value) {
      _preferredHeight = value;
      markNeedsLayout();
    }
  }

  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ToolbarParentData) {
      child.parentData = ToolbarParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, _preferredHeight));

    RenderBox? leading;
    RenderBox? middle;
    List<RenderBox> actions = [];

    // Categorize children
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as ToolbarParentData;
      if (pd.slot == ToolbarSlotType.leading) {
        leading = child;
      } else if (pd.slot == ToolbarSlotType.middle) {
        middle = child;
      } else if (pd.slot == ToolbarSlotType.action) {
        actions.add(child);
      }
      child = childAfter(child);
    }

    double left = _padding.left;
    double right = size.width - _padding.right;

    // Layout Leading
    if (leading != null) {
      leading.layout(
        BoxConstraints(maxHeight: size.height, maxWidth: size.width / 3),
        parentUsesSize: true,
      );
      (leading.parentData as ToolbarParentData).offset = Offset(
        left,
        (size.height - leading.size.height) / 2,
      );
      left += leading.size.width + 16.0;
    }

    // Layout Actions (Right to Left)
    for (var action in actions) {
      action.layout(
        BoxConstraints(maxHeight: size.height),
        parentUsesSize: true,
      );
      right -= action.size.width;
      (action.parentData as ToolbarParentData).offset = Offset(
        right,
        (size.height - action.size.height) / 2,
      );
      right -= 8.0; // Spacing
    }

    // Layout Middle
    if (middle != null) {
      // Middle takes remaining space between left and right (with checks)
      double middleMaxWidth = (right - left).clamp(0.0, double.infinity);
      middle.layout(
        BoxConstraints(maxHeight: size.height, maxWidth: middleMaxWidth),
        parentUsesSize: true,
      );
      (middle.parentData as ToolbarParentData).offset = Offset(
        left,
        (size.height - middle.size.height) / 2,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(offset & size, Paint()..color = _backgroundColor);
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
