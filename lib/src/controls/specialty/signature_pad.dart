// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_signature_pad.dart';


/// A widget for capturing handwritten signatures.
class SignaturePad extends LeafRenderObjectWidget {
  const SignaturePad({
    super.key,
    this.strokeColor = const Color(0xFF000000),
    this.strokeWidth = 2.0,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.onSignatureChanged,
    this.tag,
  });

  final Color strokeColor;
  final double strokeWidth;
  final Color backgroundColor;
  final ValueChanged<List<List<Offset>>>? onSignatureChanged;
  final String? tag;

  @override
  RenderSignaturePad createRenderObject(BuildContext context) {
    return RenderSignaturePad(
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      backgroundColor: backgroundColor,
      onSignatureChanged: onSignatureChanged,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSignaturePad renderObject,
  ) {
    renderObject
      ..strokeColor = strokeColor
      ..strokeWidth = strokeWidth
      ..backgroundColor = backgroundColor
      ..onSignatureChanged = onSignatureChanged;
  }
}
