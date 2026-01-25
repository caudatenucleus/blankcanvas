import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/customization.dart';
import 'package:blankcanvas/src/rendering/icon_primitive.dart';

enum ChipSlot { avatar, label, deleteIcon }

class ChipParentData extends ContainerBoxParentData<RenderBox> {
  ChipSlot? slot;
}

class _ChipSlot extends ParentDataWidget<ChipParentData> {
  const _ChipSlot({required this.slot, required super.child});
  final ChipSlot slot;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! ChipParentData) {
      renderObject.parentData = ChipParentData();
    }
    final ChipParentData parentData = renderObject.parentData as ChipParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Chip;
}

/// A compact element representing an attribute, text, or action using lowest-level RenderObject APIs.
class Chip extends MultiChildRenderObjectWidget {
  Chip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.avatar,
    this.tag,
  }) : super(
         children: [
           if (avatar != null) _ChipSlot(slot: ChipSlot.avatar, child: avatar),
           _ChipSlot(slot: ChipSlot.label, child: label),
           if (onDeleted != null)
             _ChipSlot(
               slot: ChipSlot.deleteIcon,
               child: const IconPrimitive(
                 icon: IconData(0x2715, fontFamily: 'MaterialIcons'),
                 size: 16,
                 color: Color(0xFF757575),
               ),
             ),
         ],
       );

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final Widget? avatar;
  final String? tag;

  @override
  RenderChip createRenderObject(BuildContext context) {
    return RenderChip(
      selected: selected,
      onSelected: onSelected,
      onDeleted: onDeleted,
      customization: ChipCustomization.simple(),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderChip renderObject) {
    renderObject
      ..selected = selected
      ..onSelected = onSelected
      ..onDeleted = onDeleted
      ..customization = ChipCustomization.simple();
  }
}

