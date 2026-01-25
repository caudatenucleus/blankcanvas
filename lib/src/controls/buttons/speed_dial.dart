import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;
import 'package:blankcanvas/src/rendering/icon_primitive.dart';

class SpeedDialItem {
  const SpeedDialItem({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
}

/// A floating action button using lowest-level RenderObject APIs.
class SpeedDial extends MultiChildRenderObjectWidget {
  SpeedDial({
    super.key,
    required this.items,
    this.mainIcon = const IconData(0xe145, fontFamily: 'MaterialIcons'),
    this.activeIcon = const IconData(0xe5cd, fontFamily: 'MaterialIcons'),
    this.color = const Color(0xFF2196F3),
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.tag,
  }) : super(children: _buildChildren(items, mainIcon, color, foregroundColor));

  final List<SpeedDialItem> items;
  final IconData mainIcon;
  final IconData activeIcon;
  final Color color;
  final Color foregroundColor;
  final String? tag;

  static List<Widget> _buildChildren(
    List<SpeedDialItem> items,
    IconData mainIcon,
    Color color,
    Color foregroundColor,
  ) {
    final children = <Widget>[];

    // Main FAB
    children.add(
      layout.Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: IconPrimitive(icon: mainIcon, color: foregroundColor, size: 24),
      ),
    );

    // Items (simplified for now as static list above the FAB)
    for (final item in items) {
      children.add(
        _SpeedDialItem(label: item.label, icon: item.icon, onTap: item.onTap),
      );
    }

    return children;
  }

  @override
  RenderSpeedDial createRenderObject(BuildContext context) {
    return RenderSpeedDial();
  }

  @override
  void updateRenderObject(BuildContext context, RenderSpeedDial renderObject) {
    // Update logic
  }
}

class RenderSpeedDial extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StackParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! StackParentData) {
      child.parentData = StackParentData();
    }
  }

  @override
  void performLayout() {
    double currentY = constraints.maxHeight;
    RenderBox? child = firstChild;

    if (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final pd = child.parentData! as StackParentData;
      pd.offset = Offset(
        constraints.maxWidth - child.size.width,
        currentY - child.size.height,
      );
      currentY -= child.size.height + 8;
      child = pd.nextSibling;
    }

    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final pd = child.parentData! as StackParentData;
      pd.offset = Offset(
        constraints.maxWidth - child.size.width,
        currentY - child.size.height,
      );
      currentY -= child.size.height + 12;
      child = pd.nextSibling;
    }

    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class _SpeedDialItem extends LeafRenderObjectWidget {
  const _SpeedDialItem({required this.label, this.icon, required this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  RenderSpeedDialItem createRenderObject(BuildContext context) {
    return RenderSpeedDialItem(label: label, icon: icon, onTap: onTap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSpeedDialItem renderObject,
  ) {
    renderObject
      ..label = label
      ..icon = icon
      ..onTap = onTap;
  }
}

class RenderSpeedDialItem extends RenderBox {
  RenderSpeedDialItem({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
  }) : _label = label,
       _icon = icon,
       _onTap = onTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  String _label;
  set label(String value) {
    if (_label == value) return;
    _label = value;
    markNeedsPaint();
  }

  IconData? _icon;
  set icon(IconData? value) {
    if (_icon == value) return;
    _icon = value;
    markNeedsPaint();
  }

  VoidCallback? _onTap;
  set onTap(VoidCallback? value) {
    _onTap = value;
  }

  late TapGestureRecognizer _tap;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  void _handleTapUp(TapUpDetails details) {
    _onTap?.call();
  }

  TextPainter? _labelPainter;
  TextPainter? _iconPainter;

  @override
  void performLayout() {
    // Label
    _labelPainter ??= TextPainter(textDirection: TextDirection.ltr);
    _labelPainter!.text = TextSpan(
      text: _label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Color(0xFF333333),
      ),
    );
    _labelPainter!.layout();

    // Icon
    if (_icon != null) {
      _iconPainter ??= TextPainter(textDirection: TextDirection.ltr);
      _iconPainter!.text = TextSpan(
        text: String.fromCharCode(_icon!.codePoint),
        style: TextStyle(
          fontSize: 20,
          fontFamily: _icon!.fontFamily,
          color: const Color(0xFF666666),
        ),
      );
      _iconPainter!.layout();
    }

    // Width = Label Width + Padding(16) + Gap(12) + FabSize(40)
    // Height = Max(LabelHeight + Padding, FabSize) ~= 48
    final width = _labelPainter!.width + 16 + 12 + 48;
    size = constraints.constrain(Size(width, 48));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final centerY = offset.dy + size.height / 2;

    // Paint Label Background
    final labelHeight = _labelPainter!.height + 8;
    final labelWidth = _labelPainter!.width + 16;
    final labelRect = Rect.fromLTWH(
      offset.dx,
      centerY - labelHeight / 2,
      labelWidth,
      labelHeight,
    );
    final labelBgPaint = Paint()..color = const Color(0xFFFFFFFF);

    // Shadow
    canvas.drawShadow(
      Path()..addRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      ),
      const Color(0x40000000),
      2,
      true,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      labelBgPaint,
    );

    // Paint Label Text
    _labelPainter!.paint(
      canvas,
      Offset(offset.dx + 8, centerY - _labelPainter!.height / 2),
    );

    // Paint Mini FAB
    final fabX = offset.dx + labelWidth + 12;
    final fabRect = Rect.fromCenter(
      center: Offset(fabX + 20, centerY), // 40/2 = 20 radius
      width: 40,
      height: 40,
    ); // Wait, original was 48 width container.
    // Let's use 40 visual circle.

    // Shadow
    canvas.drawShadow(
      Path()..addOval(fabRect),
      const Color(0x40000000),
      4,
      true,
    );

    canvas.drawOval(fabRect, Paint()..color = const Color(0xFFFFFFFF));

    // Paint Icon
    if (_icon != null && _iconPainter != null) {
      _iconPainter!.paint(
        canvas,
        Offset(
          fabRect.center.dx - _iconPainter!.width / 2,
          fabRect.center.dy - _iconPainter!.height / 2,
        ),
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => size.contains(position);

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }
}
