import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/customization.dart';
import '../theme/theme.dart';
import 'layout.dart';

/// A node in the tree.
class TreeNode<T> {
  TreeNode({
    required this.data,
    this.children = const [],
    this.isExpanded = false,
  });

  final T data;
  final List<TreeNode<T>> children;
  bool isExpanded;
}

/// A Tree View widget.
class TreeView<T> extends StatefulWidget {
  const TreeView({
    super.key,
    required this.nodes,
    required this.nodeBuilder,
    this.onNodeTap,
    this.tag,
  });

  final List<TreeNode<T>> nodes;
  final Widget Function(BuildContext context, T data) nodeBuilder;
  final ValueChanged<TreeNode<T>>? onNodeTap;
  final String? tag;

  @override
  State<TreeView<T>> createState() => _TreeViewState<T>();
}

class _TreeViewState<T> extends State<TreeView<T>> {
  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTreeView(widget.tag);

    final status = TreeControlStatus();
    final decoration =
        customization?.decoration(status) ?? const BoxDecoration();

    final List<_FlatNode<T>> flatNodes = [];
    void flatten(TreeNode<T> node, int depth) {
      flatNodes.add(_FlatNode(node: node, depth: depth));
      if (node.isExpanded) {
        for (final child in node.children) {
          flatten(child, depth + 1);
        }
      }
    }

    for (final node in widget.nodes) {
      flatten(node, 0);
    }

    return LayoutBox(
      padding: EdgeInsets.zero,
      child: _TreeViewContainerRenderWidget(
        decoration: decoration is BoxDecoration
            ? decoration
            : const BoxDecoration(),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: flatNodes.length,
          itemBuilder: (context, index) {
            final flatNode = flatNodes[index];
            return _TreeItemWidget(
              node: flatNode.node,
              depth: flatNode.depth,
              content: widget.nodeBuilder(context, flatNode.node.data),
              onTap: () => widget.onNodeTap?.call(flatNode.node),
              onToggle: () {
                setState(() {
                  flatNode.node.isExpanded = !flatNode.node.isExpanded;
                });
              },
              customization:
                  customization?.itemCustomization ??
                  TreeItemCustomization.simple(),
            );
          },
        ),
      ),
    );
  }
}

class _FlatNode<T> {
  _FlatNode({required this.node, required this.depth});
  final TreeNode<T> node;
  final int depth;
}

class _TreeViewContainerRenderWidget extends SingleChildRenderObjectWidget {
  const _TreeViewContainerRenderWidget({super.child, required this.decoration});
  final BoxDecoration decoration;

  @override
  RenderTreeViewContainer createRenderObject(BuildContext context) =>
      RenderTreeViewContainer(decoration: decoration);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTreeViewContainer renderObject,
  ) {
    renderObject.decoration = decoration;
  }
}

class RenderTreeViewContainer extends RenderProxyBox {
  RenderTreeViewContainer({required BoxDecoration decoration})
    : _decoration = decoration;
  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0x00000000);
    if (decoration.borderRadius != null) {
      context.canvas.drawRRect(
        decoration.borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
        paint,
      );
    } else {
      context.canvas.drawRect(rect, paint);
    }
    if (child != null) context.paintChild(child!, offset);
  }
}

class _TreeItemWidget<T> extends MultiChildRenderObjectWidget {
  _TreeItemWidget({
    required this.node,
    required this.depth,
    required Widget content,
    required this.onTap,
    required this.onToggle,
    required this.customization,
  }) : super(
         children: [
           content,
           // Toggle icon (if has children)
           if (node.children.isNotEmpty)
             _ToggleIconWidget(
               isExpanded: node.isExpanded,
               customization: customization,
             ),
         ],
       );

  final TreeNode<T> node;
  final int depth;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final TreeItemCustomization customization;

  @override
  RenderTreeItem createRenderObject(BuildContext context) {
    return RenderTreeItem(
      depth: depth,
      indent: customization.indent ?? 20.0,
      padding:
          customization.padding ??
          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration:
          customization.decoration(
                TreeItemControlStatus()
                  ..enabled = 1.0
                  ..hovered = 0.0
                  ..selected = 0.0
                  ..expanded = node.isExpanded ? 1.0 : 0.0,
              )
              as BoxDecoration, // Cast to BoxDecoration
      onTap: onTap,
      onToggle: onToggle,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTreeItem renderObject,
  ) {
    renderObject
      ..depth = depth
      ..indent = customization.indent ?? 20.0
      ..padding =
          customization.padding ??
          const EdgeInsets.symmetric(vertical: 4, horizontal: 8)
      ..decoration =
          customization.decoration(
                TreeItemControlStatus()
                  ..enabled = 1.0
                  ..hovered = 0.0
                  ..selected = 0.0
                  ..expanded = node.isExpanded ? 1.0 : 0.0,
              )
              as BoxDecoration // Cast to BoxDecoration
      ..onTap = onTap
      ..onToggle = onToggle;
  }
}

class _ToggleIconWidget extends LeafRenderObjectWidget {
  const _ToggleIconWidget({
    required this.isExpanded,
    required this.customization,
  });
  final bool isExpanded;
  final TreeItemCustomization customization;

