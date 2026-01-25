// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_captcha.dart';


/// A CAPTCHA verification widget.
class Captcha extends LeafRenderObjectWidget {
  const Captcha({
    super.key,
    required this.onVerified,
    this.length = 6,
    this.tag,
  });

  final void Function(bool verified)? onVerified;
  final int length;
  final String? tag;

  @override
  RenderCaptcha createRenderObject(BuildContext context) {
    return RenderCaptcha(onVerified: onVerified, length: length);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCaptcha renderObject) {
    renderObject
      ..onVerified = onVerified
      ..length = length;
  }
}
