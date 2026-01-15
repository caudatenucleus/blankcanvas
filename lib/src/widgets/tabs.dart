import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';
import '../theme/customization.dart';
import 'layout.dart';

/// Status for a single Tab.
class TabStatus extends TabControlStatus {}

/// A Segmented Control / Tab Bar.
/// It renders a list of items and handles selection.
/// Each item is a 'Tab'.
class TabControl<T> extends StatefulWidget {
  const TabControl({
    super.key,
    required this.items,
    required this.groupValue,
    required this.onChanged,
    this.itemBuilder,
    this.tag,
  });

  final List<T> items;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Widget Function(BuildContext context, T item, TabStatus status)?
  itemBuilder;
  final String? tag;

  @override
  State<TabControl<T>> createState() => _TabControlState();
}

class _TabControlState<T> extends State<TabControl<T>> {
  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTab(widget.tag);

    return FlexBox(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      children: widget.items.map((item) {
        return _TabItem<T>(
          item: item,
          isSelected: item == widget.groupValue,
          onChanged: widget.onChanged,
          customization: customization,
          builder: widget.itemBuilder,
        );
      }).toList(),
    );
  }
}

class _TabItem<T> extends StatefulWidget {
  const _TabItem({
    required this.item,
    required this.isSelected,
    required this.onChanged,
    this.customization,
    this.builder,
  });

  final T item;
  final bool isSelected;
  final ValueChanged<T> onChanged;
  final TabCustomization? customization;
  final Widget Function(BuildContext context, T item, TabStatus status)?
  builder;

  @override
  State<_TabItem<T>> createState() => _TabItemState<T>();
}

class _TabItemState<T> extends State<_TabItem<T>>
    with SingleTickerProviderStateMixin {
  final TabStatus _status = TabStatus();
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
    _status.selected = widget.isSelected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(_TabItem<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _status.selected = widget.isSelected ? 1.0 : 0.0;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.customization?.decoration(_status);
    final textStyle =
        widget.customization?.textStyle(_status) ?? const TextStyle();

    Widget child;
    if (widget.builder != null) {
      child = widget.builder!(context, widget.item, _status);
    } else {
      child = Text("${widget.item}");
    }

    return Semantics(
      selected: widget.isSelected,
      button: true,
      onTap: () => widget.onChanged(widget.item),
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.onChanged(widget.item),
          child: _TabRenderWidget(
            decoration: decoration is BoxDecoration
                ? decoration
                : const BoxDecoration(),
            padding:
                widget.customization?.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DefaultTextStyle(style: textStyle, child: child),
          ),
        ),
      ),
    );
  }
}

class _TabRenderWidget extends SingleChildRenderObjectWidget {
  const _TabRenderWidget({
    super.child,
    required this.decoration,
    required this.padding,
  });

  final BoxDecoration decoration;
  final EdgeInsetsGeometry padding;

  @override
  RenderTab createRenderObject(BuildContext context) {
    return RenderTab(decoration: decoration, padding: padding);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTab renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..padding = padding;
  }
}

class RenderTab extends RenderProxyBox {
  RenderTab({
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
