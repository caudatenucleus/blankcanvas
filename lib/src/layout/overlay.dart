import 'package:flutter/widgets.dart'
    hide Overlay, OverlayEntry, OverlayState, Stack;
import 'package:flutter/rendering.dart';

/// A simplified Overlay using lowest-level RenderObject APIs.
class Overlay extends MultiChildRenderObjectWidget {
  Overlay({super.key, required this.initialEntries})
    : super(
        children: initialEntries
            .map((e) => Builder(builder: e.builder))
            .toList(),
      );

  final List<OverlayEntry> initialEntries;

  @override
  RenderOverlay createRenderObject(BuildContext context) {
    return RenderOverlay();
  }

  @override
  void updateRenderObject(BuildContext context, RenderOverlay renderObject) {
    // Basic update
  }
}

class RenderOverlay extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StackParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! StackParentData) {
      child.parentData = StackParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints.tighten(), parentUsesSize: true);
      child = (child.parentData! as StackParentData).nextSibling;
    }
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

class OverlayEntry {
  OverlayEntry({required this.builder});
  final WidgetBuilder builder;

  void remove() {
    // In real implementation, this would communicate with the Overlay.
  }
}
