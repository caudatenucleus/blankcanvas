import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Scrollbar.
class ScrollbarStatus extends ScrollbarControlStatus {}

/// A custom scrollbar that adheres to the BlankCanvas theme.
/// This is a SingleChildRenderObjectWidget wrapper.
class Scrollbar extends SingleChildRenderObjectWidget {
  const Scrollbar({super.key, required Widget child, this.controller, this.tag})
    : super(child: child);

  final ScrollController? controller;
  final String? tag;

  @override
  RenderScrollbar createRenderObject(BuildContext context) {
    return RenderScrollbar(tag: tag, context: context);
  }

  @override
  void updateRenderObject(BuildContext context, RenderScrollbar renderObject) {
    renderObject
      ..tag = tag
      ..themeContext = context;
  }
}

class RenderScrollbar extends RenderProxyBox implements TickerProvider {
  RenderScrollbar({String? tag, required BuildContext context})
    : _tag = tag,
      _context = context {
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverController.addListener(markNeedsPaint);
  }

  String? _tag;
  set tag(String? value) {
    if (_tag == value) return;
    _tag = value;
    markNeedsPaint();
  }

  BuildContext _context;
  set themeContext(BuildContext value) {
    _context = value;
  }

  ScrollMetrics? _lastMetrics;
  late final AnimationController _hoverController;
  final ScrollbarStatus _status = ScrollbarStatus();

  void updateMetrics(ScrollMetrics metrics) {
    _lastMetrics = metrics;
    markNeedsPaint();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'ScrollbarTicker');
  }

  @override
  void detach() {
    _hoverController.dispose();
    super.detach();
  }

  bool _isHovered = false;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      super.hitTest(result, position: position);
      return true;
    }
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) {
    final Rect? thumbRect = _computeThumbRect(Offset.zero);
    return thumbRect?.contains(position) ?? false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent) {
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

  Rect? _computeThumbRect(Offset offset) {
    if (_lastMetrics == null || size.isEmpty) return null;
    final metrics = _lastMetrics!;

    if (metrics.axis != Axis.vertical) return null;

    final double viewport = metrics.viewportDimension;
    final double contentSize = metrics.maxScrollExtent + viewport;
    if (contentSize <= viewport) return null;

    final double trackSize = size.height;
    final double thumbSize = (viewport / contentSize * trackSize).clamp(
      20.0,
      trackSize,
    );
    final double maxScroll = metrics.maxScrollExtent;
    final double scrollFraction = maxScroll > 0
        ? (metrics.pixels / maxScroll).clamp(0.0, 1.0)
        : 0.0;
    final double thumbOffset = scrollFraction * (trackSize - thumbSize);

    final customizations = CustomizedTheme.of(_context);
    final customization = customizations.getScrollbar(_tag);
    final double thickness = customization?.thickness ?? 8.0;

    return Rect.fromLTWH(
      offset.dx + size.width - thickness,
      offset.dy + thumbOffset,
      thickness,
      thumbSize,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);

    if (_lastMetrics == null) return;

    _status.hovered = _hoverController.value;

    final rect = _computeThumbRect(offset);
    if (rect == null) return;

    final customizations = CustomizedTheme.of(_context);
    final customization = customizations.getScrollbar(_tag);
    final decoration =
        customization?.decoration(_status) ??
        const BoxDecoration(
          color: Color(0xFF888888),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        );

    final BoxPainter painter = decoration.createBoxPainter();
    painter.paint(
      context.canvas,
      rect.topLeft,
      ImageConfiguration(size: rect.size),
    );
    painter.dispose();
  }
}
