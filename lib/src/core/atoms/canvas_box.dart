import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'canvas_status.dart';
import '../../decorations/canvas_decoration.dart';

class CanvasBox extends SingleChildRenderObjectWidget {
  const CanvasBox({
    super.key,
    required this.decoration,
    super.child,
    this.width,
    this.height,
  });

  final CanvasDecoration decoration;
  final double? width;
  final double? height;

  @override
  RenderCanvasBox createRenderObject(BuildContext context) {
    return RenderCanvasBox(
      decoration: decoration,
      width: width,
      height: height,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCanvasBox renderObject) {
    renderObject
      ..decoration = decoration
      ..width = width
      ..height = height;
  }
}

class RenderCanvasBox extends RenderShiftedBox
    implements StatusAwareRenderObject {
  RenderCanvasBox({
    required CanvasDecoration decoration,
    double? width,
    double? height,
  }) : _decoration = decoration,
       _width = width,
       _height = height,
       super(null);

  CanvasDecoration _decoration;
  set decoration(CanvasDecoration value) {
    if (_decoration != value) {
      _decoration = value;
      markNeedsLayout(); // Padding might change
      markNeedsPaint();
    }
  }

  double? _width;
  set width(double? value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  double? _height;
  set height(double? value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  ControlStatus _status = const ControlStatus();
  @override
  set controlStatus(ControlStatus status) {
    if (_status != status) {
      _status = status;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final double? width = _width;
    final double? height = _height;

    // Determine bounds
    double? constrainedWidth = width;
    double? constrainedHeight = height;

    // Respect parental constraints
    if (constrainedWidth != null) {
      constrainedWidth = constraints.constrainWidth(constrainedWidth);
    }
    if (constrainedHeight != null) {
      constrainedHeight = constraints.constrainHeight(constrainedHeight);
    }

    // Inner constraints for child (deflated by padding)
    final padding = _decoration.padding;
    final innerConstraints = constraints.deflate(padding);

    if (child != null) {
      child!.layout(innerConstraints, parentUsesSize: true);
      final childSize = child!.size;

      size = constraints.constrain(
        Size(
          constrainedWidth ?? childSize.width + padding.horizontal,
          constrainedHeight ?? childSize.height + padding.vertical,
        ),
      );

      final BoxParentData childParentData = child!.parentData as BoxParentData;
      childParentData.offset = Offset(padding.left, padding.top);
    } else {
      size = constraints.constrain(
        Size(
          constrainedWidth ?? padding.horizontal,
          constrainedHeight ?? padding.vertical,
        ),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _decoration.paint(context.canvas, size, _status);

    if (child != null) {
      context.paintChild(
        child!,
        offset + (child!.parentData as BoxParentData).offset,
      );
    }
  }
}
