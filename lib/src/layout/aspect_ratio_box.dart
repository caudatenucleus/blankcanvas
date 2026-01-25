import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// An enhanced aspect ratio widget using lowest-level APIs.
class AspectRatioBox extends SingleChildRenderObjectWidget {
  const AspectRatioBox({
    super.key,
    required this.aspectRatio,
    required Widget child,
    this.fit = BoxFit.contain,
  }) : super(child: child);

  final double aspectRatio;
  final BoxFit fit;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAspectRatioBox(aspectRatio: aspectRatio);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAspectRatioBox renderObject,
  ) {
    renderObject.aspectRatio = aspectRatio;
  }
}

class RenderAspectRatioBox extends RenderAspectRatio {
  RenderAspectRatioBox({required super.aspectRatio});

  // RenderAspectRatio already handles the layout logic for bounded/unbounded
  // to a large extent. If we needed custom 'fit' logic like the original
  // implementation intended (handling failures gracefully), we can override
  // performLayout.

  // For now, we reuse RenderAspectRatio which is the lowest level implementation.
}
