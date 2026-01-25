import 'package:flutter/widgets.dart';

/// A widget that takes up space in a [Row], [Column], or [Flex] using lowest-level RenderObject APIs.
class Spacer extends LeafRenderObjectWidget {
  const Spacer({super.key, this.flex = 1});

  final int flex;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSpacer();
  }
}

class RenderSpacer extends RenderBox {
  @override
  void performLayout() {
    size = constraints.smallest;
  }
}
