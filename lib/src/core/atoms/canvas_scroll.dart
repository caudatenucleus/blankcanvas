import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CanvasScroll extends SingleChildRenderObjectWidget {
  const CanvasScroll({
    super.key,
    required this.offset,
    this.clipBehavior = Clip.hardEdge,
    super.child,
  });

  final ViewportOffset offset;
  final Clip clipBehavior;

  @override
  RenderCanvasScroll createRenderObject(BuildContext context) {
    return RenderCanvasScroll(offset: offset, clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCanvasScroll renderObject,
  ) {
    renderObject
      ..offset = offset
      ..clipBehavior = clipBehavior;
  }
}

class RenderCanvasScroll extends RenderProxyBox {
  RenderCanvasScroll({
    required ViewportOffset offset,
    Clip clipBehavior = Clip.hardEdge,
    RenderBox? child,
  }) : _offset = offset,
       _clipBehavior = clipBehavior,
       super(child);

  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    if (_offset == value) return;
    if (attached) _offset.removeListener(markNeedsPaint);
    _offset = value;
    if (attached) _offset.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  Clip _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior != value) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _offset.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      // Apply clip
      if (_clipBehavior != Clip.none) {
        context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
          context,
          offset,
        ) {
          // Apply offset
          // We assume vertical scrolling or handle generic offset?
          // ViewportOffset is usually 1D (pixels).
          // But "Infinite Canvases" implies 2D.
          // Standard ViewportOffset is 1D.
          // If we want 2D, we need Offset object.
          // But implementing standardized scrolling usually involves Slivers.
          // Here we assume simple translation.
          // If offset.pixels is Y, we translate Y.
          // For now, assume Y.
          // In a real "Universal Atom", we might want 2D offset.
          // But keeping it compatible with ViewportOffset allows re-use of ScrollPosition.
          context.paintChild(child!, offset - Offset(0, _offset.pixels));
        }, clipBehavior: _clipBehavior);
      } else {
        context.paintChild(child!, offset - Offset(0, _offset.pixels));
      }
    }
  }
}
