import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A sliver that manages an animated grid using lowest-level RenderObject APIs.
class SliverAnimatedGridPrimitive extends SliverMultiBoxAdaptorWidget {
  const SliverAnimatedGridPrimitive({
    super.key,
    required super.delegate,
    required this.gridDelegate,
    this.initialItemCount = 0,
  });

  final SliverGridDelegate gridDelegate;
  final int initialItemCount;

  @override
  RenderSliverGrid createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverGrid(childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }
}
