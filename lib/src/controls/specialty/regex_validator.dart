// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.
import 'form_validator.dart';



class RegexValidator implements FormValidator {
  final RegExp pattern;
  final String message;
  const RegexValidator(this.pattern, this.message);

  @override
  String? validate(dynamic value) {
    if (value == null || value is! String) return null;
    if (!pattern.hasMatch(value)) return message;
    return null;
  }
}