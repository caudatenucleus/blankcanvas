import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';
import 'package:blankcanvas/src/rendering/icon_primitive.dart';

enum BannerType { info, success, warning, error }

enum BannerSlotType { icon, message, action, dismiss }

class BannerParentData extends ContainerBoxParentData<RenderBox> {
  BannerSlotType? slot;
}

class BannerSlot extends ParentDataWidget<BannerParentData> {
  const BannerSlot({super.key, required this.slot, required super.child});
  final BannerSlotType slot;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! BannerParentData) {
      renderObject.parentData = BannerParentData();
    }
    final parentData = renderObject.parentData as BannerParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Banner;
}

/// An inline banner for displaying notifications or status using lowest-level RenderObject APIs.
class Banner extends MultiChildRenderObjectWidget {
  Banner({
    Key? key,
    required String message,
    BannerType type = BannerType.info,
    String? action,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
    String? tag,
  }) : this._raw(
         key: key,
         children: _buildChildren(message, type, action, onDismiss != null),
         type: type,
         onAction: onAction,
         onDismiss: onDismiss,
         tag: tag,
       );

  const Banner._raw({
    super.key,
    required super.children,
    required this.type,
    this.onAction,
    this.onDismiss,
    this.tag,
  });

  final BannerType type;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final String? tag;

