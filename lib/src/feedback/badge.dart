import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Badge.
class BadgeStatus extends BadgeControlStatus {}

/// A low-level Badge implemented using RenderObject.
class Badge extends MultiChildRenderObjectWidget {
  Badge({
    super.key,
    this.child,
    this.label,
    this.tag,
    this.alignment = Alignment.topRight,
  }) : super(children: [if (child != null) child, if (label != null) label]);

  final Widget? child;
  final Widget? label;
  final String? tag;
  final AlignmentGeometry alignment;

  @override
  RenderBadge createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getBadge(tag);
    final decoration = customization?.decoration(BadgeStatus());

    return RenderBadge(
      decoration: decoration is BoxDecoration
          ? decoration
          : const BoxDecoration(color: Color(0xFFFF0000)),
      padding:
          customization?.padding ??
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      alignment: alignment,
      hasChild: child != null,
      hasLabel: label != null,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBadge renderObject,
  ) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getBadge(tag);
    final decoration = customization?.decoration(BadgeStatus());

    renderObject
      ..decoration = decoration is BoxDecoration
          ? decoration
          : const BoxDecoration(color: Color(0xFFFF0000))
      ..padding =
          customization?.padding ??
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
      ..alignment = alignment
      ..hasChild = child != null
      ..hasLabel = label != null;
  }
}

class BadgeParentData extends ContainerBoxParentData<RenderBox> {}

class RenderBadge extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, BadgeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BadgeParentData> {
  RenderBadge({
    required BoxDecoration decoration,
    required EdgeInsetsGeometry padding,
    required AlignmentGeometry alignment,
    required bool hasChild,
    required bool hasLabel,
  }) : _decoration = decoration,
       _padding = padding,
       _alignment = alignment,
       _hasChild = hasChild,
       _hasLabel = hasLabel;

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

  AlignmentGeometry _alignment;
  AlignmentGeometry get alignment => _alignment;
  set alignment(AlignmentGeometry value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  bool _hasChild;
  bool get hasChild => _hasChild;
  set hasChild(bool value) {
    if (_hasChild == value) return;
    _hasChild = value;
    markNeedsLayout();
  }

  bool _hasLabel;
  bool get hasLabel => _hasLabel;
  set hasLabel(bool value) {
    if (_hasLabel == value) return;
    _hasLabel = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BadgeParentData) {
      child.parentData = BadgeParentData();
    }
  }

  @override
  void performLayout() {
    if (!hasChild && !hasLabel) {
      size = constraints.smallest;
      return;
    }

    if (hasChild) {
      final RenderBox mainChild = firstChild!;
      mainChild.layout(constraints, parentUsesSize: true);
      size = mainChild.size;

      if (hasLabel) {
        final RenderBox labelChild = lastChild!;
        labelChild.layout(const BoxConstraints(), parentUsesSize: true);

        final BadgeParentData labelData =
            labelChild.parentData! as BadgeParentData;
        final Alignment resolvedAlignment = alignment.resolve(
          TextDirection.ltr,
        );

        // Position label relative to main child
        final Offset labelOffset = resolvedAlignment.alongSize(mainChild.size);
        // Center the label on the corner
        labelData.offset =
            labelOffset -
            Offset(labelChild.size.width / 2, labelChild.size.height / 2);
      }
    } else if (hasLabel) {
      final RenderBox labelChild = firstChild!;
      labelChild.layout(constraints.loosen(), parentUsesSize: true);
      size = labelChild.size;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (hasChild) {
      final RenderBox mainChild = firstChild!;
      context.paintChild(mainChild, offset);

      if (hasLabel) {
        final RenderBox labelChild = lastChild!;
        final BadgeParentData labelData =
            labelChild.parentData! as BadgeParentData;

        // Paint badge background
        final Rect badgeRect = (labelData.offset + offset) & labelChild.size;
        final Paint paint = Paint()
          ..color = decoration.color ?? const Color(0xFFFF0000);

        if (decoration.borderRadius != null) {
          context.canvas.drawRRect(
            decoration.borderRadius!
                .resolve(TextDirection.ltr)
                .toRRect(badgeRect),
            paint,
          );
        } else if (decoration.shape == BoxShape.circle) {
          context.canvas.drawCircle(
            badgeRect.center,
            badgeRect.shortestSide / 2,
            paint,
          );
        } else {
          context.canvas.drawRect(badgeRect, paint);
        }

        context.paintChild(labelChild, labelData.offset + offset);
      }
    } else if (hasLabel) {
      final RenderBox labelChild = firstChild!;
      // Paint background for standalone badge
      final Rect badgeRect = offset & size;
      final Paint paint = Paint()
        ..color = decoration.color ?? const Color(0xFFFF0000);

      if (decoration.borderRadius != null) {
        context.canvas.drawRRect(
          decoration.borderRadius!
              .resolve(TextDirection.ltr)
              .toRRect(badgeRect),
          paint,
        );
      } else {
        context.canvas.drawRect(badgeRect, paint);
      }

      context.paintChild(labelChild, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
