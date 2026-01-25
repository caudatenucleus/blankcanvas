import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;

enum ToastSlotType { message, action }

class ToastParentData extends ContainerBoxParentData<RenderBox> {
  ToastSlotType? slot;
}

class ToastSlot extends ParentDataWidget<ToastParentData> {
  const ToastSlot({super.key, required this.slot, required super.child});
  final ToastSlotType slot;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! ToastParentData) {
      renderObject.parentData = ToastParentData();
    }
    final parentData = renderObject.parentData as ToastParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Toast;
}

/// A notification toast message using lowest-level RenderObject APIs.
class Toast extends MultiChildRenderObjectWidget {
  Toast({
    super.key,
    required String message,
    String? action,
    this.onAction,
    this.duration = const Duration(seconds: 4),
    this.tag,
  }) : super(children: _buildChildren(message, action));

  final VoidCallback? onAction;
  final Duration duration;
  final String? tag;

  static List<Widget> _buildChildren(String message, String? action) {
    var children = <Widget>[
      ToastSlot(
        slot: ToastSlotType.message,
        child: ParagraphPrimitive(
          text: TextSpan(
            text: message,
            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
          ),
        ),
      ),
    ];
    if (action != null) {
      children.add(
        ToastSlot(
          slot: ToastSlotType.action,
          child: ParagraphPrimitive(
            text: TextSpan(
              text: action,
              style: const TextStyle(
                color: Color(0xFF64B5F6),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return children;
  }

  @override
  RenderToast createRenderObject(BuildContext context) {
    return RenderToast(onAction: onAction);
  }

  @override
  void updateRenderObject(BuildContext context, RenderToast renderObject) {
    renderObject.onAction = onAction;
  }
}

class RenderToast extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ToastParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ToastParentData> {
  RenderToast({VoidCallback? onAction}) : _onAction = onAction {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  VoidCallback? _onAction;
  set onAction(VoidCallback? value) {
    _onAction = value;
  }

  late TapGestureRecognizer _tap;
  Rect? _actionBounds;
  bool _hitAction = false;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_onAction != null && _hitAction) {
      _onAction!();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ToastParentData) {
      child.parentData = ToastParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? message;
    RenderBox? action;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as ToastParentData;
      if (pd.slot == ToastSlotType.message) message = child;
      if (pd.slot == ToastSlotType.action) action = child;
      child = childAfter(child);
    }

    const horizontalPadding = 48.0;
    const verticalPadding = 24.0;
    final contentConstraint = constraints.loosen().deflate(
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    double messageWidth = 0;
    double actionWidth = 0;
    double maxHeight = 0;

    if (action != null) {
      action.layout(contentConstraint, parentUsesSize: true);
      actionWidth = action.size.width;
      maxHeight = action.size.height;
    }

    if (message != null) {
      final msgMaxWidth =
          (contentConstraint.maxWidth -
                  (actionWidth > 0 ? actionWidth + 16 : 0))
              .clamp(0.0, double.infinity);
      message.layout(
        contentConstraint.copyWith(maxWidth: msgMaxWidth),
        parentUsesSize: true,
      );
      messageWidth = message.size.width;
      maxHeight = (message.size.height > maxHeight)
          ? message.size.height
          : maxHeight;
    }

    final width =
        messageWidth +
        (actionWidth > 0 ? actionWidth + 16 : 0) +
        horizontalPadding;
    final height = maxHeight + verticalPadding;
    size = constraints.constrain(Size(width, height));

    double startX = 24.0;
    double centerY = height / 2.0;

    if (message != null) {
      final pd = message.parentData as ToastParentData;
      pd.offset = Offset(startX, centerY - message.size.height / 2);
    }

    if (action != null) {
      final pd = action.parentData as ToastParentData;
      double actionX = startX + messageWidth + 16.0;
      pd.offset = Offset(actionX, centerY - action.size.height / 2);
      _actionBounds = (pd.offset & action.size);
    } else {
      _actionBounds = null;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final rect = offset & size;
    final paint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;
    context.canvas.drawShadow(
      Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4))),
      const Color(0x40000000),
      4.0,
      true,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );
    defaultPaint(context, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      _hitAction = _actionBounds?.contains(position) ?? false;
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

class ToastManager {
  static void show(
    BuildContext context, {
    required String message,
    String? action,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final OverlayState overlay = Overlay.of(context);
    late OverlayEntry entry;
    Timer? timer;
    void dismiss() {
      if (timer?.isActive ?? false) timer?.cancel();
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (context) {
        return layout.Align(
          alignment: Alignment.bottomCenter,
          child: layout.Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Toast(
              message: message,
              action: action,
              onAction: () {
                onAction?.call();
                dismiss();
              },
              duration: duration,
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
    timer = Timer(duration, dismiss);
  }
}
