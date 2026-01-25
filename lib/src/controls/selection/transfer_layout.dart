// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_transfer_layout.dart';


class TransferLayout extends MultiChildRenderObjectWidget {
  const TransferLayout({super.key, required super.children});

  @override
  RenderTransferLayout createRenderObject(BuildContext context) {
    return RenderTransferLayout();
  }
}
