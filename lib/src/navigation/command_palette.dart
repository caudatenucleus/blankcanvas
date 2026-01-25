import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';
import 'package:blankcanvas/src/rendering/icon_primitive.dart';

class CommandAction {
  const CommandAction({
    required this.id,
    required this.label,
    required this.onExecute,
    this.shortcut,
    this.icon,
  });

  final String id;
  final String label;
  final VoidCallback? onExecute;
  final String? shortcut;
  final IconData? icon;
}

/// A command palette using lowest-level RenderObject APIs.
class CommandPalette extends MultiChildRenderObjectWidget {
  CommandPalette({
    super.key,
    required this.actions,
    this.width = 600,
    this.maxHeight = 400,
    this.hintText = 'Type a command...',
    this.tag,
  }) : super(children: _buildChildren(actions, hintText, width, maxHeight));

  final List<CommandAction> actions;
  final double width;
  final double maxHeight;
  final String hintText;
  final String? tag;

  static List<Widget> _buildChildren(
    List<CommandAction> actions,
    String hintText,
    double width,
    double maxHeight,
  ) {
    final items = <Widget>[];

    // Header / Search
    items.add(
      layout.Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: layout.Row(
          children: [
            const IconPrimitive(
              icon: IconData(0xe8b6, fontFamily: 'MaterialIcons'),
              color: Color(0xFF999999),
              size: 20,
            ),
            const layout.SizedBox(width: 12),
            ParagraphPrimitive(
              text: TextSpan(
                text: hintText,
                style: const TextStyle(fontSize: 16, color: Color(0xFFBBBBBB)),
              ),
            ),
          ],
        ),
      ),
    );

    // Separator
    items.add(layout.Container(height: 1, color: const Color(0xFFEEEEEE)));

    // Actions
    for (final action in actions) {
      items.add(
        _CommandItem(
          icon: action.icon,
          label: action.label,
          shortcut: action.shortcut,
        ),
      );
    }

    return items;
  }

  @override
  RenderCommandPalette createRenderObject(BuildContext context) {
    return RenderCommandPalette(width: width, maxHeight: maxHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCommandPalette renderObject,
  ) {
    renderObject
      ..width = width
      ..maxHeight = maxHeight;
  }
}

class RenderCommandPalette extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {
  RenderCommandPalette({required double width, required double maxHeight})
    : _width = width,
      _maxHeight = maxHeight;

  double _width;
  set width(double value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double _maxHeight;
  set maxHeight(double value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  @override
  void performLayout() {
    double currentY = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints(
          minWidth: _width,
          maxWidth: _width,
          minHeight: 0,
          maxHeight: _maxHeight,
        ),
        parentUsesSize: true,
      );
      final pd = child.parentData! as FlexParentData;
      pd.offset = Offset(0, currentY);
      currentY += child.size.height;
      child = pd.nextSibling;
    }
    size = constraints.constrain(Size(_width, currentY.clamp(0.0, _maxHeight)));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Draw background
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, const Radius.circular(8)),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class _CommandItem extends LeafRenderObjectWidget {
  const _CommandItem({
    required this.icon,
    required this.label,
    required this.shortcut,
  });

  final IconData? icon;
  final String label;
  final String? shortcut;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCommandItem(icon: icon, label: label, shortcut: shortcut);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCommandItem renderObject,
  ) {
    renderObject
      ..icon = icon
      ..label = label
      ..shortcut = shortcut;
  }
}

class RenderCommandItem extends RenderBox {
  RenderCommandItem({IconData? icon, required String label, String? shortcut})
    : _icon = icon,
      _label = label,
      _shortcut = shortcut;

  IconData? _icon;
  set icon(IconData? value) {
    if (_icon == value) return;
    _icon = value;
    markNeedsPaint();
  }

  String _label;
  set label(String value) {
    if (_label == value) return;
    _label = value;
    markNeedsPaint();
  }

  String? _shortcut;
  set shortcut(String? value) {
    if (_shortcut == value) return;
    _shortcut = value;
    markNeedsPaint();
  }

  // Helper primitives
  TextPainter? _iconPainter;
  TextPainter? _labelPainter;
  TextPainter? _shortcutPainter;

  @override
  void performLayout() {
    double width = constraints.maxWidth;
    double height = 44.0; // Fixed height ~12 padding + 20 icon + 12 padding

    // Layout Icon
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

    // Layout Label
    _labelPainter ??= TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );
    _labelPainter!.text = TextSpan(
      text: _label,
      style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
    );
    _labelPainter!.layout(maxWidth: width - 60); // approximate space

    // Layout Shortcut
    if (_shortcut != null) {
      _shortcutPainter ??= TextPainter(textDirection: TextDirection.ltr);
      _shortcutPainter!.text = TextSpan(
        text: _shortcut,
        style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
      );
      _shortcutPainter!.layout();
    }

    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    double currentX = offset.dx + 16;
    final centerY = offset.dy + size.height / 2;

    // Paint Icon
    if (_icon != null && _iconPainter != null) {
      _iconPainter!.paint(
        canvas,
        Offset(currentX, centerY - _iconPainter!.height / 2),
      );
      currentX += 20 + 12; // Icon size + gap
    }

    // Paint Label
    if (_labelPainter != null) {
      _labelPainter!.paint(
        canvas,
        Offset(currentX, centerY - _labelPainter!.height / 2),
      );
    }

    // Paint Shortcut (Right aligned)
    if (_shortcut != null && _shortcutPainter != null) {
      final shortcutX = offset.dx + size.width - 16 - _shortcutPainter!.width;
      _shortcutPainter!.paint(
        canvas,
        Offset(shortcutX, centerY - _shortcutPainter!.height / 2),
      );
    }
  }
}
