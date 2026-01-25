import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';

/// A widget to display when no data is available using lowest-level RenderObject APIs.
class EmptyState extends MultiChildRenderObjectWidget {
  EmptyState({
    super.key,
    this.image,
    required this.title,
    this.description,
    this.action,
    this.tag,
  }) : super(children: _buildChildren(image, title, description, action));

  final Widget? image;
  final String title;
  final String? description;
  final Widget? action;
  final String? tag;

  static List<Widget> _buildChildren(
    Widget? image,
    String title,
    String? description,
    Widget? action,
  ) {
    final list = <Widget>[];
    if (image != null) list.add(image);

    list.add(
      ParagraphPrimitive(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );

    if (description != null) {
      list.add(
        ParagraphPrimitive(
          text: TextSpan(
            text: description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ),
      );
    }

    if (action != null) list.add(action);

    return list;
  }

  @override
  RenderEmptyState createRenderObject(BuildContext context) {
    return RenderEmptyState(
      paramHasImage: image != null,
      paramHasDescription: description != null,
      paramHasAction: action != null,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderEmptyState renderObject) {
    renderObject
      ..hasImage = image != null
      ..hasDescription = description != null
      ..hasAction = action != null;
  }
}

class RenderEmptyState extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {
  RenderEmptyState({
    required bool paramHasImage,
    required bool paramHasDescription,
    required bool paramHasAction,
  }) : _hasImage = paramHasImage,
       _hasDescription = paramHasDescription,
       _hasAction = paramHasAction;

  bool _hasImage;
  set hasImage(bool v) {
    if (_hasImage != v) {
      _hasImage = v;
      markNeedsLayout();
    }
  }

  bool _hasDescription;
  set hasDescription(bool v) {
    if (_hasDescription != v) {
      _hasDescription = v;
      markNeedsLayout();
    }
  }

  bool _hasAction;
  set hasAction(bool v) {
    if (_hasAction != v) {
      _hasAction = v;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  @override
  void performLayout() {
    double width = constraints.maxWidth;
    double y = 0.0;
    RenderBox? child = firstChild;

    void layoutChild(RenderBox c, double topGap) {
      c.layout(constraints.loosen(), parentUsesSize: true);
      final pd = c.parentData as FlexParentData;
      pd.offset = Offset((width - c.size.width) / 2, y + topGap);
      y += topGap + c.size.height;
    }

    if (_hasImage && child != null) {
      layoutChild(child, 0);
      child = childAfter(child);
      y += 24;
    }

    if (child != null) {
      // Title
      layoutChild(child, 0);
      child = childAfter(child);
    }

    if (_hasDescription && child != null) {
      y += 8;
      layoutChild(child, 0);
      child = childAfter(child);
    }

    if (_hasAction && child != null) {
      y += 24;
      layoutChild(child, 0);
      child = childAfter(child);
    }

    size = constraints.constrain(Size(width, y));
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
