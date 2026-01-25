import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

typedef AnimatedItemBuilder =
    Widget Function(
      BuildContext context,
      int index,
      Animation<double> animation,
    );

/// A sliver that manages an animated list using lowest-level RenderObject APIs.
class SliverAnimatedListPrimitive extends SliverMultiBoxAdaptorWidget {
  const SliverAnimatedListPrimitive({
    super.key,
    required super.delegate,
    this.initialItemCount = 0,
  });

  final int initialItemCount;

  @override
  RenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverList(childManager: element);
  }
}
