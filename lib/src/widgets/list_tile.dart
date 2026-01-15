import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/customization.dart';
import '../theme/theme.dart';

/// A row primitive with leading, title, subtitle, and trailing slots.
class ListTile extends StatelessWidget {
  const ListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.tag,
    this.onTap,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final String? tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getListTile(tag) ?? ListTileCustomization.simple();

    final status = MutableControlStatus();
    final decoration = customization.decoration(status);

    return _ListTileContainerRenderWidget(
      decoration: decoration is BoxDecoration
          ? decoration
          : const BoxDecoration(),
      onTap: onTap,
      child: _ListTileRenderWidget(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        customization: customization,
      ),
    );
  }
}

class _ListTileContainerRenderWidget extends SingleChildRenderObjectWidget {
  const _ListTileContainerRenderWidget({
    super.child,
    required this.decoration,
    this.onTap,
  });

  final BoxDecoration decoration;
  final VoidCallback? onTap;

  @override
  RenderListTileContainer createRenderObject(BuildContext context) =>
      RenderListTileContainer(decoration: decoration, onTap: onTap);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderListTileContainer renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..onTap = onTap;
  }
}

class RenderListTileContainer extends RenderProxyBox {
  RenderListTileContainer({required BoxDecoration decoration, this.onTap})
    : _decoration = decoration;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  VoidCallback? onTap;

  int _hovered = 0;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent) {
      if (_hovered == 0) {
        _hovered = 1;
        markNeedsPaint();
      }
    } else if (event is PointerExitEvent) {
      if (_hovered == 1) {
        _hovered = 0;
        markNeedsPaint();
      }
    } else if (event is PointerDownEvent) {
      onTap?.call();
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0x00000000);
    context.canvas.drawRect(offset & size, paint);
    if (child != null) context.paintChild(child!, offset);
  }
}

class _ListTileRenderWidget extends MultiChildRenderObjectWidget {
  _ListTileRenderWidget({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    required this.customization,
  }) : super(
         children: [
           if (leading != null)
             _ListTileSlot(slot: ListTileSlotType.leading, child: leading),
           _ListTileSlot(slot: ListTileSlotType.title, child: title),
           if (subtitle != null)
             _ListTileSlot(slot: ListTileSlotType.subtitle, child: subtitle),
           if (trailing != null)
             _ListTileSlot(slot: ListTileSlotType.trailing, child: trailing),
         ],
       );

  final ListTileCustomization customization;

  @override
  RenderListTile createRenderObject(BuildContext context) =>
      RenderListTile(customization: customization);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderListTile renderObject,
  ) {
    renderObject.customization = customization;
  }
}

/// Slot types for ListTile child positioning.
enum ListTileSlotType { leading, title, subtitle, trailing }

class _ListTileSlot extends ParentDataWidget<ListTileParentData> {
  const _ListTileSlot({required this.slot, required super.child});

  final ListTileSlotType slot;

  @override
  void applyParentData(RenderObject renderObject) {
    final ListTileParentData parentData =
        renderObject.parentData! as ListTileParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      final RenderObject? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _ListTileRenderWidget;
}

class ListTileParentData extends ContainerBoxParentData<RenderBox> {
  ListTileSlotType? slot;
}

class RenderListTile extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ListTileParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ListTileParentData> {
  RenderListTile({required ListTileCustomization customization})
    : _customization = customization;

  ListTileCustomization _customization;
  ListTileCustomization get customization => _customization;
  set customization(ListTileCustomization value) {
    if (_customization == value) return;
    _customization = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ListTileParentData) {
      child.parentData = ListTileParentData();
    }
  }

  @override
  void performLayout() {
    final EdgeInsets padding =
        customization.contentPadding?.resolve(TextDirection.ltr) ??
        EdgeInsets.zero;

    RenderBox? leading;
    RenderBox? title;
    RenderBox? subtitle;
    RenderBox? trailing;

    RenderBox? child = firstChild;
    while (child != null) {
      final ListTileParentData childParentData =
          child.parentData! as ListTileParentData;
      switch (childParentData.slot) {
        case ListTileSlotType.leading:
          leading = child;
          break;
        case ListTileSlotType.title:
          title = child;
          break;
        case ListTileSlotType.subtitle:
          subtitle = child;
          break;
        case ListTileSlotType.trailing:
          trailing = child;
          break;
        case null:
          break;
      }
      child = childAfter(child);
    }

    double currentX = padding.left;

    // 1. Layout Leading
    if (leading != null) {
      leading.layout(constraints.loosen(), parentUsesSize: true);
      (leading.parentData! as ListTileParentData).offset = Offset(
        currentX,
        padding.top,
      );
      currentX +=
          leading.size.width + 16; // 16 is space between leading and content
    }

    // 2. Layout Trailing to know how much space is left for title/subtitle
    double trailingWidth = 0;
    if (trailing != null) {
      trailing.layout(constraints.loosen(), parentUsesSize: true);
      trailingWidth = trailing.size.width + 16;
    }

    // 3. Layout Title and Subtitle
    final double availableWidth =
        (constraints.maxWidth - currentX - trailingWidth - padding.right).clamp(
          0.0,
          double.infinity,
        );

    double contentHeight = 0;
    if (title != null) {
      title.layout(
        BoxConstraints(maxWidth: availableWidth),
        parentUsesSize: true,
      );
      (title.parentData! as ListTileParentData).offset = Offset(
        currentX,
        padding.top,
      );
      contentHeight += title.size.height;
    }

    if (subtitle != null) {
      subtitle.layout(
        BoxConstraints(maxWidth: availableWidth),
        parentUsesSize: true,
      );
      (subtitle.parentData! as ListTileParentData).offset = Offset(
        currentX,
        padding.top + contentHeight + 4,
      );
      contentHeight += subtitle.size.height + 4;
    }

    // 4. Position Trailing
    if (trailing != null) {
      (trailing.parentData! as ListTileParentData).offset = Offset(
        constraints.maxWidth - padding.right - trailing.size.width,
        padding.top,
      );
    }

    final double totalHeight = (contentHeight + padding.vertical).clamp(
      leading?.size.height ?? 0,
      constraints.maxHeight,
    );
    size = constraints.constrain(Size(constraints.maxWidth, totalHeight));

    // Centering vertically for leading and trailing if they are smaller than content
    if (leading != null) {
      final double leadingY = (size.height - leading.size.height) / 2;
      (leading.parentData! as ListTileParentData).offset = Offset(
        padding.left,
        leadingY,
      );
    }
    if (trailing != null) {
      final double trailingY = (size.height - trailing.size.height) / 2;
      (trailing.parentData! as ListTileParentData).offset = Offset(
        size.width - padding.right - trailing.size.width,
        trailingY,
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
