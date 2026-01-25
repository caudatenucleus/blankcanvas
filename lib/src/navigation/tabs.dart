import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';

/// Status for a single Tab.
class TabStatus extends TabControlStatus {}

/// A Segmented Control / Tab Bar.
class TabControl<T> extends MultiChildRenderObjectWidget {
  TabControl({
    super.key,
    required this.items,
    required this.groupValue,
    required this.onChanged,
    this.tag,
  }) : super(
         children: items
             .map(
               (item) => _TabSlot<T>(
                 item: item,
                 isSelected: item == groupValue,
                 child: ParagraphPrimitive(
                   text: TextSpan(
                     text: item.toString(),
                     style: const TextStyle(
                       fontSize: 14.0,
                       color: Color(0xFF000000),
                     ),
                   ),
                 ),
               ),
             )
             .toList(),
       );

  final List<T> items;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String? tag;

  @override
  RenderTabControl<T> createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTab(tag);
    return RenderTabControl<T>(
      items: items,
      groupValue: groupValue,
      onChanged: onChanged,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTabControl<T> renderObject,
  ) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTab(tag);
    renderObject
      ..items = items
      ..groupValue = groupValue
      ..onChanged = onChanged
      ..customization = customization;
  }
}

class _TabSlot<T> extends ParentDataWidget<_TabParentData> {
  const _TabSlot({
    required this.item,
    required this.isSelected,
    required super.child,
  });

  final T item;
  final bool isSelected;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! _TabParentData) {
      renderObject.parentData = _TabParentData();
    }
    final pd = renderObject.parentData as _TabParentData;
    pd.isSelected = isSelected;
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TabControl;
}

class _TabParentData extends ContainerBoxParentData<RenderBox> {
  bool isSelected = false;
}

class RenderTabControl<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TabParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TabParentData> {
  RenderTabControl({
    required List<T> items,
    required T groupValue,
    required ValueChanged<T> onChanged,
    TabCustomization? customization,
  }) : _items = items,
       _groupValue = groupValue,
       _onChanged = onChanged,
       _customization = customization {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<T> _items;
  set items(List<T> value) {
    _items = value;
    markNeedsLayout();
  }

  T _groupValue;
  set groupValue(T value) {
    if (_groupValue != value) {
      _groupValue = value;
      markNeedsPaint();
    }
  }

  ValueChanged<T> _onChanged;
  set onChanged(ValueChanged<T> value) => _onChanged = value;

  TabCustomization? _customization;
  set customization(TabCustomization? value) {
    _customization = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;
  final List<Rect> _tabRects = [];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TabParentData) {
      child.parentData = _TabParentData();
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _tabRects.clear();
    double x = 0;
    double maxHeight = 0;
    final padding =
        _customization?.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final resolvedPadding = padding.resolve(TextDirection.ltr);

    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final pd = child.parentData as _TabParentData;

      final tabWidth = child.size.width + resolvedPadding.horizontal;
      final tabHeight = child.size.height + resolvedPadding.vertical;

      pd.offset = Offset(x + resolvedPadding.left, resolvedPadding.top);
      _tabRects.add(Rect.fromLTWH(x, 0, tabWidth, tabHeight));

      x += tabWidth;
      maxHeight = maxHeight > tabHeight ? maxHeight : tabHeight;

      child = childAfter(child);
      index++;
    }

    size = constraints.constrain(Size(x, maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      if (index >= _tabRects.length) break;

      final pd = child.parentData as _TabParentData;
      final rect = _tabRects[index].shift(offset);
      final isSelected = index < _items.length && _items[index] == _groupValue;
      final isHovered = index == _hoveredIndex;

      // Create status
      final status = TabStatus()
        ..selected = isSelected ? 1.0 : 0.0
        ..hovered = isHovered ? 1.0 : 0.0;

      // Get decoration
      final decoration = _customization?.decoration(status);
      if (decoration is BoxDecoration) {
        final paint = Paint()
          ..color = decoration.color ?? const Color(0x00000000);

        if (decoration.borderRadius != null) {
          final borderRadius = decoration.borderRadius!.resolve(
            TextDirection.ltr,
          );
          canvas.drawRRect(borderRadius.toRRect(rect), paint);
          decoration.border?.paint(canvas, rect, borderRadius: borderRadius);
        } else {
          canvas.drawRect(rect, paint);
          decoration.border?.paint(canvas, rect);
        }
      }

      // Paint child
      context.paintChild(child, pd.offset + offset);

      child = childAfter(child);
      index++;
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _tabRects.length; i++) {
      if (_tabRects[i].contains(local) && i < _items.length) {
        _onChanged(_items[i]);
        break;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _tabRects.length; i++) {
      if (_tabRects[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_hoveredIndex != hovered) {
      _hoveredIndex = hovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
