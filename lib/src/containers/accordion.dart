import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// A panel in an Accordion.
class AccordionPanel {
  const AccordionPanel({
    required this.header,
    required this.body,
    this.isExpanded = false,
  });

  final Widget header;
  final Widget body;
  final bool isExpanded;
}

enum AccordionSlotType { header, body }

class AccordionParentData extends ContainerBoxParentData<RenderBox> {
  AccordionSlotType? slot;
  int? index;
}

class AccordionSlot extends ParentDataWidget<AccordionParentData> {
  const AccordionSlot({
    super.key,
    required this.slot,
    required this.index,
    required super.child,
  });

  final AccordionSlotType slot;
  final int index;

  @override
  void applyParentData(RenderObject renderObject) {
    if (renderObject.parentData is! AccordionParentData) {
      renderObject.parentData = AccordionParentData();
    }
    final parentData = renderObject.parentData as AccordionParentData;
    bool needsLayout = false;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      needsLayout = true;
    }
    if (parentData.index != index) {
      parentData.index = index;
      needsLayout = true;
    }
    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Accordion;
}

/// An Accordion widget (list of expandable panels).
class Accordion extends MultiChildRenderObjectWidget {
  Accordion({
    super.key,
    required List<AccordionPanel> panels,
    this.allowMultiple = false,
    this.onExpansionChanged,
    this.tag,
  }) : super(children: _buildChildren(panels));

  final bool allowMultiple;
  final ValueChanged<int>? onExpansionChanged;
  final String? tag;

  static List<Widget> _buildChildren(List<AccordionPanel> panels) {
    final children = <Widget>[];
    for (int i = 0; i < panels.length; i++) {
      children.add(
        AccordionSlot(
          slot: AccordionSlotType.header,
          index: i,
          child: panels[i].header,
        ),
      );
      children.add(
        AccordionSlot(
          slot: AccordionSlotType.body,
          index: i,
          child: panels[i].body,
        ),
      );
    }
    return children;
  }

  @override
  RenderAccordion createRenderObject(BuildContext context) {
    return RenderAccordion(
      allowMultiple: allowMultiple,
      onExpansionChanged: onExpansionChanged,
      tag: tag,
      customization: CustomizedTheme.of(context).getAccordion(tag),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAccordion renderObject) {
    renderObject
      ..allowMultiple = allowMultiple
      ..onExpansionChanged = onExpansionChanged
      ..tag = tag
      ..customization = CustomizedTheme.of(context).getAccordion(tag);
  }
}

class RenderAccordion extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AccordionParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AccordionParentData> {
  RenderAccordion({
    bool allowMultiple = false,
    ValueChanged<int>? onExpansionChanged,
    String? tag,
    AccordionCustomization? customization,
  }) : _allowMultiple = allowMultiple,
       _onExpansionChanged = onExpansionChanged,
       _tag = tag,
       _resolvedCustomization = customization {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  bool _allowMultiple;
  set allowMultiple(bool value) {
    if (_allowMultiple != value) {
      _allowMultiple = value;
    }
  }

  ValueChanged<int>? _onExpansionChanged;
  set onExpansionChanged(ValueChanged<int>? value) {
    _onExpansionChanged = value;
  }

  String? _tag;
  set tag(String? value) {
    if (_tag != value) {
      _tag = value;
      markNeedsPaint();
    }
  }

  AccordionCustomization? _resolvedCustomization;
  set customization(AccordionCustomization? value) {
    if (_resolvedCustomization != value) {
      _resolvedCustomization = value;
      markNeedsLayout();
    }
  }

  // State
  final Map<int, bool> _expandedState = {};
  final Map<int, bool> _hoveredState = {};

  late TapGestureRecognizer _tap;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_lastHitIndex != null) {
      _toggle(_lastHitIndex!);
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    final index = _hitTestHeader(local);
    bool changed = false;
    // Clear old hovers
    for (var k in _hoveredState.keys) {
      if (_hoveredState[k] == true && k != index) {
        _hoveredState[k] = false;
        changed = true;
      }
    }
    if (index != null) {
      if (_hoveredState[index] != true) {
        _hoveredState[index] = true;
        changed = true;
      }
    }
    if (changed) markNeedsPaint();
  }

  void _toggle(int index) {
    final current = _expandedState[index] ?? false;
    if (_allowMultiple) {
      _expandedState[index] = !current;
    } else {
      // Collapse others
      _expandedState.clear();
      if (!current) {
        _expandedState[index] = true;
      }
    }
    _onExpansionChanged?.call(index);
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AccordionParentData) {
      child.parentData = AccordionParentData();
    }
  }

  int? _lastHitIndex;

  @override
  void performLayout() {
    final customization =
        _resolvedCustomization ?? AccordionCustomization.simple();

    double currentY = 0;
    double maxWidth = constraints.maxWidth;

    final Map<int, RenderBox> headers = {};
    final Map<int, RenderBox> bodies = {};
    int maxIndex = -1;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as AccordionParentData;
      if (pd.index != null) {
        if (pd.slot == AccordionSlotType.header) headers[pd.index!] = child;
        if (pd.slot == AccordionSlotType.body) bodies[pd.index!] = child;
        if (pd.index! > maxIndex) maxIndex = pd.index!;
      }
      child = childAfter(child);
    }

    final headerPadding =
        customization.headerPadding?.resolve(TextDirection.ltr) ??
        const EdgeInsets.all(16);
    final contentPadding =
        customization.contentPadding?.resolve(TextDirection.ltr) ??
        const EdgeInsets.all(16);

