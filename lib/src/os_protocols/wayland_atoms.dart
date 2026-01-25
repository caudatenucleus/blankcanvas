import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Represents a dirty region update for a surface.
class WaylandSurfaceDamage {
  const WaylandSurfaceDamage(this.rect);
  final Rect rect;

  @override
  String toString() =>
      'Damage(${rect.left}, ${rect.top}, ${rect.width}x${rect.height})';
}

/// Control logic for subsurfaces (relative stacking).
class WaylandSubsurfaceControl {
  const WaylandSubsurfaceControl({
    required this.parentId,
    required this.surfaceId,
    required this.x,
    required this.y,
    this.zOrder = 0, // >0 above, <0 below parent
  });

  final int parentId;
  final int surfaceId;
  final double x;
  final double y;
  final int zOrder;
}

/// Manager for shared memory pixel buffer pools.
class WaylandShmPool {
  WaylandShmPool(this.fd, this.size);
  final int fd;
  final int size;

  final Map<int, Object> _buffers = {}; // offset -> buffer

  void createBuffer(int offset, int width, int height, int stride, int format) {
    _buffers[offset] = {'w': width, 'h': height};
  }
}

/// Focus node extension for identity-aware input routing.
class WaylandKeyboardFocus extends FocusNode {
  WaylandKeyboardFocus({super.debugLabel, this.surfaceId});
  final int? surfaceId;
}

/// Constraint logic for pointer locking/confining.
class WaylandPointerConstraint extends SingleChildRenderObjectWidget {
  const WaylandPointerConstraint({
    super.key,
    required super.child,
    this.locked = false,
    this.confinedRegion,
  });

  final bool locked;
  final Rect? confinedRegion;

  @override
  RenderWaylandPointerConstraint createRenderObject(BuildContext context) {
    return RenderWaylandPointerConstraint(
      locked: locked,
      confinedRegion: confinedRegion,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWaylandPointerConstraint renderObject,
  ) {
    renderObject
      ..locked = locked
      ..confinedRegion = confinedRegion;
  }
}

class RenderWaylandPointerConstraint extends RenderProxyBox {
  RenderWaylandPointerConstraint({
    RenderBox? child,
    bool locked = false,
    Rect? confinedRegion,
  }) : _locked = locked,
       _confinedRegion = confinedRegion,
       super(child);

  bool _locked;
  set locked(bool val) {
    if (_locked != val) {
      _locked = val;
    }
  }

  Rect? _confinedRegion;
  set confinedRegion(Rect? val) {
    if (_confinedRegion != val) {
      _confinedRegion = val;
    }
  }
}

/// Output mode (resolution/refresh rate).
class WaylandOutputMode {
  const WaylandOutputMode({
    required this.width,
    required this.height,
    required this.refreshRate, // mHz
    this.preferred = false,
  });

  final int width;
  final int height;
  final int refreshRate;
  final bool preferred;

  @override
  String toString() =>
      '${width}x$height @ ${refreshRate / 1000}Hz ${preferred ? '(pref)' : ''}';
}
