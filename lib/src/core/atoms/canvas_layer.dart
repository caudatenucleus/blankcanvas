import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

abstract class LayerDelegate {
  const LayerDelegate();

  void pushLayer(
    PaintingContext context,
    Offset offset,
    PaintingContextCallback childPainter,
  );
}

class TransformDelegate extends LayerDelegate {
  const TransformDelegate(this.transform);
  final Matrix4 transform;

  @override
  void pushLayer(
    PaintingContext context,
    Offset offset,
    PaintingContextCallback childPainter,
  ) {
    context.pushTransform(
      true, // needsCompositing
      offset,
      transform,
      childPainter,
    );
  }
}

class OpacityDelegate extends LayerDelegate {
  const OpacityDelegate(this.alpha);
  final int alpha;

  @override
  void pushLayer(
    PaintingContext context,
    Offset offset,
    PaintingContextCallback childPainter,
  ) {
    context.pushOpacity(offset, alpha, childPainter);
  }
}

class CanvasLayer extends SingleChildRenderObjectWidget {
  const CanvasLayer({super.key, required this.delegate, super.child});

  final LayerDelegate delegate;

  @override
  RenderCanvasLayer createRenderObject(BuildContext context) {
    return RenderCanvasLayer(delegate: delegate);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCanvasLayer renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}

class RenderCanvasLayer extends RenderProxyBox {
  RenderCanvasLayer({required LayerDelegate delegate, RenderBox? child})
    : _delegate = delegate,
      super(child);

  LayerDelegate _delegate;
  set delegate(LayerDelegate value) {
    if (_delegate != value) {
      _delegate = value;
      markNeedsPaint();
    }
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      _delegate.pushLayer(context, offset, (context, offset) {
        context.paintChild(child!, offset);
      });
    }
  }
}
