import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A widget that renders its overlay content into the closest Overlay ancestor.
class Portal extends SingleChildRenderObjectWidget {
  const Portal({
    super.key,
    required Widget child,
    this.anchor = Alignment.bottomLeft,
    this.overlayAnchor = Alignment.topLeft,
    this.offset = Offset.zero,
    this.tag,
  }) : super(child: child);

  final Alignment anchor;
  final Alignment overlayAnchor;
  final Offset offset;
  final String? tag;

  @override
  RenderPortal createRenderObject(BuildContext context) {
    return RenderPortal(
      anchor: anchor,
      overlayAnchor: overlayAnchor,
      portalOffset: offset,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPortal renderObject) {
    renderObject
      ..anchor = anchor
      ..overlayAnchor = overlayAnchor
      ..portalOffset = offset;
  }
}

class RenderPortal extends RenderProxyBox {
  RenderPortal({
    required Alignment anchor,
    required Alignment overlayAnchor,
    required Offset portalOffset,
  }) : _anchor = anchor,
       _overlayAnchor = overlayAnchor,
       _portalOffset = portalOffset;

  Alignment _anchor;
  set anchor(Alignment value) {
    if (_anchor != value) {
      _anchor = value;
      markNeedsPaint();
    }
  }

  Alignment _overlayAnchor;
  set overlayAnchor(Alignment value) {
    if (_overlayAnchor != value) {
      _overlayAnchor = value;
      markNeedsPaint();
    }
  }

  Offset _portalOffset;
  set portalOffset(Offset value) {
    if (_portalOffset != value) {
      _portalOffset = value;
      markNeedsPaint();
    }
  }
}
