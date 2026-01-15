import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';
import 'layout.dart';

/// Status for a BottomBar Item.
class BottomBarItemStatus extends BottomBarItemControlStatus {}

/// A Bottom Navigation Bar Item.
class BottomBarItem extends StatefulWidget {
  const BottomBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.tag,
  });

  final Widget icon;
  final Widget label;
  final bool selected;
  final VoidCallback onTap;
  final String? tag;

  @override
  State<BottomBarItem> createState() => _BottomBarItemState();
}

class _BottomBarItemState extends State<BottomBarItem>
    with SingleTickerProviderStateMixin {
  final BottomBarItemStatus _status = BottomBarItemStatus();
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _hoverController.addListener(
      () => setState(() {
        _status.hovered = _hoverController.value;
      }),
    );
    _status.selected = widget.selected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(BottomBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _status.selected = widget.selected ? 1.0 : 0.0;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getBottomBarItem(widget.tag);

    final decoration =
        customization?.decoration(_status) ?? const BoxDecoration();
    final textStyle = customization?.textStyle(_status) ?? const TextStyle();
    final padding = customization?.padding ?? const EdgeInsets.all(8);

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: _BottomBarItemRenderWidget(
          decoration: decoration is BoxDecoration
              ? decoration
              : const BoxDecoration(),
          padding: padding,
          child: FlexBox(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  color: textStyle.color,
                  size: textStyle.fontSize != null
                      ? textStyle.fontSize! * 1.5
                      : 24,
                ),
                child: widget.icon,
              ),
              DefaultTextStyle(style: textStyle, child: widget.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItemRenderWidget extends SingleChildRenderObjectWidget {
  const _BottomBarItemRenderWidget({
    super.child,
    required this.decoration,
    required this.padding,
  });

  final BoxDecoration decoration;
  final EdgeInsetsGeometry padding;

  @override
  RenderBottomBarItemBox createRenderObject(BuildContext context) {
    return RenderBottomBarItemBox(decoration: decoration, padding: padding);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBottomBarItemBox renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..padding = padding;
  }
}

class RenderBottomBarItemBox extends RenderProxyBox {
  RenderBottomBarItemBox({
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

    // Paint background
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

/// A Bottom Navigation Bar.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.items, this.tag});

  final List<Widget> items;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getBottomBar(tag);

    final status = BottomBarControlStatus();
    final decoration =
        customization?.decoration(status) ??
        const BoxDecoration(color: Color(0xFFEEEEEE));
    final double? height = customization?.height;

    return _BottomBarRenderWidget(
      decoration: decoration is BoxDecoration
          ? decoration
          : const BoxDecoration(),
      height: height,
      child: LayoutBox(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: FlexBox(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: items,
        ),
      ),
    );
  }
}

class _BottomBarRenderWidget extends SingleChildRenderObjectWidget {
  const _BottomBarRenderWidget({
    super.child,
    required this.decoration,
    this.height,
  });

  final BoxDecoration decoration;
  final double? height;

  @override
  RenderBottomBarBox createRenderObject(BuildContext context) {
    return RenderBottomBarBox(decoration: decoration, heightValue: height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBottomBarBox renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..heightValue = height;
  }
}

class RenderBottomBarBox extends RenderProxyBox {
  RenderBottomBarBox({required BoxDecoration decoration, double? heightValue})
    : _decoration = decoration,
      _heightValue = heightValue;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  double? _heightValue;
  double? get heightValue => _heightValue;
  set heightValue(double? value) {
    if (_heightValue == value) return;
    _heightValue = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      size = constraints.constrain(
        Size(constraints.maxWidth, heightValue ?? child!.size.height),
      );
    } else {
      size = constraints.constrain(
        Size(constraints.maxWidth, heightValue ?? 0.0),
      );
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
      context.paintChild(child!, offset);
    }
  }
}
