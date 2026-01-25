import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// A row primitive using lowest-level RenderObject APIs.
class ListTile extends MultiChildRenderObjectWidget {
  ListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.tag,
    this.onTap,
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

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final String? tag;
  final VoidCallback? onTap;

  @override
  RenderListTile createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getListTile(tag) ?? ListTileCustomization.simple();
    // Helper to resolve decoration?
    // Decoration depends on status (hovered/pressed/etc).
    // RenderListTile will handle status and resolving decoration if we pass the customization/resolver.

    return RenderListTile(customization: customization, onTap: onTap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderListTile renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getListTile(tag) ?? ListTileCustomization.simple();

    renderObject
      ..customization = customization
      ..onTap = onTap;
  }
}

/// Slot types for ListTile child positioning.
enum ListTileSlotType { leading, title, subtitle, trailing }

class ListTileParentData extends ContainerBoxParentData<RenderBox> {
  ListTileSlotType? slot;
}

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
  Type get debugTypicalAncestorWidgetClass => ListTile;
}

class RenderListTile extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ListTileParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ListTileParentData> {
  RenderListTile({
    required ListTileCustomization customization,
    VoidCallback? onTap,
  }) : _customization = customization,
       _onTap = onTap;

  ListTileCustomization _customization;
  ListTileCustomization get customization => _customization;
  set customization(ListTileCustomization value) {
    if (_customization == value) return;
    _customization = value;
    markNeedsLayout(); // Padding might change
    markNeedsPaint(); // Decoration might change
  }

  VoidCallback? _onTap;
  VoidCallback? get onTap => _onTap;
  set onTap(VoidCallback? value) {
    if (_onTap == value) return;
    _onTap = value;
    // Update semantics if needed
    markNeedsSemanticsUpdate();
  }

  // Status tracking
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ListTileParentData) {
      child.parentData = ListTileParentData();
    }
  }

  @override
  void performLayout() {
    // Resolve padding
    final EdgeInsets padding =
        _customization.contentPadding?.resolve(TextDirection.ltr) ??
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
        default:
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
      currentX += leading.size.width + 16;
    }

    // 2. Layout Trailing
    double trailingWidth = 0;
    if (trailing != null) {
      trailing.layout(constraints.loosen(), parentUsesSize: true);
      trailingWidth = trailing.size.width + 16;
    }

    // 3. Layout Title/Subtitle
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
    // Also consider min height if defined in customization?

    size = constraints.constrain(Size(constraints.maxWidth, totalHeight));

    // Centering
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
    // Resolve decoration based on status
    final status = MutableControlStatus()..hovered = _isHovered ? 1.0 : 0.0;
    // We map pressed to focused for simplicity or ignore pressed if not supported in base status
    // (Base status supports focused/hovered/enabled)
    if (_isPressed) status.focused = 1.0;

    final decoration = _customization.decoration.call(status);

    final BoxPainter painter = decoration.createBoxPainter();
    painter.paint(context.canvas, offset, ImageConfiguration(size: size));
    painter.dispose();

    // Draw children
    defaultPaint(context, offset);
  }

  @override
  bool hitTestSelf(Offset position) => true; // Always intercept if we have onTap?

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    bool dirty = false;

    if (event is PointerDownEvent) {
      if (onTap != null) {
        _isPressed = true;
        dirty = true;
        // Invoke onTap? Usually onTap is on Up.
        // GestureRecognizer handles tap logic (down/up/cancel).
        // Since we are doing "raw" handling:
      }
    } else if (event is PointerUpEvent) {
      if (_isPressed) {
        _isPressed = false;
        dirty = true;
        onTap?.call();
      }
    } else if (event is PointerCancelEvent) {
      if (_isPressed) {
        _isPressed = false;
        dirty = true;
      }
    } else if (event is PointerHoverEvent) {
      if (!_isHovered) {
        _isHovered = true;
        dirty = true;
      }
    } else if (event is PointerExitEvent) {
      if (_isHovered) {
        _isHovered = false;
        dirty = true;
      }
    }

    if (dirty) {
      markNeedsPaint();
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    if (onTap != null) {
      config.isButton = true;
      config.isEnabled = true;
      config.onTap = onTap;
    }
  }
}
