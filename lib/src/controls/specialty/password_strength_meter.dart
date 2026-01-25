// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_password_strength_meter.dart';


/// A visual password strength indicator.
class PasswordStrengthMeter extends LeafRenderObjectWidget {
  const PasswordStrengthMeter({
    super.key,
    required this.password,
    this.minLength = 8,
    this.tag,
  });

  final String password;
  final int minLength;
  final String? tag;

  @override
  RenderPasswordStrengthMeter createRenderObject(BuildContext context) {
    return RenderPasswordStrengthMeter(
      password: password,
      minLength: minLength,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPasswordStrengthMeter renderObject,
  ) {
    renderObject
      ..password = password
      ..minLength = minLength;
  }
}

enum PasswordStrength { none, weak, fair, good, strong }
