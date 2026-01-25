import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

// --------------------------------------------------------------------------
// Input Routing & Hierarchy
// --------------------------------------------------------------------------

/// Renders a routing node for hardware-to-window event mapping.
class InputEventRoutingNode extends SingleChildRenderObjectWidget {
  const InputEventRoutingNode({
    super.key,
    required super.child,
    required this.windowId,
    this.enabled = true,
  });

  final int windowId;
  final bool enabled;

  @override
  RenderInputEventRouting createRenderObject(BuildContext context) {
    return RenderInputEventRouting(windowId: windowId, enabled: enabled);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderInputEventRouting renderObject,
  ) {
    renderObject
      ..windowId = windowId
      ..enabled = enabled;
  }
}

class RenderInputEventRouting extends RenderProxyBox {
  RenderInputEventRouting({
    required int windowId,
    bool enabled = true,
    RenderBox? child,
  }) : _windowId = windowId,
       _enabled = enabled,
       super(child);

  int _windowId;
  set windowId(int val) => _windowId = val;

  bool _enabled;
  set enabled(bool val) => _enabled = val;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!_enabled) return false;
    // We can intercept here or tag the result with window ID metadata
    final hit = super.hitTest(result, position: position);
    if (hit) {
      // In a real system, we'd append a WindowHitEntry(windowId)
    }
    return hit;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('windowId', _windowId));
    properties.add(DiagnosticsProperty<bool>('enabled', _enabled));
  }
}

/// Simulation of native-to-hybrid view hierarchy synchronization.
class PlatformViewHierarchySync {
  final Map<int, int> viewMap = {}; // Flutter ID -> Native ID

  void registerView(int flutterId, int nativeId) {
    viewMap[flutterId] = nativeId;
  }

  void unregisterView(int flutterId) {
    viewMap.remove(flutterId);
  }
}

// --------------------------------------------------------------------------
// Data Exchange
// --------------------------------------------------------------------------

/// Inter-process data exchange node.
class ClipboardAtom {
  const ClipboardAtom({required this.mimeType, required this.data});

  final String mimeType;
  final List<int> data;
}

/// Registry for drag & drop mime types.
class DragDropMimeRegistry {
  static final DragDropMimeRegistry instance = DragDropMimeRegistry._();
  DragDropMimeRegistry._();

  final Map<String, String> _extensions = {};

  void register(String mime, String extension) {
    _extensions[mime] = extension;
  }

  String? getExtension(String mime) => _extensions[mime];
}

// --------------------------------------------------------------------------
// Window Management
// --------------------------------------------------------------------------

/// Logic for window chrome (client-side vs server-side).
class WindowDecorationLogic {
  const WindowDecorationLogic({
    this.hasTitleBar = true,
    this.hasBorders = true,
    this.isResizable = true,
    this.titleBarHeight = 24.0,
  });

  final bool hasTitleBar;
  final bool hasBorders;
  final bool isResizable;
  final double titleBarHeight;

  EdgeInsets get padding => EdgeInsets.only(
    top: hasTitleBar ? titleBarHeight : (hasBorders ? 1.0 : 0.0),
    left: hasBorders ? 1.0 : 0.0,
    right: hasBorders ? 1.0 : 0.0,
    bottom: hasBorders ? 1.0 : 0.0,
  );
}

/// GPU-composited alpha hole implementation.
class WindowTransparencyMask extends SingleChildRenderObjectWidget {
  const WindowTransparencyMask({
    super.key,
    required super.child,
    this.transparent = false,
  });

  final bool transparent;

  @override
  RenderTransparencyMask createRenderObject(BuildContext context) {
    return RenderTransparencyMask(transparent: transparent);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTransparencyMask renderObject,
  ) {
    renderObject.transparent = transparent;
  }
}

class RenderTransparencyMask extends RenderProxyBox {
  RenderTransparencyMask({RenderBox? child, bool transparent = false})
    : _transparent = transparent,
      super(child);

  bool _transparent;
  set transparent(bool val) {
    if (_transparent != val) {
      _transparent = val;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_transparent) {
      // Simulate alpha hole: blend mode dstOut or similar if we strictly needed to punch holes.
      // Here just composite layer or opacity.
      // For "GPU hole", we might need a specialized separate layer.
      // We will use a savelayer + blendmode for simulation.
      context.canvas.saveLayer(offset & size, Paint());
      super.paint(context, offset);
      context.canvas.restore();
    } else {
      super.paint(context, offset);
    }
  }
}

/// Global window stacking order registry.
class WindowZOrderManager {
  final List<int> _stackingOrder = []; // Window IDs, bottom to top

  void raise(int windowId) {
    _stackingOrder.remove(windowId);
    _stackingOrder.add(windowId);
  }

  void lower(int windowId) {
    _stackingOrder.remove(windowId);
    _stackingOrder.insert(0, windowId);
  }

  List<int> get snapshot => List.unmodifiable(_stackingOrder);
}

/// State container for taskbar items.
class WindowTaskbarState {
  WindowTaskbarState({
    required this.windowId,
    required this.title,
    this.isMinimized = false,
    this.isMaximized = false,
  });

  final int windowId;
  String title;
  bool isMinimized;
  bool isMaximized;
}