  static List<Widget> _buildChildren(
    String message,
    BannerType type,
    String? action,
    bool hasDismiss,
  ) {
    Color textColor;
    IconData iconData;

    switch (type) {
      case BannerType.info:
        textColor = const Color(0xFF0D47A1);
        iconData = const IconData(0xe88e, fontFamily: 'MaterialIcons');
        break;
      case BannerType.success:
        textColor = const Color(0xFF1B5E20);
        iconData = const IconData(0xe86c, fontFamily: 'MaterialIcons');
        break;
      case BannerType.warning:
        textColor = const Color(0xFFE65100);
        iconData = const IconData(0xe002, fontFamily: 'MaterialIcons');
        break;
      case BannerType.error:
        textColor = const Color(0xFFB71C1C);
        iconData = const IconData(0xe000, fontFamily: 'MaterialIcons');
        break;
    }

    final children = <Widget>[
      BannerSlot(
        slot: BannerSlotType.icon,
        child: IconPrimitive(icon: iconData, color: textColor, size: 20),
      ),
      BannerSlot(
        slot: BannerSlotType.message,
        child: ParagraphPrimitive(
          text: TextSpan(
            text: message,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
      ),
    ];

    if (action != null) {
      children.add(
        BannerSlot(
          slot: BannerSlotType.action,
          child: ParagraphPrimitive(
            text: TextSpan(
              text: action,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
    }

    if (hasDismiss) {
      children.add(
        BannerSlot(
          slot: BannerSlotType.dismiss,
          child: IconPrimitive(
            icon: const IconData(0xe5cd, fontFamily: 'MaterialIcons'),
            color: textColor.withValues(alpha: 0.6),
            size: 18,
          ),
        ),
      );
    }
    return children;
  }

  @override
  RenderBanner createRenderObject(BuildContext context) {
    return RenderBanner(type: type, onAction: onAction, onDismiss: onDismiss);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBanner renderObject) {
    renderObject
      ..type = type
      ..onAction = onAction
      ..onDismiss = onDismiss;
  }
}

class RenderBanner extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, BannerParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, BannerParentData> {
  RenderBanner({
    required BannerType type,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) : _type = type,
       _onAction = onAction,
       _onDismiss = onDismiss {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  BannerType _type;
  set type(BannerType value) {
    if (_type != value) {
      _type = value;
      markNeedsPaint();
    }
  }

  VoidCallback? _onAction;
  set onAction(VoidCallback? value) {
    _onAction = value;
  }

  VoidCallback? _onDismiss;
  set onDismiss(VoidCallback? value) {
    _onDismiss = value;
  }

  late TapGestureRecognizer _tap;
  Rect? _actionBounds;
  Rect? _dismissBounds;
  bool _hitAction = false;
  bool _hitDismiss = false;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_hitAction && _onAction != null) {
      _onAction!();
    } else if (_hitDismiss && _onDismiss != null) {
      _onDismiss!();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BannerParentData) {
      child.parentData = BannerParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? icon;
    RenderBox? message;
    RenderBox? action;
    RenderBox? dismiss;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as BannerParentData;
      if (pd.slot == BannerSlotType.icon) icon = child;
      if (pd.slot == BannerSlotType.message) message = child;
      if (pd.slot == BannerSlotType.action) action = child;
      if (pd.slot == BannerSlotType.dismiss) dismiss = child;
      child = childAfter(child);
    }

    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    const spacing = 12.0;
    final innerConstraints = constraints.deflate(padding);

    double iconWidth = 0;
    if (icon != null) {
      icon.layout(innerConstraints.loosen(), parentUsesSize: true);
      iconWidth = icon.size.width;
    }

    double dismissWidth = 0;
    if (dismiss != null) {
      dismiss.layout(innerConstraints.loosen(), parentUsesSize: true);
      dismissWidth = dismiss.size.width;
    }

    double contentMaxWidth =
        (innerConstraints.maxWidth -
                iconWidth -
                spacing -
                (dismiss != null ? dismissWidth + spacing : 0))
            .clamp(0.0, double.infinity);
    final contentConstraints = BoxConstraints(maxWidth: contentMaxWidth);

    double messageHeight = 0;
    if (message != null) {
      message.layout(contentConstraints, parentUsesSize: true);
      messageHeight = message.size.height;
    }

    double actionHeight = 0;
    if (action != null) {
      action.layout(contentConstraints, parentUsesSize: true);
      actionHeight = action.size.height;
    }

    double totalContentHeight =
        messageHeight + (action != null ? 8.0 + actionHeight : 0);
    double maxH = totalContentHeight;
    if (icon != null && icon.size.height > maxH) maxH = icon.size.height;
    if (dismiss != null && dismiss.size.height > maxH)
      maxH = dismiss.size.height;

    size = constraints.constrain(
      Size(constraints.maxWidth, maxH + padding.vertical),
    );

    double currentX = padding.left;
    double topY = padding.top;

    if (icon != null) {
      final pd = icon.parentData as BannerParentData;
      pd.offset = Offset(currentX, topY);
      currentX += icon.size.width + spacing;
    }

    if (message != null) {
      final pd = message.parentData as BannerParentData;
      pd.offset = Offset(currentX, topY);
    }

    if (action != null) {
      final pd = action.parentData as BannerParentData;
      pd.offset = Offset(currentX, topY + messageHeight + 8.0);
      _actionBounds = pd.offset & action.size;
    } else {
      _actionBounds = null;
    }

    if (dismiss != null) {
      final pd = dismiss.parentData as BannerParentData;
      pd.offset = Offset(size.width - padding.right - dismiss.size.width, topY);
      _dismissBounds = pd.offset & dismiss.size;
    } else {
      _dismissBounds = null;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Color bgColor;
    Color borderColor;
    switch (_type) {
      case BannerType.info:
        bgColor = const Color(0xFFE3F2FD);
        borderColor = const Color(0xFF0D47A1);
        break;
      case BannerType.success:
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF1B5E20);
        break;
      case BannerType.warning:
        bgColor = const Color(0xFFFFF3E0);
        borderColor = const Color(0xFFE65100);
        break;
      case BannerType.error:
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFB71C1C);
        break;
    }
    final rect = offset & size;
    context.canvas.drawRect(rect, Paint()..color = bgColor);
    context.canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, 4.0, rect.height),
      Paint()..color = borderColor,
    );
    defaultPaint(context, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      _hitAction = _actionBounds?.contains(position) ?? false;
      _hitDismiss = _dismissBounds?.contains(position) ?? false;
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }
}
