import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A widget that defers building its child until it becomes visible in the viewport.
class LazyLoad extends SingleChildRenderObjectWidget {
  const LazyLoad({
    super.key,
    required Widget child,
    this.offset = 0.0,
    this.tag,
  }) : super(child: child);

  final double offset;
  final String? tag;

  @override
  RenderLazyLoad createRenderObject(BuildContext context) {
    return RenderLazyLoad(lazyOffset: offset);
  }

  @override
  void updateRenderObject(BuildContext context, RenderLazyLoad renderObject) {
    renderObject.lazyOffset = offset;
  }
}

class RenderLazyLoad extends RenderProxyBox {
  RenderLazyLoad({required double lazyOffset}) : _lazyOffset = lazyOffset;

  double _lazyOffset;
  set lazyOffset(double value) {
    if (_lazyOffset != value) {
      _lazyOffset = value;
    }
  }

  bool _isVisible = false;

  @override
  void paint(PaintingContext context, Offset offset) {
    // Check visibility in viewport
    final viewport = RenderAbstractViewport.maybeOf(this);
    if (viewport != null) {
      final revealedOffset = viewport.getOffsetToReveal(this, 0.0);
      final viewportDimension = (viewport as RenderBox).size.height;
      _isVisible = revealedOffset.offset < viewportDimension + _lazyOffset;
    } else {
      _isVisible = true; // Not in scrollable, always visible
    }

    if (_isVisible) {
      super.paint(context, offset);
    } else {
      // Paint placeholder
      context.canvas.drawRect(
        offset & size,
        Paint()..color = const Color(0xFFF5F5F5),
      );
    }
  }
}
