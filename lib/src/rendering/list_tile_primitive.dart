import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A widget that implements the complex layout of a list tile using lowest-level RenderObject APIs.
class ListTilePrimitive extends MultiChildRenderObjectWidget {
  ListTilePrimitive({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.dense = false,
    this.contentPadding,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.focusNode,
    this.autofocus = false,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback = true,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
  }) : super(
         children: [
           if (leading != null) leading,
           if (title != null) title,
           if (subtitle != null) subtitle,
           if (trailing != null) trailing,
         ],
       );

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final bool dense;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? tileColor;
  final Color? selectedTileColor;
  final bool enableFeedback;
  final double? horizontalTitleGap;
  final double? minVerticalPadding;
  final double? minLeadingWidth;

  @override
  RenderListTilePrimitive createRenderObject(BuildContext context) {
    return RenderListTilePrimitive(
      isThreeLine: isThreeLine,
      dense: dense,
      contentPadding: contentPadding,
      tileColor: selected ? selectedTileColor : tileColor,
      minLeadingWidth: minLeadingWidth,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderListTilePrimitive renderObject,
  ) {
    renderObject
      ..isThreeLine = isThreeLine
      ..dense = dense
      ..contentPadding = contentPadding
      ..tileColor = selected ? selectedTileColor : tileColor
      ..minLeadingWidth = minLeadingWidth
      ..horizontalTitleGap = horizontalTitleGap
      ..minVerticalPadding = minVerticalPadding;
  }
}

class ListTilePrimitiveParentData extends ContainerBoxParentData<RenderBox> {}

class RenderListTilePrimitive extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ListTilePrimitiveParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ListTilePrimitiveParentData
        > {
  RenderListTilePrimitive({
    required bool isThreeLine,
    required bool dense,
    EdgeInsetsGeometry? contentPadding,
    Color? tileColor,
    double? minLeadingWidth,
    double? horizontalTitleGap,
    double? minVerticalPadding,
  }) : _isThreeLine = isThreeLine,
       _dense = dense,
       _contentPadding = contentPadding,
       _tileColor = tileColor,
       _minLeadingWidth = minLeadingWidth,
       _horizontalTitleGap = horizontalTitleGap,
       _minVerticalPadding = minVerticalPadding;

  // ignore: unused_field
  bool _isThreeLine;
  set isThreeLine(bool value) {
    if (_isThreeLine == value) return;
    _isThreeLine = value;
    markNeedsLayout();
  }

  bool _dense;
  set dense(bool value) {
    if (_dense == value) return;
    _dense = value;
    markNeedsLayout();
  }

  EdgeInsetsGeometry? _contentPadding;
  set contentPadding(EdgeInsetsGeometry? value) {
    if (_contentPadding == value) return;
    _contentPadding = value;
    markNeedsLayout();
  }

  Color? _tileColor;
  set tileColor(Color? value) {
    if (_tileColor == value) return;
    _tileColor = value;
    markNeedsPaint();
  }

  // ignore: unused_field
  double? _minLeadingWidth;
  set minLeadingWidth(double? value) {
    if (_minLeadingWidth == value) return;
    _minLeadingWidth = value;
    markNeedsLayout();
  }

  // ignore: unused_field
  double? _horizontalTitleGap;
  set horizontalTitleGap(double? value) {
    if (_horizontalTitleGap == value) return;
    _horizontalTitleGap = value;
    markNeedsLayout();
  }

  // ignore: unused_field
  double? _minVerticalPadding;
  set minVerticalPadding(double? value) {
    if (_minVerticalPadding == value) return;
    _minVerticalPadding = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ListTilePrimitiveParentData) {
      child.parentData = ListTilePrimitiveParentData();
    }
  }

  @override
  void performLayout() {
    final padding =
        (_contentPadding ?? const EdgeInsets.symmetric(horizontal: 16.0))
            .resolve(TextDirection.ltr);

    double currentX = padding.left;
    double maxHeight = _dense ? 48.0 : 56.0;

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final pd = child.parentData! as ListTilePrimitiveParentData;
      pd.offset = Offset(currentX, (maxHeight - child.size.height) / 2);
      currentX += child.size.width + 16.0;
      child = pd.nextSibling;
    }

    size = constraints.constrain(Size(constraints.maxWidth, maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_tileColor != null) {
      context.canvas.drawRect(offset & size, Paint()..color = _tileColor!);
    }
    defaultPaint(context, offset);
  }
}
