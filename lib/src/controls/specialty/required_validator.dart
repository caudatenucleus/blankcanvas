// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'form_validator.dart';

class RequiredValidator implements FormValidator {
  final String message;
  const RequiredValidator([this.message = 'This field is required']);

  @override
  String? validate(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      return message;
    }
    return null;
  }
}
