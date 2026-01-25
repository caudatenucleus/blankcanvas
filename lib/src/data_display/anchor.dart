import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// An anchor link that scrolls to a target section.
class Anchor extends SingleChildRenderObjectWidget {
  const Anchor({
    super.key,
    required this.controller,
    required this.sectionId,
    required Widget child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.tag,
  }) : super(child: child);

  final ScrollController controller;
  final String sectionId;
  final Duration duration;
  final Curve curve;
  final String? tag;

  @override
  RenderAnchor createRenderObject(BuildContext context) {
    return RenderAnchor(sectionId: sectionId, duration: duration, curve: curve);
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnchor renderObject) {
    renderObject
      ..sectionId = sectionId
      ..duration = duration
      ..curve = curve;
  }
}

class RenderAnchor extends RenderProxyBox {
  RenderAnchor({
    required String sectionId,
    required Duration duration,
    required Curve curve,
  }) : _sectionId = sectionId,
       _duration = duration,
       _curve = curve {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  String _sectionId;
  set sectionId(String value) {
    _sectionId = value;
  }

  Duration _duration;
  set duration(Duration value) {
    _duration = value;
  }

  Curve _curve;
  set curve(Curve value) {
    _curve = value;
  }

  late TapGestureRecognizer _tap;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  void _handleTap() {
    AnchorRegistry.scrollTo(_sectionId, duration: _duration, curve: _curve);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }
}

/// A target for an Anchor link.
class AnchorTarget extends SingleChildRenderObjectWidget {
  const AnchorTarget({super.key, required this.id, required Widget child})
    : super(child: child);

  final String id;

  @override
  RenderAnchorTarget createRenderObject(BuildContext context) {
    return RenderAnchorTarget(id: id, context: context);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAnchorTarget renderObject,
  ) {
    renderObject.id = id;
  }
}

class RenderAnchorTarget extends RenderProxyBox {
  RenderAnchorTarget({required String id, required BuildContext context})
    : _id = id,
      _context = context;

  String _id;
  set id(String value) {
    if (_id != value) {
      AnchorRegistry.unregister(_id);
      _id = value;
      AnchorRegistry.register(_id, _context);
    }
  }

  final BuildContext _context;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    AnchorRegistry.register(_id, _context);
  }

  @override
  void detach() {
    AnchorRegistry.unregister(_id);
    super.detach();
  }
}

/// Registry to map IDs to BuildContexts for scrolling.
class AnchorRegistry {
  static final Map<String, BuildContext> _targets = {};

  static void register(String id, BuildContext context) {
    _targets[id] = context;
  }

  static void unregister(String id) {
    _targets.remove(id);
  }

  static Future<void> scrollTo(
    String id, {
    Duration? duration,
    Curve? curve,
  }) async {
    final context = _targets[id];
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: curve ?? Curves.easeInOut,
      );
    }
  }
}
