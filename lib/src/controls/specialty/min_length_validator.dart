// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.
import 'form_validator.dart';



class MinLengthValidator implements FormValidator {
  final int minLength;
  final String? message;
  const MinLengthValidator(this.minLength, [this.message]);

  @override
  String? validate(dynamic value) {
    if (value == null || value is! String) return null;
    if (value.length < minLength) {
      return message ?? 'Minimum $minLength characters required';
    }
    return null;
  }
}