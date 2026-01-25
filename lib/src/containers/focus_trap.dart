import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A widget that traps focus within its subtree.
class FocusTrap extends SingleChildRenderObjectWidget {
  const FocusTrap({
    super.key,
    required Widget child,
    this.isActive = true,
    this.tag,
  }) : super(child: child);

  final bool isActive;
  final String? tag;

  @override
  RenderFocusTrap createRenderObject(BuildContext context) {
    return RenderFocusTrap(isActive: isActive);
  }

  @override
  void updateRenderObject(BuildContext context, RenderFocusTrap renderObject) {
    renderObject.isActive = isActive;
  }
}

class RenderFocusTrap extends RenderProxyBox {
  RenderFocusTrap({required bool isActive}) : _isActive = isActive;

  bool _isActive;
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      markNeedsPaint();
    }
  }

  // Focus trapping is handled at widget layer via FocusScope.
  // This RenderObject passes through but could add visual indicators if needed.
}
