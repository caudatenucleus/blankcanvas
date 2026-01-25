// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_barcode_scanner.dart';


/// A barcode scanner widget.
class BarcodeScanner extends LeafRenderObjectWidget {
  const BarcodeScanner({
    super.key,
    this.onScanned,
    this.formats = const ['EAN-13', 'UPC-A', 'Code128'],
    this.tag,
  });

  final void Function(String code, String format)? onScanned;
  final List<String> formats;
  final String? tag;

  @override
  RenderBarcodeScanner createRenderObject(BuildContext context) {
    return RenderBarcodeScanner(onScanned: onScanned, formats: formats);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBarcodeScanner renderObject,
  ) {
    renderObject
      ..onScanned = onScanned
      ..formats = formats;
  }
}
