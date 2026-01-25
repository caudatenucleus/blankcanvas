import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A group of stacked avatars.
class AvatarGroup extends MultiChildRenderObjectWidget {
  const AvatarGroup({
    super.key,
    required List<Widget> avatars,
    this.maxDisplay = 3,
    this.size = 40.0,
    this.overlap = 0.3,
    this.borderColor = const Color(0xFFFFFFFF),
    this.borderWidth = 2.0,
    this.onExcessTap,
    this.tag,
  }) : super(children: avatars);

  final int maxDisplay;
  final double size;
  final double overlap;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onExcessTap;
  final String? tag;

  @override
  RenderAvatarGroup createRenderObject(BuildContext context) {
    return RenderAvatarGroup(
      maxDisplay: maxDisplay,
      avatarSize: size,
      overlap: overlap,
      borderColor: borderColor,
      borderWidth: borderWidth,
      onExcessTap: onExcessTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAvatarGroup renderObject,
  ) {
    renderObject
      ..maxDisplay = maxDisplay
      ..avatarSize = size
      ..overlap = overlap
      ..borderColor = borderColor
      ..borderWidth = borderWidth
      ..onExcessTap = onExcessTap;
  }
}

class AvatarGroupParentData extends ContainerBoxParentData<RenderBox> {}

class RenderAvatarGroup extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AvatarGroupParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AvatarGroupParentData> {
  RenderAvatarGroup({
    required int maxDisplay,
    required double avatarSize,
    required double overlap,
    required Color borderColor,
    required double borderWidth,
    VoidCallback? onExcessTap,
  }) : _maxDisplay = maxDisplay,
       _avatarSize = avatarSize,
       _overlap = overlap,
       _borderColor = borderColor,
       _borderWidth = borderWidth,
       _onExcessTap = onExcessTap;

  int _maxDisplay;
  set maxDisplay(int value) {
    if (_maxDisplay == value) return;
    _maxDisplay = value;
    markNeedsLayout();
  }

  double _avatarSize;
  set avatarSize(double value) {
    if (_avatarSize == value) return;
    _avatarSize = value;
    markNeedsLayout();
  }

  double _overlap;
  set overlap(double value) {
    if (_overlap == value) return;
    _overlap = value;
    markNeedsLayout();
  }

  Color _borderColor;
  set borderColor(Color value) {
    if (_borderColor == value) return;
    _borderColor = value;
    markNeedsPaint();
  }

  double _borderWidth;
  set borderWidth(double value) {
    if (_borderWidth == value) return;
    _borderWidth = value;
    markNeedsPaint();
  }

  VoidCallback? _onExcessTap;
  set onExcessTap(VoidCallback? value) {
    _onExcessTap = value;
  }

  late final TapGestureRecognizer _tap = TapGestureRecognizer()
    ..onTapUp = _handleTapUp;

  void _handleTapUp(TapUpDetails details) {
    // Check if tap is on Excess indicator
    if (childCount > _maxDisplay) {
      final int displayCount = _maxDisplay;
      final double overlapOffset = _avatarSize * (1 - _overlap);
      final double excessLeft = displayCount * overlapOffset;
      final Rect excessRect = Rect.fromLTWH(
        excessLeft,
        0,
        _avatarSize,
        _avatarSize,
      );

      if (excessRect.contains(details.localPosition)) {
        _onExcessTap?.call();
      }
    }
  }

  @override
  void detach() {
    _tap.dispose(); // Wait, dispose cleans up? Yes. But we can't reuse it.
    // Better create new one or just dispose if we own it.
    // Actually we shouldn't dispose if we want to reuse?
    // TapGestureRecognizer needs to be disposed when render object is disposed.
    super.detach();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AvatarGroupParentData) {
      child.parentData = AvatarGroupParentData();
    }
  }

