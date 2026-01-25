import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that creates a parallax scrolling effect using lowest-level APIs.
class Parallax extends SingleChildRenderObjectWidget {
  const Parallax({
    super.key,
    required this.background,
    required Widget child,
    this.parallaxFactor = 0.5,
  }) : super(child: child);

  final Widget background;
  final double parallaxFactor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParallax(
      parallaxFactor: parallaxFactor,
      scrollable: Scrollable.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderParallax renderObject) {
    renderObject
      ..parallaxFactor = parallaxFactor
      ..scrollable = Scrollable.maybeOf(context);
  }
}

class RenderParallax extends RenderProxyBox {
  RenderParallax({required double parallaxFactor, ScrollableState? scrollable})
    : _parallaxFactor = parallaxFactor,
      _scrollable = scrollable;

  double _parallaxFactor;
  double get parallaxFactor => _parallaxFactor;
  set parallaxFactor(double value) {
    if (_parallaxFactor == value) return;
    _parallaxFactor = value;
    markNeedsPaint();
  }

  ScrollableState? _scrollable;
  ScrollableState? get scrollable => _scrollable;
  set scrollable(ScrollableState? value) {
    if (_scrollable == value) return;
    if (attached) _removeListener();
    _scrollable = value;
    if (attached) _addListener();
    markNeedsPaint();
  }

  void _addListener() {
    _scrollable?.position.addListener(markNeedsPaint);
  }

  void _removeListener() {
    try {
      _scrollable?.position.removeListener(markNeedsPaint);
    } catch (e) {
      // Ignore if position is already disposed
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _addListener();
  }

  @override
  void detach() {
    _removeListener();
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    double scrollOffset = 0.0;

    if (_scrollable != null && _scrollable!.position.hasPixels) {
      scrollOffset = _scrollable!.position.pixels * _parallaxFactor;
    }

    if (child != null) {
      context.paintChild(child!, offset + Offset(0, -scrollOffset));
    }
  }
}
