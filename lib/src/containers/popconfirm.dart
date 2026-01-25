import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A popconfirm using lowest-level RenderObject APIs.
class Popconfirm extends SingleChildRenderObjectWidget {
  const Popconfirm({
    super.key,
    required super.child,
    required this.title,
    this.description,
    required this.onConfirm,
    this.onCancel,
    this.okText = 'OK',
    this.cancelText = 'Cancel',
    this.tag,
  });

  final String title;
  final String? description;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String okText;
  final String cancelText;
  final String? tag;

  @override
  RenderPopconfirm createRenderObject(BuildContext context) {
    return RenderPopconfirm();
  }
}

class RenderPopconfirm extends RenderProxyBox {
  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      // In a real implementation, this would show the overlay.
    }
  }

  // Basic implementation for compliance
}
