import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that annotates the widget tree with a description of the meaning of the widgets.
class Semantics extends SingleChildRenderObjectWidget {
  const Semantics({
    super.key,
    this.container = false,
    this.explicitChildNodes = false,
    this.excludeSemantics = false,
    this.label,
    this.value,
    this.increasedValue,
    this.decreasedValue,
    this.hint,
    this.onTap,
    this.onLongPress,
    this.textDirection,
    super.child,
  });

  final bool container;
  final bool explicitChildNodes;
  final bool excludeSemantics;
  final String? label;
  final String? value;
  final String? increasedValue;
  final String? decreasedValue;
  final String? hint;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final TextDirection? textDirection;

  @override
  RenderSemanticsAnnotations createRenderObject(BuildContext context) {
    return RenderSemanticsAnnotations(
      container: container,
      explicitChildNodes: explicitChildNodes,
      excludeSemantics: excludeSemantics,
      properties: SemanticsProperties(
        label: label,
        value: value,
        increasedValue: increasedValue,
        decreasedValue: decreasedValue,
        hint: hint,
        onTap: onTap,
        onLongPress: onLongPress,
        textDirection: textDirection ?? Directionality.maybeOf(context),
      ),
      textDirection: textDirection ?? Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSemanticsAnnotations renderObject,
  ) {
    renderObject
      ..container = container
      ..explicitChildNodes = explicitChildNodes
      ..excludeSemantics = excludeSemantics
      ..properties = SemanticsProperties(
        label: label,
        value: value,
        increasedValue: increasedValue,
        decreasedValue: decreasedValue,
        hint: hint,
        onTap: onTap,
        onLongPress: onLongPress,
        textDirection: textDirection ?? Directionality.maybeOf(context),
      )
      ..textDirection = textDirection ?? Directionality.maybeOf(context);
  }
}

/// A widget that makes its child invisible to hit testing.
class IgnorePointer extends SingleChildRenderObjectWidget {
  const IgnorePointer({
    super.key,
    this.ignoring = true,
    this.ignoringSemantics,
    super.child,
  });

  final bool ignoring;
  final bool? ignoringSemantics;

  @override
  RenderIgnorePointer createRenderObject(BuildContext context) {
    return RenderIgnorePointer(
      ignoring: ignoring,
      ignoringSemantics: ignoringSemantics,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderIgnorePointer renderObject,
  ) {
    renderObject
      ..ignoring = ignoring
      ..ignoringSemantics = ignoringSemantics;
  }
}

/// A widget that absorbs pointers during hit testing.
class AbsorbPointer extends SingleChildRenderObjectWidget {
  const AbsorbPointer({
    super.key,
    this.absorbing = true,
    this.ignoringSemantics,
    super.child,
  });

  final bool absorbing;
  final bool? ignoringSemantics;

  @override
  RenderAbsorbPointer createRenderObject(BuildContext context) {
    return RenderAbsorbPointer(
      absorbing: absorbing,
      ignoringSemantics: ignoringSemantics,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAbsorbPointer renderObject,
  ) {
    renderObject
      ..absorbing = absorbing
      ..ignoringSemantics = ignoringSemantics;
  }
}

/// A widget that holds opaque meta data.
class MetaData extends SingleChildRenderObjectWidget {
  const MetaData({
    super.key,
    this.metaData,
    this.behavior = HitTestBehavior.deferToChild,
    super.child,
  });

  final dynamic metaData;
  final HitTestBehavior behavior;

  @override
  RenderMetaData createRenderObject(BuildContext context) {
    return RenderMetaData(metaData: metaData, behavior: behavior);
  }

  @override
  void updateRenderObject(BuildContext context, RenderMetaData renderObject) {
    renderObject
      ..metaData = metaData
      ..behavior = behavior;
  }
}

/// A widget that manages focus using lowest-level RenderObject APIs.
class FocusScope extends SingleChildRenderObjectWidget {
  const FocusScope({super.key, this.node, super.child, this.autofocus = false});

  final FocusScopeNode? node;
  final bool autofocus;

  @override
  RenderFocusScope createRenderObject(BuildContext context) {
    return RenderFocusScope(
      node: node ?? FocusScopeNode(),
      autofocus: autofocus,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFocusScope renderObject) {
    renderObject.autofocus = autofocus;
    if (node != null && renderObject.node != node) {
      renderObject.node = node!;
    }
  }
}

class RenderFocusScope extends RenderProxyBox {
  RenderFocusScope({required FocusScopeNode node, bool autofocus = false})
    : _node = node,
      _autofocus = autofocus;

  FocusScopeNode _node;
  FocusScopeNode get node => _node;
  set node(FocusScopeNode value) {
    if (_node == value) return;
    _node = value;
  }

  bool _autofocus;
  bool get autofocus => _autofocus;
  set autofocus(bool value) {
    if (_autofocus == value) return;
    _autofocus = value;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_autofocus) {
      _node.requestFocus();
    }
  }

  // Note: Standard Focus management in Flutter is more complex,
  // this is a simplified version for compliance.
}
