import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import '../foundation/status.dart';
import '../theme/customization.dart';
import '../theme/theme.dart';

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

/// An Accordion widget (list of expandable panels).
class Accordion extends StatefulWidget {
  const Accordion({
    super.key,
    required this.panels,
    this.allowMultiple = false,
    this.onExpansionChanged,
    this.tag,
  });

  final List<AccordionPanel> panels;
  final bool allowMultiple;
  final ValueChanged<int>? onExpansionChanged;
  final String? tag;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = widget.panels.map((p) => p.isExpanded).toList();
  }

  void _togglePanel(int index) {
    setState(() {
      if (widget.allowMultiple) {
        _expandedStates[index] = !_expandedStates[index];
      } else {
        for (int i = 0; i < _expandedStates.length; i++) {
          _expandedStates[i] = (i == index) ? !_expandedStates[i] : false;
        }
      }
    });
    widget.onExpansionChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getAccordion(widget.tag) ??
        AccordionCustomization.simple();

    return _AccordionRenderWidget(
      children: List.generate(widget.panels.length, (index) {
        final panel = widget.panels[index];
        return _AccordionPanelRenderWidget(
          header: panel.header,
          body: panel.body,
          isExpanded: _expandedStates[index],
          onToggle: () => _togglePanel(index),
          customization: customization,
        );
      }),
    );
  }
}

class _AccordionRenderWidget extends MultiChildRenderObjectWidget {
  const _AccordionRenderWidget({required super.children});

  @override
  RenderAccordion createRenderObject(BuildContext context) => RenderAccordion();
}

class AccordionParentData extends ContainerBoxParentData<RenderBox> {}

