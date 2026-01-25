import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Menu Item.
class MenuItemStatus extends MenuItemControlStatus {}

/// A Menu Item.
class MenuItem extends MultiChildRenderObjectWidget {
  MenuItem({
    super.key,
    required Widget label,
    required this.onTap,
    Widget? leading,
    Widget? trailing,
    this.tag,
  }) : super(
         children: [
           if (leading != null) leading,
           label,
           if (trailing != null) trailing,
         ],
       );

  final VoidCallback onTap;
  final String? tag;

  @override
  RenderMenuItem createRenderObject(BuildContext context) {
    return RenderMenuItem(
      onTap: onTap,
      tag: tag,
      context: context,
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMenuItem renderObject) {
    renderObject
      ..onTap = onTap
      ..tag = tag
      ..context = context
      ..textDirection = Directionality.of(context);
  }
}

class RenderMenuItem extends RenderFlex implements TickerProvider {
  RenderMenuItem({
    required VoidCallback onTap,
    String? tag,
    required BuildContext context,
    super.direction,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.textDirection,
  }) : _onTap = onTap,
       _tag = tag,
       _context = context {
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _hoverController.addListener(markNeedsPaint);

    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  VoidCallback _onTap;
  set onTap(VoidCallback value) {
    _onTap = value;
  }

  String? _tag;
  set tag(String? value) {
    if (_tag == value) return;
    _tag = value;
    markNeedsPaint();
  }

  BuildContext _context;
  set context(BuildContext value) {
    _context = value;
  }

  late final AnimationController _hoverController;
  late final TapGestureRecognizer _tap;
  final MenuItemStatus _status = MenuItemStatus();

  void _handleTap() {
    _onTap();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'MenuItemTicker');
  }

  @override
  void detach() {
    _hoverController.dispose();
    _tap.dispose();
    super.detach();
  }

  @override
  bool hitTestSelf(Offset position) => size.contains(position);

  bool _isHovered = false;
  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      if (!_isHovered) {
        _isHovered = true;
        _hoverController.forward();
      }
    } else if (event is PointerExitEvent) {
      if (_isHovered) {
        _isHovered = false;
        _hoverController.reverse();
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _status.hovered = _hoverController.value;

    final customizations = CustomizedTheme.of(_context);
    final customization = customizations.getMenuItem(_tag);
    final decoration =
        customization?.decoration(_status) ?? const BoxDecoration();

    final BoxPainter painter = decoration.createBoxPainter();
    painter.paint(context.canvas, offset, ImageConfiguration(size: size));
    painter.dispose();

    super.paint(context, offset);
  }
}

/// A Menu widget.
class Menu extends MultiChildRenderObjectWidget {
  const Menu({super.key, required super.children, this.tag});

  final String? tag;

  @override
  RenderMenuBox createRenderObject(BuildContext context) {
    return RenderMenuBox(
      tag: tag,
      context: context,
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMenuBox renderObject) {
    renderObject
      ..tag = tag
      ..context = context
      ..textDirection = Directionality.of(context);
  }
}

class RenderMenuBox extends RenderFlex {
  RenderMenuBox({
    String? tag,
    required BuildContext context,
    super.direction,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.textDirection,
  }) : _tag = tag,
       _context = context;

  String? _tag;
  set tag(String? value) {
    if (_tag != value) {
      _tag = value;
      markNeedsPaint();
    }
  }

  BuildContext _context;
  set context(BuildContext value) {
    _context = value;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final customizations = CustomizedTheme.of(_context);
    final customization = customizations.getMenu(_tag);
    final decoration =
        customization?.decoration(MenuControlStatus()) ??
        const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [BoxShadow(blurRadius: 4, color: Color(0x20000000))],
        );

    final BoxPainter painter = decoration.createBoxPainter();
    painter.paint(context.canvas, offset, ImageConfiguration(size: size));
    painter.dispose();

    super.paint(context, offset);
  }
}
