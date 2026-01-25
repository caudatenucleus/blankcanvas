// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.
import 'form_validator.dart';



class CustomValidator implements FormValidator {
  final String? Function(dynamic value) validatorFn;
  const CustomValidator(this.validatorFn);

  @override
  String? validate(dynamic value) => validatorFn(value);
}

/// Field types supported by FormBuilder.
enum FormFieldType { text, email, password, number, checkbox, dropdown, date }