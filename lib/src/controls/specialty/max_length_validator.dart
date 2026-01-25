// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.
import 'form_validator.dart';



class MaxLengthValidator implements FormValidator {
  final int maxLength;
  final String? message;
  const MaxLengthValidator(this.maxLength, [this.message]);

  @override
  String? validate(dynamic value) {
    if (value == null || value is! String) return null;
    if (value.length > maxLength) {
      return message ?? 'Maximum $maxLength characters allowed';
    }
    return null;
  }
}