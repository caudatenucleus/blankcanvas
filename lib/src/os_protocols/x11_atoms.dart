import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Registry for X11 Atoms (unique protocol identifiers).
class X11AtomRegistry {
  static final X11AtomRegistry instance = X11AtomRegistry._();
  X11AtomRegistry._();

  final Map<String, int> _atoms = {};
  int _nextId = 1;

  int internAtom(String name) {
    if (_atoms.containsKey(name)) {
      return _atoms[name]!;
    }
    final id = _nextId++;
    _atoms[name] = id;
    return id;
  }

  String? getAtomName(int id) {
    for (final entry in _atoms.entries) {
      if (entry.value == id) return entry.key;
    }
    return null;
  }
}

/// Helper for accessing the registry in the tree (simulation).
class X11Scope extends InheritedWidget {
  const X11Scope({super.key, required super.child, required this.registry});

  final X11AtomRegistry registry;

  static X11AtomRegistry of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<X11Scope>()?.registry ??
        X11AtomRegistry.instance;
  }

  @override
  bool updateShouldNotify(X11Scope oldWidget) => registry != oldWidget.registry;
}

/// Represents a property on an X11 window.
class X11WindowProperty {
  const X11WindowProperty({
    required this.name,
    required this.type,
    required this.format,
    required this.data,
  });

  final String name;
  final String type; // Atom name for type
  final int format; // 8, 16, or 32
  final Uint8List data;

  @override
  String toString() =>
      'X11Prop($name, type=$type, fmt=$format, len=${data.length})';
}

/// Logic for extended input device handling (e.g. multi-pointer).
class X11InputExtension {
  const X11InputExtension();

  // Simulation of listing devices
  List<String> listInputDevices() {
    return ['Virtual Core Pointer', 'Virtual Core Keyboard', 'Stylus'];
  }
}

/// A widget that simulates capturing raw X11-like events using lowest-level RenderObject APIs.
class X11EventCapture extends SingleChildRenderObjectWidget {
  const X11EventCapture({super.key, required super.child, this.onEvent});

  final ValueChanged<String>? onEvent;

  @override
  RenderX11EventCapture createRenderObject(BuildContext context) {
    return RenderX11EventCapture(onEvent: onEvent);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderX11EventCapture renderObject,
  ) {
    renderObject.onEvent = onEvent;
  }
}

class RenderX11EventCapture extends RenderProxyBox {
  RenderX11EventCapture({this.onEvent});

  ValueChanged<String>? onEvent;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      onEvent?.call('ButtonPress: ${event.position}');
    } else if (event is PointerUpEvent) {
      onEvent?.call('ButtonRelease: ${event.position}');
    } else if (event is PointerMoveEvent) {
      onEvent?.call('MotionNotify: ${event.position}');
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

/// Simulation of X11 Shared Memory Extension.
class X11ShmExtension {
  // Stub for creating integer keys for shared memory segments
  int createSegment(int size) {
    return DateTime.now().microsecondsSinceEpoch;
  }

  void attach(int shmId) {
    // Stub
  }

  void detach(int shmId) {
    // Stub
  }
}

/// Data class representing an X11 RandR screen/output.
class X11RandrScreen {
  const X11RandrScreen({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.rate,
    required this.x,
    required this.y,
  });

  final int id;
  final String name;
  final int width;
  final int height;
  final double rate; // Refresh rate in Hz
  final int x;
  final int y;

  @override
  String toString() => 'Screen($name, ${width}x$height@${rate}Hz, +$x+$y)';
}
