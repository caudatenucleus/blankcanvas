import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A large menu widget suitable for navigation headers.
/// Uses an overlay approach with low-level RenderObject and Element linkage.
class MegaMenu extends SingleChildRenderObjectWidget {
  const MegaMenu({
    super.key,
    required this.trigger,
    required this.content,
    this.width,
    this.tag,
  }) : super(child: trigger);

  final Widget trigger;
  final Widget content;
  final double? width;
  final String? tag;

  @override
  MegaMenuElement createElement() => MegaMenuElement(this);

  @override
  RenderMegaMenu createRenderObject(BuildContext context) {
    return RenderMegaMenu();
  }

  @override
  void updateRenderObject(BuildContext context, RenderMegaMenu renderObject) {
    // No properties to update on renderObject specifically yet
  }
}

class MegaMenuElement extends SingleChildRenderObjectElement {
  MegaMenuElement(MegaMenu super.widget);

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (renderObject as RenderMegaMenu).onToggle = _toggle;
    (renderObject as RenderMegaMenu).layerLink = _layerLink;
  }

  @override
  void unmount() {
    _removeOverlay();
    super.unmount();
  }

  void _toggle() {
    if (_overlayEntry != null) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = renderObject as RenderBox;
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: (widget as MegaMenu).width ?? size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height), // Below trigger
            child: (widget as MegaMenu).content,
          ),
        );
      },
    );

    Overlay.of(this).insert(_overlayEntry!);
    (renderObject as RenderMegaMenu).isOpen = true;
  }

  void _close() {
    _removeOverlay();
    (renderObject as RenderMegaMenu).isOpen = false;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class RenderMegaMenu extends RenderProxyBox {
  RenderMegaMenu({LayerLink? layerLink}) : _layerLink = layerLink {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  VoidCallback? onToggle;
  LayerLink? _layerLink;
  set layerLink(LayerLink? value) {
    _layerLink = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  bool _isOpen = false;
  set isOpen(bool value) {
    if (_isOpen != value) {
      _isOpen = value;
      markNeedsPaint();
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  void _handleTap() {
    onToggle?.call();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_layerLink != null) {
      context.pushLayer(LeaderLayer(link: _layerLink!, offset: offset), (
        context,
        offset,
      ) {
        super.paint(context, offset);
      }, Offset.zero);
    } else {
      super.paint(context, offset);
    }

    // Paint indication
    if (_isOpen) {
      final paint = Paint()..color = const Color(0xFF2196F3);
      context.canvas.drawRect(
        Rect.fromLTWH(offset.dx, offset.dy + size.height - 2, size.width, 2),
        paint,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }
}