class RenderChip extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ChipParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ChipParentData>
    implements TickerProvider {
  RenderChip({
    required bool selected,
    ValueChanged<bool>? onSelected,
    VoidCallback? onDeleted,
    required ChipCustomization customization,
  }) : _selected = selected,
       _onSelected = onSelected,
       _onDeleted = onDeleted,
       _customization = customization {
    _tap = TapGestureRecognizer()
      ..onTapUp = _handleTapUp
      ..onTapDown = _handleTapDown
      ..onTapCancel = _handleTapCancel;
  }

  bool _selected;
  bool get selected => _selected;
  set selected(bool value) {
    if (_selected == value) return;
    _selected = value;
    markNeedsPaint();
  }

  ValueChanged<bool>? _onSelected;
  set onSelected(ValueChanged<bool>? value) {
    _onSelected = value;
  }

  VoidCallback? _onDeleted;
  set onDeleted(VoidCallback? value) {
    _onDeleted = value;
  }

  ChipCustomization _customization;
  set customization(ChipCustomization value) {
    if (_customization == value) return;
    _customization = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  bool _isHovered = false;
  bool _isPressed = false;
  Ticker? _ticker;
  double _hoverValue = 0.0;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ChipParentData) {
      child.parentData = ChipParentData();
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void _startTicker() {
    if (_ticker == null) {
      _ticker = createTicker(_tick)..start();
    } else if (!_ticker!.isActive) {
      _ticker!.start();
    }
  }

  void _tick(Duration elapsed) {
    final double targetHover = _isHovered ? 1.0 : 0.0;
    if ((_hoverValue - targetHover).abs() > 0.01) {
      _hoverValue += (targetHover - _hoverValue) * 0.2;
      markNeedsPaint();
    } else {
      _hoverValue = targetHover;
      _ticker?.stop();
    }
  }

  @override
  void detach() {
    _ticker?.dispose();
    super.detach();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      if (!_isHovered) {
        _isHovered = true;
        _startTicker();
      }
    } else if (event is PointerExitEvent) {
      if (_isHovered) {
        _isHovered = false;
        _startTicker();
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _isPressed = true;
    markNeedsPaint();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      _isPressed = false;
      markNeedsPaint();

      final RenderBox? deleteIcon = _childForSlot(ChipSlot.deleteIcon);
      if (deleteIcon != null) {
        final ChipParentData pd = deleteIcon.parentData as ChipParentData;
        final Rect deleteRect = pd.offset & deleteIcon.size;
        if (deleteRect.inflate(4).contains(details.localPosition)) {
          _onDeleted?.call();
          return;
        }
      }
      _onSelected?.call(!_selected);
    }
  }

  void _handleTapCancel() {
    _isPressed = false;
    markNeedsPaint();
  }

  RenderBox? _childForSlot(ChipSlot slot) {
    RenderBox? child = firstChild;
    while (child != null) {
      final ChipParentData pd = child.parentData as ChipParentData;
      if (pd.slot == slot) return child;
      child = pd.nextSibling;
    }
    return null;
  }

  @override
  void performLayout() {
    final double spacing = 6.0;
    final EdgeInsets padding =
        (_customization.padding ??
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6))
            .resolve(TextDirection.ltr);

    double widthUsed = padding.horizontal;
    double heightUsed = 0.0;

    final RenderBox? avatar = _childForSlot(ChipSlot.avatar);
    final RenderBox? label = _childForSlot(ChipSlot.label);
    final RenderBox? deleteIcon = _childForSlot(ChipSlot.deleteIcon);

    if (avatar != null) {
      avatar.layout(constraints.loosen(), parentUsesSize: true);
      widthUsed += avatar.size.width + spacing;
      heightUsed = avatar.size.height;
    }

    double iconWidth = 0.0;
    if (deleteIcon != null) {
      deleteIcon.layout(constraints.loosen(), parentUsesSize: true);
      iconWidth = deleteIcon.size.width + spacing;
      if (deleteIcon.size.height > heightUsed)
        heightUsed = deleteIcon.size.height;
    }

    if (label != null) {
      final double maxWidth = (constraints.maxWidth - widthUsed - iconWidth)
          .clamp(0.0, double.infinity);
      label.layout(BoxConstraints(maxWidth: maxWidth), parentUsesSize: true);
      widthUsed += label.size.width;
      if (label.size.height > heightUsed) heightUsed = label.size.height;
    }

    widthUsed += iconWidth;
    heightUsed += padding.vertical;
    size = constraints.constrain(Size(widthUsed, heightUsed));

    double x = padding.left;
    final double centerY = padding.top + (heightUsed - padding.vertical) / 2;

    if (avatar != null) {
      final ChipParentData pd = avatar.parentData as ChipParentData;
      pd.offset = Offset(x, centerY - avatar.size.height / 2);
      x += avatar.size.width + spacing;
    }
    if (label != null) {
      final ChipParentData pd = label.parentData as ChipParentData;
      pd.offset = Offset(x, centerY - label.size.height / 2);
      x += label.size.width;
    }
    if (deleteIcon != null) {
      x += spacing;
      final ChipParentData pd = deleteIcon.parentData as ChipParentData;
      pd.offset = Offset(x, centerY - deleteIcon.size.height / 2);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RadioControlStatus status = RadioControlStatus()
      ..selected = _selected ? 1.0 : 0.0
      ..hovered = _hoverValue;
    final decoration = _customization.decoration(status);
    final Rect rect = offset & size;
    if (decoration is BoxDecoration) {
      final Paint bgPaint = Paint()
        ..color = decoration.color ?? const Color(0xFFEEEEEE);
      if (decoration.borderRadius != null) {
        final borderRadius = decoration.borderRadius!.resolve(
          TextDirection.ltr,
        );
        context.canvas.drawRRect(borderRadius.toRRect(rect), bgPaint);
        decoration.border?.paint(
          context.canvas,
          rect,
          borderRadius: borderRadius,
        );
      } else {
        context.canvas.drawRect(rect, bgPaint);
        decoration.border?.paint(context.canvas, rect);
      }
    } else {
      final BoxPainter painter = decoration.createBoxPainter();
      painter.paint(context.canvas, offset, ImageConfiguration(size: size));
      painter.dispose();
    }
    defaultPaint(context, offset);
  }
}