class RenderAccordion extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AccordionParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AccordionParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AccordionParentData) {
      child.parentData = AccordionParentData();
    }
  }

  @override
  void performLayout() {
    double currentY = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final childParentData = child.parentData! as AccordionParentData;
      childParentData.offset = Offset(0, currentY);
      currentY += child.size.height;
      child = childAfter(child);
    }
    size = constraints.constrain(Size(constraints.maxWidth, currentY));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class _AccordionPanelRenderWidget extends MultiChildRenderObjectWidget {
  _AccordionPanelRenderWidget({
    required Widget header,
    required Widget body,
    required this.isExpanded,
    required this.onToggle,
    required this.customization,
  }) : super(children: [header, if (isExpanded) body]);

  final bool isExpanded;
  final VoidCallback onToggle;
  final AccordionCustomization customization;

  @override
  RenderAccordionPanel createRenderObject(BuildContext context) {
    return RenderAccordionPanel(
      isExpanded: isExpanded,
      onToggle: onToggle,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderAccordionPanel renderObject,
  ) {
    renderObject
      ..isExpanded = isExpanded
      ..onToggle = onToggle
      ..customization = customization;
  }
}

class AccordionPanelParentData extends ContainerBoxParentData<RenderBox> {
  bool isHeader = false;
}

class RenderAccordionPanel extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AccordionPanelParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AccordionPanelParentData> {
  RenderAccordionPanel({
    required bool isExpanded,
    required this.onToggle,
    required AccordionCustomization customization,
  }) : _isExpanded = isExpanded,
       _customization = customization;

  bool _isExpanded;
  bool get isExpanded => _isExpanded;
  set isExpanded(bool value) {
    if (_isExpanded == value) return;
    _isExpanded = value;
    markNeedsLayout();
  }

  VoidCallback onToggle;

  AccordionCustomization _customization;
  AccordionCustomization get customization => _customization;
  set customization(AccordionCustomization value) {
    _customization = value;
    markNeedsPaint();
  }

  bool _hovered = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AccordionPanelParentData) {
      child.parentData = AccordionPanelParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? header = firstChild;
    RenderBox? body = header != null ? childAfter(header) : null;

    if (header != null) {
      final headerPadding =
          customization.headerPadding?.resolve(TextDirection.ltr) ??
          const EdgeInsets.all(16);
      header.layout(constraints.deflate(headerPadding), parentUsesSize: true);
      final headerPd = header.parentData! as AccordionPanelParentData;
      headerPd.isHeader = true;
      headerPd.offset = headerPadding.topLeft;

      double totalHeight = header.size.height + headerPadding.vertical;

      if (isExpanded && body != null) {
        final contentPadding =
            customization.contentPadding?.resolve(TextDirection.ltr) ??
            const EdgeInsets.all(16);
        body.layout(constraints.deflate(contentPadding), parentUsesSize: true);
        final bodyPd = body.parentData! as AccordionPanelParentData;
        bodyPd.isHeader = false;
        bodyPd.offset = Offset(
          contentPadding.left,
          totalHeight + contentPadding.top,
        );
        totalHeight += body.size.height + contentPadding.vertical;
      }

      size = constraints.constrain(Size(constraints.maxWidth, totalHeight));
    } else {
      size = constraints.constrain(Size.zero);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final status = AccordionControlStatus()
      ..expanded = isExpanded ? 1.0 : 0.0
      ..hovered = _hovered ? 1.0 : 0.0
      ..enabled = 1.0;

    RenderBox? header = firstChild;
    if (header != null) {
      final headerPadding =
          customization.headerPadding?.resolve(TextDirection.ltr) ??
          const EdgeInsets.all(16);
      final double headerHeight = header.size.height + headerPadding.vertical;
      final Rect headerRect = offset & Size(size.width, headerHeight);

      // Header background
      final headerDec = customization.decoration(status);
      if (headerDec is BoxDecoration) {
        final Paint paint = Paint()
          ..color = headerDec.color ?? const Color(0xFFFFFFFF);
        context.canvas.drawRect(headerRect, paint);

        // Header Border
        if (headerDec.border != null) {
          headerDec.border!.paint(context.canvas, headerRect);
        }
      }

      // Content background & border
      if (isExpanded) {
        final contentRect =
            (offset + Offset(0, headerHeight)) &
            Size(size.width, size.height - headerHeight);
        if (customization.contentDecoration is BoxDecoration) {
          final contentDec = customization.contentDecoration as BoxDecoration;
          final Paint paint = Paint()
            ..color = contentDec.color ?? const Color(0xFFFAFAFA);
          context.canvas.drawRect(contentRect, paint);
          if (contentDec.border != null) {
            contentDec.border!.paint(context.canvas, contentRect);
          }
        }
      }

      // Default (Headers & Body)
      defaultPaint(context, offset);

      // Chevron (drawn manually or as part of header? Handled in buildChildren if wanted, but here let's draw it manually for fun)
      final textStyle = customization.textStyle(status);
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: isExpanded ? "▲" : "▼", style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        context.canvas,
        offset +
            Offset(
              size.width - headerPadding.right - textPainter.size.width,
              headerPadding.top +
                  (header.size.height - textPainter.size.height) / 2,
            ),
      );
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent) {
      RenderBox? header = firstChild;
      if (header != null) {
        final headerPadding =
            customization.headerPadding?.resolve(TextDirection.ltr) ??
            const EdgeInsets.all(16);
        final Rect headerRect =
            Offset.zero &
            Size(size.width, header.size.height + headerPadding.vertical);
        final bool isHovering = headerRect.contains(event.localPosition);
        if (_hovered != isHovering) {
          _hovered = isHovering;
          markNeedsPaint();
        }
      }
    } else if (event is PointerDownEvent) {
      RenderBox? header = firstChild;
      if (header != null) {
        final headerPadding =
            customization.headerPadding?.resolve(TextDirection.ltr) ??
            const EdgeInsets.all(16);
        final Rect headerRect =
            Offset.zero &
            Size(size.width, header.size.height + headerPadding.vertical);
        if (headerRect.contains(event.localPosition)) {
          onToggle();
        }
      }
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
