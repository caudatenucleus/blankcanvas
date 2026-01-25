import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';

/// A breadcrumbs widget to show navigation hierarchy using lowest-level RenderObject APIs.
class Breadcrumbs extends MultiChildRenderObjectWidget {
  Breadcrumbs({
    super.key,
    required List<Widget> items,
    Widget separator = const ParagraphPrimitive(
      text: TextSpan(
        text: " / ",
        style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14.0),
      ),
    ),
    this.onItemTapped,
  }) : super(children: _buildChildren(items, separator));

  final ValueChanged<int>? onItemTapped;

  static List<Widget> _buildChildren(List<Widget> items, Widget separator) {
    if (items.isEmpty) return [];
    final List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      children.add(items[i]);
      if (i < items.length - 1) {
        children.add(separator);
      }
    }
    return children;
  }

  @override
  RenderBreadcrumbs createRenderObject(BuildContext context) {
    return RenderBreadcrumbs(onItemTapped: onItemTapped);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBreadcrumbs renderObject,
  ) {
    renderObject.onItemTapped = onItemTapped;
  }
}

class BreadcrumbsParentData extends ContainerBoxParentData<RenderBox> {
  int? itemIndex; // null if separator
}

class RenderBreadcrumbs extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, BreadcrumbsParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BreadcrumbsParentData> {
  RenderBreadcrumbs({ValueChanged<int>? onItemTapped})
    : _onItemTapped = onItemTapped {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  ValueChanged<int>? _onItemTapped;
  set onItemTapped(ValueChanged<int>? value) {
    _onItemTapped = value;
  }

  late final TapGestureRecognizer _tap;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BreadcrumbsParentData) {
      child.parentData = BreadcrumbsParentData();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_onItemTapped == null) return;

    // Find which child was tapped
    RenderBox? child = firstChild;
    while (child != null) {
      final BreadcrumbsParentData pd =
          child.parentData as BreadcrumbsParentData;
      // Check if item (not separator)
      if (pd.itemIndex != null) {
        if ((pd.offset & child.size).contains(details.localPosition)) {
          _onItemTapped!(pd.itemIndex!);
          return;
        }
      }
      child = pd.nextSibling;
    }
  }

  @override
  void performLayout() {
    // Horizontal layout
    double x = 0.0;
    double maxHeight = 0.0;

    RenderBox? child = firstChild;
    int index = 0;

    while (child != null) {
      child.layout(
        BoxConstraints.loose(constraints.biggest),
        parentUsesSize: true,
      );

      final BreadcrumbsParentData pd =
          child.parentData as BreadcrumbsParentData;
      pd.offset = Offset(x, 0);

      if (index % 2 == 0) {
        pd.itemIndex = index ~/ 2;
      } else {
        pd.itemIndex = null;
      }

      x += child.size.width;
      if (child.size.height > maxHeight) maxHeight = child.size.height;

      child = pd.nextSibling;
      index++;
    }

    child = firstChild;
    while (child != null) {
      final BreadcrumbsParentData pd =
          child.parentData as BreadcrumbsParentData;
      final double centeredY = (maxHeight - child.size.height) / 2;
      pd.offset = Offset(pd.offset.dx, centeredY);
      child = pd.nextSibling;
    }

    size = constraints.constrain(Size(x, maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
