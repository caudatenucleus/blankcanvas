import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Dialog.
class DialogStatus extends CardControlStatus {}

/// A Dialog container.
class Dialog extends SingleChildRenderObjectWidget {
  const Dialog({super.key, required Widget child, this.tag})
    : super(child: child);

  final String? tag;

  @override
  RenderDialogBox createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDialog(tag);
    final decoration =
        customization?.decoration(DialogStatus()) ??
        const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [BoxShadow(blurRadius: 10, color: Color(0x40000000))],
        );

    return RenderDialogBox(decoration: decoration);
  }

  @override
  void updateRenderObject(BuildContext context, RenderDialogBox renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDialog(tag);
    final decoration =
        customization?.decoration(DialogStatus()) ??
        const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [BoxShadow(blurRadius: 10, color: Color(0x40000000))],
        );

    renderObject.decoration = decoration;
  }
}

class RenderDialogBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderDialogBox({required Decoration decoration}) : _decoration = decoration;

  Decoration _decoration;
  Decoration get decoration => _decoration;
  set decoration(Decoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  // Hardcoded padding from previous implementation
  final EdgeInsets _padding = const EdgeInsets.all(24.0);

  @override
  void performLayout() {
    if (child != null) {
      final BoxConstraints innerConstraints = constraints.deflate(_padding);
      child!.layout(innerConstraints, parentUsesSize: true);

      final double width = child!.size.width + _padding.horizontal;
      final double height = child!.size.height + _padding.vertical;
      size = constraints.constrain(Size(width, height));

      final BoxParentData childParentData = child!.parentData as BoxParentData;
      // Center child in the available space (accounting for partial constraints if any)
      childParentData.offset = Offset(
        _padding.left +
            (size.width - _padding.horizontal - child!.size.width) / 2,
        _padding.top +
            (size.height - _padding.vertical - child!.size.height) / 2,
      );
    } else {
      size = constraints.constrain(_padding.collapsedSize);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint Decoration
    final BoxPainter painter = _decoration.createBoxPainter();
    painter.paint(context.canvas, offset, ImageConfiguration(size: size));
    painter.dispose();

    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      context.paintChild(child!, offset + childParentData.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      return result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
    }
    return false;
  }
}
