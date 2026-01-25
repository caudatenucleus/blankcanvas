// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderFollowerLayer - Link-source coordinate engine
// =============================================================================

class FollowerLayerPrimitive extends SingleChildRenderObjectWidget {
  const FollowerLayerPrimitive({
    super.key,
    required this.link,
    this.showWhenUnlinked = true,
    this.offset = Offset.zero,
    this.leaderAnchor = Alignment.topLeft,
    this.followerAnchor = Alignment.topLeft,
    super.child,
  });
  final LayerLink link;
  final bool showWhenUnlinked;
  final Offset offset;
  final Alignment leaderAnchor;
  final Alignment followerAnchor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFollowerLayerPrimitive(
      link: link,
      showWhenUnlinked: showWhenUnlinked,
      offset: offset,
      leaderAnchor: leaderAnchor,
      followerAnchor: followerAnchor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFollowerLayerPrimitive renderObject,
  ) {
    renderObject
      ..link = link
      ..showWhenUnlinked = showWhenUnlinked
      ..offset = offset
      ..leaderAnchor = leaderAnchor
      ..followerAnchor = followerAnchor;
  }
}

class RenderFollowerLayerPrimitive extends RenderFollowerLayer {
  RenderFollowerLayerPrimitive({
    required super.link,
    super.showWhenUnlinked,
    super.offset,
    super.leaderAnchor,
    super.followerAnchor,
  });
}
