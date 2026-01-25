import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A declarative overlay widget.
class OverlayBuilder extends SingleChildRenderObjectWidget {
  const OverlayBuilder({
    super.key,
    required Widget child,
    this.visible = false,
    this.tag,
  }) : super(child: child);

  final bool visible;
  final String? tag;

  @override
  RenderOverlayBuilder createRenderObject(BuildContext context) {
    return RenderOverlayBuilder(visible: visible);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverlayBuilder renderObject,
  ) {
    renderObject.visible = visible;
  }
}

class RenderOverlayBuilder extends RenderProxyBox {
  RenderOverlayBuilder({required bool visible}) : _visible = visible;

  bool _visible;
  set visible(bool value) {
    if (_visible != value) {
      _visible = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    if (_visible) {
      // Visual indicator that overlay is active
      context.canvas.drawRect(
        offset & size,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x442196F3)
          ..strokeWidth = 2,
      );
    }
  }
}
