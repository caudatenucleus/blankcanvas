// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_biometric_auth.dart';


/// A biometric authentication widget.
class BiometricAuth extends LeafRenderObjectWidget {
  const BiometricAuth({
    super.key,
    this.onAuthenticated,
    this.supportedMethods = const [
      BiometricMethod.fingerprint,
      BiometricMethod.faceId,
    ],
    this.tag,
  });

  final void Function(bool success, BiometricMethod method)? onAuthenticated;
  final List<BiometricMethod> supportedMethods;
  final String? tag;

  @override
  RenderBiometricAuth createRenderObject(BuildContext context) {
    return RenderBiometricAuth(
      onAuthenticated: onAuthenticated,
      supportedMethods: supportedMethods,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBiometricAuth renderObject,
  ) {
    renderObject
      ..onAuthenticated = onAuthenticated
      ..supportedMethods = supportedMethods;
  }
}

enum BiometricMethod { fingerprint, faceId, iris }
