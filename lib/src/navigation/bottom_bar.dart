import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Bottom Bar Item.
class BottomBarItemStatus extends BottomBarItemControlStatus {}

/// A Bottom Bar Item.
class BottomBarItem extends MultiChildRenderObjectWidget {
  BottomBarItem({
    super.key,
    required Widget icon,
    required Widget label,
    required this.selected,
    required this.onTap,
    this.tag,
  }) : super(children: [icon, label]);

  final bool selected;
  final VoidCallback onTap;
  final String? tag;

  @override
  RenderBottomBarItem createRenderObject(BuildContext context) {
    return RenderBottomBarItem(
      selected: selected,
      onTap: onTap,
      tag: tag,
      context: context,
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBottomBarItem renderObject,
  ) {
    renderObject
      ..selected = selected
      ..onTap = onTap
      ..tag = tag
      ..context = context
      ..textDirection = Directionality.of(context);
  }
}

class RenderBottomBarItem extends RenderFlex implements TickerProvider {
  RenderBottomBarItem({
    required bool selected,
    required VoidCallback onTap,
    String? tag,
    required BuildContext context,
    super.direction,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.textDirection,
  }) : _selected = selected,
       _onTap = onTap,
       _tag = tag,
       _context = context {
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _hoverController.addListener(markNeedsPaint);

    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  bool _selected;
  set selected(bool value) {
    if (_selected != value) {
      _selected = value;
      markNeedsPaint();
    }
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
  final BottomBarItemStatus _status = BottomBarItemStatus();

  void _handleTap() {
    _onTap();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'BottomBarItemTicker');
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
    _status.selected = _selected ? 1.0 : 0.0;

    final customizations = CustomizedTheme.of(_context);
    final customization = customizations.getBottomBarItem(_tag);
    final decoration =
        customization?.decoration(_status) ?? const BoxDecoration();

    final BoxPainter painter = decoration.createBoxPainter();
    painter.paint(context.canvas, offset, ImageConfiguration(size: size));
    painter.dispose();

    super.paint(context, offset);
  }
}

/// A Bottom Bar.
class BottomBar extends MultiChildRenderObjectWidget {
  const BottomBar({super.key, required super.children, this.tag});

  final String? tag;

  @override
  RenderBottomBarBox createRenderObject(BuildContext context) {
    return RenderBottomBarBox(
      tag: tag,
      context: context,
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBottomBarBox renderObject,
  ) {
    renderObject
      ..tag = tag
      ..context = context
      ..textDirection = Directionality.of(context);
  }
}

class RenderBottomBarBox extends RenderFlex {
  RenderBottomBarBox({
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
    final customization = customizations.getBottomBar(_tag);
    final decoration =
        customization?.decoration(BottomBarControlStatus()) ??
        const BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, -2),
              color: Color(0x1F000000),
            ),
          ],
        );

    final BoxPainter painter = decoration.createBoxPainter();
    painter.paint(context.canvas, offset, ImageConfiguration(size: size));
    painter.dispose();

    super.paint(context, offset);
  }
}
