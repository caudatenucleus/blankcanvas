// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_q_r_scanner.dart';


/// A QR code scanner widget.
class QRScanner extends LeafRenderObjectWidget {
  const QRScanner({super.key, this.onScanned, this.tag});

  final void Function(String data)? onScanned;
  final String? tag;

  @override
  RenderQRScanner createRenderObject(BuildContext context) {
    return RenderQRScanner(onScanned: onScanned);
  }

  @override
  void updateRenderObject(BuildContext context, RenderQRScanner renderObject) {
    renderObject.onScanned = onScanned;
  }
}