    for (int i = 0; i <= maxIndex; i++) {
      final header = headers[i];
      final body = bodies[i];

      if (header != null) {
        // Layout header
        header.layout(
          constraints.deflate(headerPadding).copyWith(minHeight: 0),
          parentUsesSize: true,
        );
        final pd = header.parentData as AccordionParentData;
        pd.offset = Offset(headerPadding.left, currentY + headerPadding.top);

        final headerHeight = header.size.height + headerPadding.vertical;
        currentY += headerHeight;

        bool isExpanded = _expandedState[i] ?? false;

        if (isExpanded && body != null) {
          // Layout body
          body.layout(
            constraints.deflate(contentPadding).copyWith(minHeight: 0),
            parentUsesSize: true,
          );
          final bpd = body.parentData as AccordionParentData;
          bpd.offset = Offset(
            contentPadding.left,
            currentY + contentPadding.top,
          );
          currentY += body.size.height + contentPadding.vertical;
        } else if (body != null) {
          // Collapse
          body.layout(BoxConstraints.tight(Size.zero));
        }
      }
    }

    size = constraints.constrain(Size(maxWidth, currentY));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final customization =
        _resolvedCustomization ?? AccordionCustomization.simple();

    final Map<int, RenderBox> headers = {};
    final Map<int, RenderBox> bodies = {};
    int maxIndex = -1;
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as AccordionParentData;
      if (pd.index != null) {
        if (pd.slot == AccordionSlotType.header) headers[pd.index!] = child;
        if (pd.slot == AccordionSlotType.body) bodies[pd.index!] = child;
        if (pd.index! > maxIndex) maxIndex = pd.index!;
      }
      child = childAfter(child);
    }

    final headerPadding =
        customization.headerPadding?.resolve(TextDirection.ltr) ??
        const EdgeInsets.all(16);

    for (int i = 0; i <= maxIndex; i++) {
      final header = headers[i];
      if (header != null) {
        bool isExpanded = _expandedState[i] ?? false;
        bool isHovered = _hoveredState[i] ?? false;

        final status = AccordionControlStatus()
          ..expanded = isExpanded ? 1.0 : 0.0
          ..hovered = isHovered ? 1.0 : 0.0
          ..enabled = 1.0;

        final pd = header.parentData as AccordionParentData;

        final headerTop = pd.offset.dy - headerPadding.top;
        final headerHeight = header.size.height + headerPadding.vertical;
        final headerRect = Rect.fromLTWH(
          offset.dx,
          offset.dy + headerTop,
          size.width,
          headerHeight,
        );

        // Paint Header Decoration
        final headerDec = customization.decoration(status);
        if (headerDec is BoxDecoration) {
          final Paint paint = Paint()
            ..color = headerDec.color ?? const Color(0xFFFFFFFF);
          context.canvas.drawRect(headerRect, paint);
          if (headerDec.border != null) {
            headerDec.border!.paint(context.canvas, headerRect);
          }
        }

        // Paint Chevron
        final textStyle = customization.textStyle(status);
        final TextSpan span = TextSpan(
          text: isExpanded ? "▲" : "▼",
          style: textStyle,
        );
        final TextPainter tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          context.canvas,
          Offset(
            headerRect.right - headerPadding.right - tp.width,
            headerRect.top + (headerRect.height - tp.height) / 2,
          ),
        );

        // Paint Header Content
        context.paintChild(header, pd.offset + offset);

        // Paint Body Content
        final body = bodies[i];
        if (isExpanded && body != null) {
          final bpd = body.parentData as AccordionParentData;

          // Content Background
          final contentTop = headerRect.bottom;
          final contentPadding =
              customization.contentPadding?.resolve(TextDirection.ltr) ??
              const EdgeInsets.all(16);
          final contentHeight = body.size.height + contentPadding.vertical;
          final contentRect = Rect.fromLTWH(
            offset.dx,
            contentTop,
            size.width,
            contentHeight,
          );

          if (customization.contentDecoration is BoxDecoration) {
            final contentDec = customization.contentDecoration as BoxDecoration;
            final Paint paint = Paint()
              ..color = contentDec.color ?? const Color(0xFFFAFAFA);
            context.canvas.drawRect(contentRect, paint);
            if (contentDec.border != null) {
              contentDec.border!.paint(context.canvas, contentRect);
            }
          }

          context.paintChild(body, bpd.offset + offset);
        }
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
      final local = event.localPosition;
      _lastHitIndex = _hitTestHeader(local);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }

  int? _hitTestHeader(Offset local) {
    final customization =
        _resolvedCustomization ?? AccordionCustomization.simple();
    final headerPadding =
        customization.headerPadding?.resolve(TextDirection.ltr) ??
        const EdgeInsets.all(16);

    final Map<int, RenderBox> headers = {};
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as AccordionParentData;
      if (pd.index != null && pd.slot == AccordionSlotType.header) {
        headers[pd.index!] = child;
      }
      child = childAfter(child);
    }

    for (var entry in headers.entries) {
      final i = entry.key;
      final header = entry.value;
      final pd = header.parentData as AccordionParentData;

      final headerTop = pd.offset.dy - headerPadding.top;
      final headerHeight = header.size.height + headerPadding.vertical;
      final rect = Rect.fromLTWH(0, headerTop, size.width, headerHeight);

      if (rect.contains(local)) return i;
    }
    return null;
  }
}