  @override
  RenderToggleIcon createRenderObject(BuildContext context) =>
      RenderToggleIcon(isExpanded: isExpanded, customization: customization);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderToggleIcon renderObject,
  ) {
    renderObject
      ..isExpanded = isExpanded
      ..customization = customization;
  }
}

class RenderToggleIcon extends RenderBox {
  RenderToggleIcon({
    required bool isExpanded,
    required TreeItemCustomization customization,
  }) : _isExpanded = isExpanded,
       _customization = customization;

  bool _isExpanded;
  bool get isExpanded => _isExpanded;
  set isExpanded(bool value) {
    if (_isExpanded == value) return;
    _isExpanded = value;
    markNeedsPaint();
  }

  TreeItemCustomization _customization;
  TreeItemCustomization get customization => _customization;
  set customization(TreeItemCustomization value) {
    _customization = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(16, 16));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final status = TreeItemControlStatus()..expanded = isExpanded ? 1.0 : 0.0;
    final textStyle = customization.textStyle(status);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: isExpanded ? "▼" : "▶",
        style: textStyle.copyWith(fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      context.canvas,
      offset + (size.center(Offset.zero) - (textPainter.size / 2).getOffset()),
    );
  }
}

class TreeItemParentData extends ContainerBoxParentData<RenderBox> {}

class RenderTreeItem extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TreeItemParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TreeItemParentData> {
  RenderTreeItem({
    required int depth,
    required double indent,
    required EdgeInsetsGeometry padding,
    required BoxDecoration decoration,
    required this.onTap,
    required this.onToggle,
  }) : _depth = depth,
       _indent = indent,
       _padding = padding,
       _decoration = decoration;

  int _depth;
  @override
  int get depth => _depth;
  set depth(int value) {
    if (_depth == value) return;
    _depth = value;
    markNeedsLayout();
  }

  double _indent;
  double get indent => _indent;
  set indent(double value) {
    if (_indent == value) return;
    _indent = value;
    markNeedsLayout();
  }

  EdgeInsetsGeometry _padding;
  EdgeInsetsGeometry get padding => _padding;
  set padding(EdgeInsetsGeometry value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  Decoration _decoration;
  Decoration get decoration => _decoration;
  set decoration(Decoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  VoidCallback onTap;
  VoidCallback onToggle;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TreeItemParentData) {
      child.parentData = TreeItemParentData();
    }
  }

  @override
  void performLayout() {
    final resolvedPadding = padding.resolve(TextDirection.ltr);
    final double leftOffset = depth * indent + resolvedPadding.left;
    double maxChildHeight = 0;

    // child 0: content, child 1: toggle (optional)

    RenderBox? content = firstChild;
    RenderBox? toggle = content != null ? childAfter(content) : null;

    if (toggle != null) {
      toggle.layout(constraints.loosen(), parentUsesSize: true);
      final toggleParentData = toggle.parentData! as TreeItemParentData;
      toggleParentData.offset = Offset(leftOffset, resolvedPadding.top);
      maxChildHeight = toggle.size.height;
    }

    if (content != null) {
      final double contentLeft =
          leftOffset + (toggle != null ? toggle.size.width + 8 : 20);
      content.layout(
        constraints.deflate(
          EdgeInsets.only(
            left: contentLeft,
            top: resolvedPadding.top,
            bottom: resolvedPadding.bottom,
          ),
        ),
        parentUsesSize: true,
      );
      final contentParentData = content.parentData! as TreeItemParentData;
      contentParentData.offset = Offset(contentLeft, resolvedPadding.top);
      maxChildHeight = maxChildHeight > content.size.height
          ? maxChildHeight
          : content.size.height;
    }

    size = constraints.constrain(
      Size(constraints.maxWidth, maxChildHeight + resolvedPadding.vertical),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint();
    if (decoration is BoxDecoration) {
      final boxDecoration = decoration as BoxDecoration;
      paint.color = boxDecoration.color ?? const Color(0x00000000);
      if (boxDecoration.borderRadius != null) {
        context.canvas.drawRRect(
          boxDecoration.borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
          paint,
        );
      } else {
        context.canvas.drawRect(rect, paint);
      }
    }
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      // Logic for toggle vs content hit test
      RenderBox? content = firstChild;
      RenderBox? toggle = content != null ? childAfter(content) : null;

      if (toggle != null) {
        final toggleParentData = toggle.parentData! as TreeItemParentData;
        if ((toggleParentData.offset & toggle.size).contains(
          event.localPosition,
        )) {
          onToggle();
          return;
        }
      }
      onTap();
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

extension on Size {
  Offset getOffset() => Offset(width, height);
}
