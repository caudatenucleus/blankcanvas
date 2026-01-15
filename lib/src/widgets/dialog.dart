import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Dialog.
class DialogStatus extends CardControlStatus {}

/// A Dialog container.
class Dialog extends StatefulWidget {
  const Dialog({super.key, required this.child, this.tag});

  final Widget child;
  final String? tag;

  @override
  State<Dialog> createState() => _DialogState();
}

class _DialogState extends State<Dialog> {
  final DialogStatus _status = DialogStatus();

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDialog(widget.tag);

    if (customization == null) {
      return _DialogRenderWidget(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [BoxShadow(blurRadius: 10, color: Color(0x40000000))],
        ),
        child: Padding(padding: const EdgeInsets.all(24), child: widget.child),
      );
    }

    final decoration = customization.decoration(_status);
    final textStyle = customization.textStyle(_status);

    return _DialogRenderWidget(
      decoration: decoration is BoxDecoration
          ? decoration
          : const BoxDecoration(),
      child: DefaultTextStyle(style: textStyle, child: widget.child),
    );
  }
}

class _DialogRenderWidget extends SingleChildRenderObjectWidget {
  const _DialogRenderWidget({super.child, required this.decoration});

  final BoxDecoration decoration;

  @override
  RenderDialogBox createRenderObject(BuildContext context) {
    return RenderDialogBox(decoration: decoration);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderDialogBox renderObject,
  ) {
    renderObject.decoration = decoration;
  }
}

class RenderDialogBox extends RenderProxyBox {
  RenderDialogBox({required BoxDecoration decoration})
    : _decoration = decoration;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    if (child != null) {
      // Dialogs usually constrain themselves or are constrained by parent (overlay)
      child!.layout(constraints.loosen(), parentUsesSize: true);
      // We center the child within our size
      size = constraints.biggest;
    } else {
      size = constraints.smallest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final Size childSize = child!.size;
    final Offset childOffset = Offset(
      (size.width - childSize.width) / 2,
      (size.height - childSize.height) / 2,
    );

    final Rect rect = (offset + childOffset) & childSize;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFFFFFFF);

    // Paint shadow
    if (decoration.boxShadow != null) {
      for (final shadow in decoration.boxShadow!) {
        context.canvas.drawRect(
          rect.shift(shadow.offset).inflate(shadow.spreadRadius),
          shadow.toPaint(),
        );
      }
    }

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

    context.paintChild(child!, offset + childOffset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    final Size childSize = child!.size;
    final Offset childOffset = Offset(
      (size.width - childSize.width) / 2,
      (size.height - childSize.height) / 2,
    );
    return result.addWithPaintOffset(
      offset: childOffset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childOffset);
        return child!.hitTest(result, position: transformed);
      },
    );
  }
}
