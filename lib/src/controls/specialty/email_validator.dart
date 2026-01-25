// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.
import 'form_validator.dart';

class EmailValidator implements FormValidator {
  final String message;
  const EmailValidator([this.message = 'Enter a valid email']);

  @override
  String? validate(dynamic value) {
    if (value == null || value is! String) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return message;
    return null;
  }
}
