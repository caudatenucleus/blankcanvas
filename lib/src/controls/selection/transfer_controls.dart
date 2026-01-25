// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_transfer_controls.dart';

class TransferControls extends LeafRenderObjectWidget {
  const TransferControls({
    super.key,
    this.onToRight,
    this.onAllToRight,
    this.onToLeft,
    this.onAllToLeft,
  });

  final VoidCallback? onToRight;
  final VoidCallback? onAllToRight;
  final VoidCallback? onToLeft;
  final VoidCallback? onAllToLeft;

  @override
  RenderTransferControls createRenderObject(BuildContext context) {
    return RenderTransferControls(
      onToRight: onToRight,
      onAllToRight: onAllToRight,
      onToLeft: onToLeft,
      onAllToLeft: onAllToLeft,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTransferControls renderObject,
  ) {
    renderObject
      ..onToRight = onToRight
      ..onAllToRight = onAllToRight
      ..onToLeft = onToLeft
      ..onAllToLeft = onAllToLeft;
  }
}
