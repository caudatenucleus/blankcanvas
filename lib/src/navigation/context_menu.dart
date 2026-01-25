import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A context menu that appears on right-click or long-press.
class ContextMenu extends SingleChildRenderObjectWidget {
  const ContextMenu({
    super.key,
    required Widget child,
    required this.items,
    this.tag,
  }) : super(child: child);

  final List<ContextMenuItem> items;
  final String? tag;

  @override
  ContextMenuElement createElement() => ContextMenuElement(this);

  @override
  RenderContextMenuTrigger createRenderObject(BuildContext context) {
    return RenderContextMenuTrigger();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderContextMenuTrigger renderObject,
  ) {
    // No properties to update on trigger
  }
}

class ContextMenuItem {
  const ContextMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDanger = false,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isDanger;
  final bool isDisabled;
}

class ContextMenuElement extends SingleChildRenderObjectElement {
  ContextMenuElement(ContextMenu super.widget);

  OverlayEntry? _overlayEntry;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (renderObject as RenderContextMenuTrigger).onShowMenu = _showMenu;
  }

  @override
  void unmount() {
    _removeOverlay();
    super.unmount();
  }

  void _showMenu(Offset globalPosition) {
    _removeOverlay(); // Ensure only one exists

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return ContextOverlay(
          onDismiss: _closeMenu,
          position: globalPosition,
          child: ContextMenuContent(
            items: (widget as ContextMenu).items,
            onDismiss: _closeMenu,
          ),
        );
      },
    );

    Overlay.of(this).insert(_overlayEntry!);
  }

  void _closeMenu() {
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class RenderContextMenuTrigger extends RenderProxyBox {
  RenderContextMenuTrigger() {
    _longPress = LongPressGestureRecognizer()
      ..onLongPressStart = _handleLongPressStart;
    _secondaryTap = TapGestureRecognizer()
      ..onSecondaryTapDown = _handleSecondaryTapDown;
  }

  ValueChanged<Offset>? onShowMenu;

  late LongPressGestureRecognizer _longPress;
  late TapGestureRecognizer _secondaryTap;

  @override
  void detach() {
    _longPress.dispose();
    _secondaryTap.dispose();
    super.detach();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    onShowMenu?.call(details.globalPosition);
  }

  void _handleSecondaryTapDown(TapDownDetails details) {
    onShowMenu?.call(details.globalPosition);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _longPress.addPointer(event);
      _secondaryTap.addPointer(event);
    }
  }
}

class ContextOverlay extends SingleChildRenderObjectWidget {
  const ContextOverlay({
    super.key,
    required this.onDismiss,
    required this.position,
    required Widget child,
  }) : super(child: child);

  final VoidCallback onDismiss;
  final Offset position;

  @override
  RenderContextOverlay createRenderObject(BuildContext context) {
    return RenderContextOverlay(onDismiss: onDismiss, position: position);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderContextOverlay renderObject,
  ) {
    renderObject
      ..onDismiss = onDismiss
      ..position = position;
  }
}

class RenderContextOverlay extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderContextOverlay({
    required VoidCallback onDismiss,
    required Offset position,
  }) : _onDismiss = onDismiss,
       _position = position {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  VoidCallback _onDismiss;
  set onDismiss(VoidCallback val) => _onDismiss = val;

  Offset _position;
  set position(Offset val) {
    if (_position != val) {
      _position = val;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;

  @override
  void performLayout() {
    size = constraints.biggest;

    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      // Position child at _position, clamped to screen
      final pd = child!.parentData as BoxParentData;

      double dx = _position.dx;
      double dy = _position.dy;

      // Clamp
      if (dx + child!.size.width > size.width) {
        dx = size.width - child!.size.width;
      }
      if (dy + child!.size.height > size.height) {
        dy = size.height - child!.size.height;
      }

      pd.offset = Offset(dx, dy);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Draw barrier? Transparent.
    if (child != null) {
      final pd = child!.parentData as BoxParentData;
      context.paintChild(child!, offset + pd.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      final pd = child!.parentData as BoxParentData;
      final bool hit = result.addWithPaintOffset(
        offset: pd.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (hit) return true;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) => true; // Barrier

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  void _handleTap() {
    _onDismiss();
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }
}

@visibleForTesting
class ContextMenuContent extends LeafRenderObjectWidget {
  const ContextMenuContent({
    super.key,
    required this.items,
    required this.onDismiss,
  });

  final List<ContextMenuItem> items;
  final VoidCallback onDismiss;

  @override
  RenderContextMenuContent createRenderObject(BuildContext context) {
    return RenderContextMenuContent(items: items, onDismiss: onDismiss);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderContextMenuContent renderObject,
  ) {
    renderObject
      ..items = items
      ..onDismiss = onDismiss;
  }
}

class RenderContextMenuContent extends RenderBox {
  RenderContextMenuContent({
    required List<ContextMenuItem> items,
    required VoidCallback onDismiss,
  }) : _items = items,
       _onDismiss = onDismiss {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<ContextMenuItem> _items;
  set items(List<ContextMenuItem> value) {
    if (_items != value) {
      _items = value;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  VoidCallback _onDismiss;
  set onDismiss(VoidCallback value) {
    _onDismiss = value;
  }

  late TapGestureRecognizer _tap;
  int? _hoveredItemIndex;

  static const double _itemHeight = 36.0;
  static const double _menuWidth = 180.0;
  static const double _menuPadding = 4.0;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final height = _items.length * _itemHeight + _menuPadding * 2;
    size = constraints.constrain(Size(_menuWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final menuRect = offset & size;

    // Shadow
    final shadowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(menuRect, const Radius.circular(4)));
    canvas.drawShadow(shadowPath, const Color(0xFF000000), 8, false);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(menuRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // Items
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final itemRect = Rect.fromLTWH(
        offset.dx + _menuPadding,
        offset.dy + _menuPadding + i * _itemHeight,
        _menuWidth - _menuPadding * 2,
        _itemHeight,
      );
      final isHovered = i == _hoveredItemIndex;

      // Hover bg
      if (isHovered && !item.isDisabled) {
        canvas.drawRect(itemRect, Paint()..color = const Color(0xFFF5F5F5));
      }

      // Text
      Color textColor = item.isDisabled
          ? const Color(0xFFBDBDBD)
          : item.isDanger
          ? const Color(0xFFFF5252)
          : const Color(0xFF333333);

      textPainter.text = TextSpan(
        text: item.label,
        style: TextStyle(fontSize: 14, color: textColor),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(itemRect.left + 12, itemRect.center.dy - textPainter.height / 2),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _items.length; i++) {
      final itemRect = Rect.fromLTWH(
        _menuPadding,
        _menuPadding + i * _itemHeight,
        _menuWidth - _menuPadding * 2,
        _itemHeight,
      );
      if (itemRect.contains(local)) {
        final item = _items[i];
        if (!item.isDisabled) {
          item.onTap();
          _onDismiss(); // Close menu after selection
        }
        return;
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      // Find hovered item
      int? hovered;
      for (int i = 0; i < _items.length; i++) {
        final itemRect = Rect.fromLTWH(
          _menuPadding,
          _menuPadding + i * _itemHeight,
          _menuWidth - _menuPadding * 2,
          _itemHeight,
        );
        if (itemRect.contains(event.localPosition)) {
          hovered = i;
          break;
        }
      }
      if (_hoveredItemIndex != hovered) {
        _hoveredItemIndex = hovered;
        markNeedsPaint();
      }
    }
  }
}
