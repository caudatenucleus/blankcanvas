import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';

/// Toolbar actions for RichTextEditor.
enum RichTextAction {
  bold,
  italic,
  underline,
  strikethrough,
  bulletList,
  numberedList,
  link,
  image,
  heading1,
  heading2,
  heading3,
  quote,
  code,
  clearFormatting,
}

/// A basic rich text editor widget using lowest-level RenderObject APIs.
class RichTextEditor extends MultiChildRenderObjectWidget {
  RichTextEditor({
    super.key,
    this.initialValue,
    this.onChanged,
    this.placeholder,
    this.enabledActions = const [
      RichTextAction.bold,
      RichTextAction.italic,
      RichTextAction.underline,
      RichTextAction.bulletList,
      RichTextAction.numberedList,
      RichTextAction.link,
    ],
    this.tag,
  }) : super(children: _buildChildren(enabledActions, placeholder));

  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final List<RichTextAction> enabledActions;
  final String? tag;

  static List<Widget> _buildChildren(
    List<RichTextAction> actions,
    String? placeholder,
  ) {
    final items = <Widget>[];

    // Toolbar
    items.add(
      layout.Container(
        height: 40,
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: layout.Row(
          children: actions
              .map(
                (a) => _ToolbarItem(
                  icon: const IconData(0xe238, fontFamily: 'MaterialIcons'),
                  onTap: () {}, // connect action
                ),
              )
              .toList(),
        ),
      ),
    );

    // Separator
    items.add(layout.Container(height: 1, color: const Color(0xFFE0E0E0)));

    // Content area
    items.add(
      layout.Padding(
        padding: const EdgeInsets.all(12),
        child: ParagraphPrimitive(
          text: TextSpan(
            text: placeholder ?? 'Enter text...',
            style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
          ),
        ),
      ),
    );

    return items;
  }

  @override
  RenderRichTextEditor createRenderObject(BuildContext context) {
    return RenderRichTextEditor();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderRichTextEditor renderObject,
  ) {
    // Update logic
  }
}

class RenderRichTextEditor extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {
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
      child.layout(constraints.loosen(), parentUsesSize: true);
      final pd = child.parentData! as FlexParentData;
      pd.offset = Offset(0, currentY);
      currentY += child.size.height;
      child = pd.nextSibling;
    }
    size = constraints.constrain(Size(constraints.maxWidth, currentY));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Draw border
    context.canvas.drawRect(
      offset & size,
      Paint()
        ..color = const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke,
    );
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class _ToolbarItem extends LeafRenderObjectWidget {
  const _ToolbarItem({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  RenderToolbarItem createRenderObject(BuildContext context) {
    return RenderToolbarItem(icon: icon, onTap: onTap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderToolbarItem renderObject,
  ) {
    renderObject
      ..icon = icon
      ..onTap = onTap;
  }
}

class RenderToolbarItem extends RenderBox {
  RenderToolbarItem({required IconData icon, VoidCallback? onTap})
    : _icon = icon,
      _onTap = onTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  IconData _icon;
  set icon(IconData value) {
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

  TextPainter? _iconPainter;

  @override
  void performLayout() {
    _iconPainter ??= TextPainter(textDirection: TextDirection.ltr);
    _iconPainter!.text = TextSpan(
      text: String.fromCharCode(_icon.codePoint),
      style: TextStyle(
        fontSize: 18,
        fontFamily: _icon.fontFamily,
        color: const Color(0xFF333333),
      ),
    );
    _iconPainter!.layout();

    // Size: Icon + Padding (right 4, left 0?) Original had right 4.
    // Let's make it a clickable touch target size, e.g. 24x24 or 30x30?
    // Original was Padding(right:4, child: Icon(size: 18)).
    // So visual width = 18. Layout width = 22. Height = 18.
    // Let's ensure min touch height? 40 height toolbar.
    // Let's vertically center it in 40 (parent constraint handles centering if Row allows).
    // Row aligns center by default.
    // We'll set size to 22x24.

    size = constraints.constrain(const Size(22, 24)); // 18 + 4 gap
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Vertically center icon in our box (24 height, icon 18 height)
    final dy = (size.height - _iconPainter!.height) / 2;
    _iconPainter!.paint(context.canvas, offset + Offset(0, dy));
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
