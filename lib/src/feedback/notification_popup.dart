import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Duration presets for notifications.
enum NotificationDuration { short, medium, long }

/// Shows a temporary notification popup (toast/snackbar equivalent).
class NotificationPopup {
  NotificationPopup._();

  static OverlayEntry? _currentEntry;

  /// Shows a notification popup with the given [child].
  static void show(
    BuildContext context, {
    required Widget child,
    NotificationDuration duration = NotificationDuration.medium,
    Alignment alignment = Alignment.bottomCenter,
  }) {
    // Dismiss any existing notification.
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    final durationMs = switch (duration) {
      NotificationDuration.short => 1500,
      NotificationDuration.medium => 3000,
      NotificationDuration.long => 5000,
    };

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _NotificationOverlay(
        alignment: alignment,
        onDismiss: () => entry.remove(),
        durationMs: durationMs,
        child: child,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Dismisses the current notification if any.
  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _NotificationOverlay extends StatefulWidget {
  const _NotificationOverlay({
    required this.alignment,
    required this.child,
    required this.onDismiss,
    required this.durationMs,
  });

  final Alignment alignment;
  final Widget child;
  final VoidCallback onDismiss;
  final int durationMs;

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    Future.delayed(Duration(milliseconds: widget.durationMs), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _NotificationRenderWidget(
      alignment: widget.alignment,
      animation: _animation,
      child: widget.child,
    );
  }
}

class _NotificationRenderWidget extends SingleChildRenderObjectWidget {
  const _NotificationRenderWidget({
    required this.alignment,
    required this.animation,
    required super.child,
  });

  final Alignment alignment;
  final Animation<double> animation;

  @override
  RenderNotificationOverlay createRenderObject(BuildContext context) {
    return RenderNotificationOverlay(
      alignment: alignment,
      animation: animation,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderNotificationOverlay renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..animation = animation;
  }
}

class RenderNotificationOverlay extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderNotificationOverlay({
    required Alignment alignment,
    required Animation<double> animation,
  }) : _alignment = alignment,
       _animation = animation {
    _animation.addListener(markNeedsPaint);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  Alignment _alignment;
  set alignment(Alignment val) {
    if (_alignment != val) {
      _alignment = val;
      markNeedsLayout();
    }
  }

  Animation<double> _animation;
  set animation(Animation<double> val) {
    if (_animation != val) {
      _animation.removeListener(markNeedsPaint);
      _animation = val;
      _animation.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    // Fill screen
    size = constraints.biggest;

    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      // We calculate position later in paint?
      // Usually layout determines position.
      // We align child inside size.
      // Indent 16.
      final BoxParentData pd = child!.parentData as BoxParentData;

      // Calculate aligned position.
      // Child bounds:
      double w = child!.size.width + 32; // + padding
      double h = child!.size.height + 24; // + padding

      // Align w/h within size.
      // Alignment: bottomCenter -> (0.0, 1.0)
      // x = (size.width - w) / 2 * (1 + align.x)
      double dx = (size.width - w) / 2 * (1 + _alignment.x);
      double dy = (size.height - h) / 2 * (1 + _alignment.y);

      // Add padding offset
      // 32 padding -> 16 left/right?
      // Actually dx is the Top-Left of the "Container" (bg).
      // Child is inside Container at (16, 12).

      // Apply constraint margin (e.g. 16 from screen edge).
      dx = dx.clamp(16.0, size.width - w - 16.0);
      dy = dy.clamp(16.0, size.height - h - 16.0);

      pd.offset = Offset(dx + 16, dy + 12);

      // Store container rect
      _bgRect = Rect.fromLTWH(dx, dy, w, h);
    }
  }

  Rect _bgRect = Rect.zero;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    // Animation
    // Fade: opacity = value.
    // Slide: from 0.3 * height to 0.
    final double animVal = _animation.value;
    if (animVal == 0) return;

    final int alpha = (animVal * 255).round();

    // Slide: Tween(begin: Offset(0, 0.3), end: zero).
    // Fractional translation? Or pixels?
    // Original used `SlideTransition` with `Offset(0, 0.3)`. That works on child size.
    // So dy += child.height * 0.3 * (1 - animVal).

    double slideY = (_bgRect.height) * 0.3 * (1.0 - animVal);

    // Transform
    context.pushTransform(
      needsCompositing,
      offset,
      Matrix4.translationValues(0, slideY, 0),
      (ctx, off) {
        context.pushOpacity(off, alpha, (ctx2, off2) {
          // Draw Background
          final Paint bgPaint = Paint()..color = const Color(0xFF323232);
          final RRect rrect = RRect.fromRectAndRadius(
            _bgRect.shift(off2 - offset),
            const Radius.circular(8),
          );

          // Shadow
          ctx2.canvas.drawShadow(
            Path()..addRRect(rrect),
            const Color(0x44000000),
            8,
            true,
          );

          ctx2.canvas.drawRRect(rrect, bgPaint);

          // Child
          if (child != null) {
            // pd removed from here to avoid duplication
            // pd.offset is global (relative to RenderVirtualList? No, relative to RenderVirtualList).
            // off2 is offset to layer.
            // child paint offset = off2 + pd.offset?
            // Wait, performLayout sets pd.offset relative to THIS box (0,0).
            // off2 is the offset of THIS box in current transform.
            // So we paint child at off2 + pd.offset.
            // Be careful with shift. _bgRect was stored in local coords.
            // rrect was shifted.

            // Wait, rrect above: `_bgRect.shift(off2 - offset)`.
            // `_bgRect` is local. `off2` is current draw origin. `offset` is original Paint offset.
            // If `pushTransform` changes coordinate system, `off2` might be (0,0) if transform handled it.
            // But `pushTransform` docs: "painter is called with the offset to the layer's origin".
            // Since we translated by (0, slideY), `off2` is effectively `off`.
            // Actually `pushTransform` just adds transform.

            // Let's use simpler logic:
            // Paint bg at `off2 + _bgRect.topLeft`.
            final Offset bgPos = off2 + _bgRect.topLeft;
            final RRect localRRect = RRect.fromRectAndRadius(
              bgPos & _bgRect.size,
              const Radius.circular(8),
            );

            ctx2.canvas.drawShadow(
              Path()..addRRect(localRRect),
              const Color(0x44000000),
              8,
              true,
            );
            ctx2.canvas.drawRRect(localRRect, bgPaint);

            final BoxParentData pd = child!.parentData as BoxParentData;
            ctx2.paintChild(child!, off2 + pd.offset);
          }
        });
      },
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child!.hitTest(result, position: transformed);
      },
    );
  }

  @override
  bool hitTestSelf(Offset position) => false; // Let clicks pass through if not on child?
  // Original overlay covers Screen. `Positioned.fill`.
  // If we return true here, we block clicks to app behind.
  // Original `Positioned.fill` -> `IgnorePointer(ignoring: false)` (means it receives events).
  // `Align` -> `DecoratedBox`.
  // If user clicks outside toast, does it dismiss?
  // `_NotificationOverlay` logic: No tap gesture detector.
  // So clicks outside pass through? `IgnorePointer` behaves based on HitTest.
  // If `Positioned.fill` is used, it covers area.
  // `RenderProxyBox` (Align) hit tests children.
  // If click is outside Align child, hitTest returns false.
  // So events pass through to underlying app.
  // So `hitTestSelf` should be false.

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsPaint);
    super.detach();
  }
}
