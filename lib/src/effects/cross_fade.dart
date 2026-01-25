import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A lowest-level cross-fade transition between two children.
class CrossFade extends MultiChildRenderObjectWidget {
  CrossFade({
    super.key,
    required this.progress,
    required Widget firstChild,
    required Widget secondChild,
    this.alignment = Alignment.center,
  }) : super(children: [firstChild, secondChild]);

  final Animation<double> progress;
  final AlignmentGeometry alignment;

  @override
  RenderCrossFade createRenderObject(BuildContext context) {
    return RenderCrossFade(progress: progress, alignment: alignment);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCrossFade renderObject) {
    renderObject
      ..progress = progress
      ..alignment = alignment;
  }
}

class CrossFadeParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCrossFade extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CrossFadeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CrossFadeParentData> {
  RenderCrossFade({
    required Animation<double> progress,
    AlignmentGeometry alignment = Alignment.center,
  }) : _progress = progress,
       _alignment = alignment;

  Animation<double> _progress;
  set progress(Animation<double> value) {
    if (_progress == value) return;
    if (attached) _progress.removeListener(markNeedsPaint);
    _progress = value;
    if (attached) _progress.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! CrossFadeParentData) {
      child.parentData = CrossFadeParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _progress.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _progress.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final CrossFadeParentData pd = child.parentData! as CrossFadeParentData;
      pd.offset = _alignment
          .resolve(TextDirection.ltr)
          .alongOffset(size - child.size as Offset);
      child = pd.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double t = _progress.value.clamp(0.0, 1.0);

    RenderBox? first = firstChild;
    RenderBox? second = lastChild;

    // First child (fade out)
    if (first != null && t < 1.0) {
      final double alpha = 1.0 - t;
      context.pushOpacity(
        offset + (first.parentData! as CrossFadeParentData).offset,
        (255 * alpha).round(),
        (context, offset) {
          context.paintChild(first, offset);
        },
      );
    }

    // Second child (fade in)
    if (second != null && t > 0.0 && first != second) {
      final double alpha = t;
      context.pushOpacity(
        offset + (second.parentData! as CrossFadeParentData).offset,
        (255 * alpha).round(),
        (context, offset) {
          context.paintChild(second, offset);
        },
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Both children can be interactive if visible?
    // Standard CrossFade hitTests both?
    return defaultHitTestChildren(result, position: position);
  }
}