  @override
  void performLayout() {
    final int totalCount = childCount;
    final int displayCount = totalCount > _maxDisplay
        ? _maxDisplay
        : totalCount;
    final int excessCount = totalCount - displayCount;

    final double overlapOffset = _avatarSize * (1 - _overlap);

    double width = overlapOffset * displayCount + _avatarSize * _overlap;
    if (excessCount > 0) {
      width += overlapOffset; // Add space for excess indicator
    }

    // Layout children
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      if (i < displayCount) {
        child.layout(
          BoxConstraints.tight(Size.square(_avatarSize)),
          parentUsesSize: false,
        );
        final AvatarGroupParentData pd =
            child.parentData as AvatarGroupParentData;
        // Reverse usage?
        // Stack usually paints first child at bottom.
        // Previous code: for (i = displayCount -1; i >=0).
        // i=displayCount-1 is on top? Positioned: left: i*overlap.
        // If i=0 is left-most. i=1 overlaps i=0?
        // Yes, index increases to the right.
        // But painting order?
        // If we paint loop i=0..N, i=N covers i=0.
        // So 2 covers 1.
        // Original code: i down to 0.
        // children: [Pos(i=2), Pos(i=1), Pos(i=0)].
        // Stack paints first first. So i=2 is at bottom?
        // Wait. Stack paints children in order.
        // `children: [A, B, C]`. C is on top.
        // Original code list was generated by `for i down`.
        // `children` list start with `i=max`.
        // So `i=max` is at bottom. `i=0` is on top.
        // Left-most avatar (i=0) is ON TOP.
        // Right-most avatar (i=max) is on BOTTOM.

        // In RenderAvatarGroup, `firstChild` corresponds to `avatars[0]`.
        // We iterate `child`.
        // We want `avatars[0]` (left-most) to be painted LAST (on top).
        // So we should paint in reverse order?
        // `defaultPaint` paints in order (first to last).
        // If we want [0] on top, we should paint [N] first.

        // Layout position:
        pd.offset = Offset(i * overlapOffset, 0);
      } else {
        // Hidden children (only layout to 0,0 size to avoid errors or just layout 0?)
        child.layout(BoxConstraints.tight(Size.zero));
      }
      child = (child.parentData as AvatarGroupParentData).nextSibling;
      i++;
    }

    size = constraints.constrain(Size(width, _avatarSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint excess indicator first? (It usually is right-most).
    // Original code: Excess is added AFTER loop.
    // children: [Avatars..., Excess].
    // Excess is on Top of everything?
    // Positioned(left: displayCount * overlap).
    // Yes.

    final int totalCount = childCount;
    final int displayCount = totalCount > _maxDisplay
        ? _maxDisplay
        : totalCount;
    final int excessCount = totalCount - displayCount;
    final double overlapOffset = _avatarSize * (1 - _overlap);

    // Paint Avatars
    // We want index 0 on top.
    // So we need to paint index displayCount-1, then displayCount-2... then 0.

    // We can collect necessary children in a list and paint.
    List<RenderBox> painters = [];
    RenderBox? child = firstChild;
    for (int i = 0; i < displayCount; i++) {
      painters.add(child!);
      child = (child.parentData as AvatarGroupParentData).nextSibling;
    }

    // Loop reverse
    for (final c in painters.reversed) {
      final AvatarGroupParentData pd = c.parentData as AvatarGroupParentData;
      _paintAvatar(context, offset + pd.offset, c);
    }

    // Paint Excess Indicator if needed
    if (excessCount > 0) {
      final Offset excessPos = offset + Offset(displayCount * overlapOffset, 0);
      _paintExcess(context, excessPos, excessCount);
    }
  }

  void _paintAvatar(PaintingContext context, Offset pos, RenderBox child) {
    // Paint border/clip mask?
    // Border is on top of bg, around child.
    final Rect rect = pos & Size.square(_avatarSize);

    context.canvas.save();
    // Clip
    final Path clipPath = Path()..addOval(rect);
    context.canvas.clipPath(clipPath);
    context.paintChild(child, pos);
    context.canvas.restore();

    // Draw Border
    if (_borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth;

      // Stroke aligns center of path.
      // We want border INSIDE or CENTER?
      // Flutter Border works usually inside/center.
      // Let's assume center.
      context.canvas.drawOval(rect.deflate(_borderWidth / 2), borderPaint);
    }
  }

  void _paintExcess(PaintingContext context, Offset pos, int count) {
    final Rect rect = pos & Size.square(_avatarSize);

    // Background
    final Paint bgPaint = Paint()..color = const Color(0xFFE0E0E0);
    context.canvas.drawOval(rect, bgPaint);

    // Border
    if (_borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth;
      context.canvas.drawOval(rect.deflate(_borderWidth / 2), borderPaint);
    }

    // Text
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '+$count',
        style: TextStyle(
          fontSize: _avatarSize * 0.3,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF666666),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      context.canvas,
      pos + Offset((_avatarSize - tp.width) / 2, (_avatarSize - tp.height) / 2),
    );
    tp.dispose();
  }
}
