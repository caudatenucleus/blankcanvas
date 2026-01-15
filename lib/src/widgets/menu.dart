import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';
import 'layout.dart';

/// Status for a Menu Item.
class MenuItemStatus extends MenuItemControlStatus {}

/// A Menu Item widget.
class MenuItem extends StatefulWidget {
  const MenuItem({
    super.key,
    required this.child,
    required this.onPressed,
    this.tag,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? tag;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem>
    with SingleTickerProviderStateMixin {
  final MenuItemStatus _status = MenuItemStatus();
  late final AnimationController _hoverController;
  late final AnimationController _focusController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _hoverController.addListener(
      () => setState(() {
        _status.hovered = _hoverController.value;
      }),
    );
    _focusController.addListener(
      () => setState(() {
        _status.focused = _focusController.value;
      }),
    );

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });

    _status.enabled = widget.onPressed != null ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getMenuItem(widget.tag);

    final decoration =
        customization?.decoration(_status) ?? const BoxDecoration();
    final textStyle =
        customization?.textStyle(_status) ??
        const TextStyle(color: Color(0xFF000000));
    final padding =
        customization?.padding ??
        const EdgeInsets.symmetric(vertical: 8, horizontal: 16);

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Focus(
          focusNode: _focusNode,
          child: _MenuItemRenderWidget(
            decoration: decoration is BoxDecoration
                ? decoration
                : const BoxDecoration(),
            padding: padding,
            child: DefaultTextStyle(style: textStyle, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _MenuItemRenderWidget extends SingleChildRenderObjectWidget {
  const _MenuItemRenderWidget({
    super.child,
    required this.decoration,
    required this.padding,
  });

  final BoxDecoration decoration;
  final EdgeInsetsGeometry padding;

  @override
  RenderMenuItemBox createRenderObject(BuildContext context) {
    return RenderMenuItemBox(decoration: decoration, padding: padding);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderMenuItemBox renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..padding = padding;
  }
}

class RenderMenuItemBox extends RenderProxyBox {
  RenderMenuItemBox({
    required BoxDecoration decoration,
    required EdgeInsetsGeometry padding,
  }) : _decoration = decoration,
       _padding = padding;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  EdgeInsetsGeometry _padding;
  EdgeInsetsGeometry get padding => _padding;
  set padding(EdgeInsetsGeometry value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child != null) {
      final resolvedPadding = padding.resolve(TextDirection.ltr);
      child!.layout(constraints.deflate(resolvedPadding), parentUsesSize: true);
      size = constraints.constrain(
        Size(
          child!.size.width + resolvedPadding.horizontal,
          child!.size.height + resolvedPadding.vertical,
        ),
      );

      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = resolvedPadding.topLeft;
    } else {
      size = constraints.constrain(Size.zero);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0x00000000);

    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
      context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
      if (decoration.border != null) {
        decoration.border!.paint(
          context.canvas,
          rect,
          borderRadius: borderRadius,
        );
      }
    } else {
      context.canvas.drawRect(rect, paint);
      if (decoration.border != null) {
        decoration.border!.paint(context.canvas, rect);
      }
    }

    if (child != null) {
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      context.paintChild(child!, childParentData.offset + offset);
    }
  }
}

/// A vertical Menu container.
class Menu extends StatelessWidget {
  const Menu({super.key, required this.children, this.tag});

  final List<Widget> children;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getMenu(tag);

    final status = CardControlStatus(); // Static for now
    final decoration =
        customization?.decoration(status) ?? const BoxDecoration();
    final textStyle = customization?.textStyle(status) ?? const TextStyle();

    return _MenuRenderWidget(
      decoration: decoration is BoxDecoration
          ? decoration
          : const BoxDecoration(),
      child: DefaultTextStyle(
        style: textStyle,
        child: FlexBox(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _MenuRenderWidget extends SingleChildRenderObjectWidget {
  const _MenuRenderWidget({super.child, required this.decoration});

  final BoxDecoration decoration;

  @override
  RenderMenuBox createRenderObject(BuildContext context) {
    return RenderMenuBox(decoration: decoration);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderMenuBox renderObject,
  ) {
    renderObject.decoration = decoration;
  }
}

class RenderMenuBox extends RenderProxyBox {
  RenderMenuBox({required BoxDecoration decoration}) : _decoration = decoration;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0x00000000);

    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
      context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
      if (decoration.border != null) {
        decoration.border!.paint(
          context.canvas,
          rect,
          borderRadius: borderRadius,
        );
      }
    } else {
      context.canvas.drawRect(rect, paint);
      if (decoration.border != null) {
        decoration.border!.paint(context.canvas, rect);
      }
    }

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}

// TODO: Helper for popup menus (overlay)
