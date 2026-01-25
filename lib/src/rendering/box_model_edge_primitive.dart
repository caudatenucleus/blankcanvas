// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderBoxModelEdge - Border/Margin/Padding atom
// =============================================================================

class BoxModelEdgePrimitive {
  const BoxModelEdgePrimitive({
    this.margin = EdgeInsets.zero,
    this.border = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
  });

  final EdgeInsets margin;
  final EdgeInsets border;
  final EdgeInsets padding;

  /// Total insets from all edges combined
  EdgeInsets get totalInsets => margin + border + padding;

  /// Deflate a size by all edge insets
  Size deflateSize(Size size) {
    return Size(
      size.width - totalInsets.horizontal,
      size.height - totalInsets.vertical,
    );
  }

  /// Inflate a size by all edge insets
  Size inflateSize(Size size) {
    return Size(
      size.width + totalInsets.horizontal,
      size.height + totalInsets.vertical,
    );
  }

  /// Get content offset (inside all edges)
  Offset get contentOffset => Offset(
    margin.left + border.left + padding.left,
    margin.top + border.top + padding.top,
  );
}
