import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A tile in a grid with header/footer overlays.
class GridTile extends MultiChildRenderObjectWidget {
  GridTile({super.key, Widget? header, Widget? footer, required Widget child})
    : super(
        children: [
          if (header != null)
            _GridTileSlot(slot: _GridTileSlotType.header, child: header),
          if (footer != null)
            _GridTileSlot(slot: _GridTileSlotType.footer, child: footer),
          _GridTileSlot(slot: _GridTileSlotType.body, child: child),
        ],
      );

  @override
  RenderGridTile createRenderObject(BuildContext context) {
    return RenderGridTile();
  }
}

enum _GridTileSlotType { header, footer, body }

class _GridTileParentData extends ContainerBoxParentData<RenderBox> {
  _GridTileSlotType slot = _GridTileSlotType.body;
}

class _GridTileSlot extends ParentDataWidget<_GridTileParentData> {
  const _GridTileSlot({required this.slot, required super.child});
  final _GridTileSlotType slot;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData as _GridTileParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => GridTile;
}

class RenderGridTile extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _GridTileParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _GridTileParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridTileParentData) {
      child.parentData = _GridTileParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    if (size.isEmpty) {
      size = constraints.constrain(
        const Size(100, 100),
      ); // Default if unbounded
    }

    RenderBox? body;
    RenderBox? header;
    RenderBox? footer;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as _GridTileParentData;
      if (pd.slot == _GridTileSlotType.body) {
        body = child;
      } else if (pd.slot == _GridTileSlotType.header) {
        header = child;
      } else if (pd.slot == _GridTileSlotType.footer) {
        footer = child;
      }
      child = childAfter(child);
    }

    if (body != null) {
      body.layout(BoxConstraints.tight(size));
      (body.parentData as _GridTileParentData).offset = Offset.zero;
    }

    if (header != null) {
      header.layout(
        BoxConstraints(maxWidth: size.width, maxHeight: size.height),
        parentUsesSize: true,
      );
      (header.parentData as _GridTileParentData).offset = Offset.zero;
    }

    if (footer != null) {
      footer.layout(
        BoxConstraints(maxWidth: size.width, maxHeight: size.height),
        parentUsesSize: true,
      );
      (footer.parentData as _GridTileParentData).offset = Offset(
        0,
        size.height - footer.size.height,
      );
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
