// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'custom_validator.dart';
import 'form_validator.dart';

/// Schema for a single form field.
class FormFieldSchema {
  final String name;
  final String label;
  final FormFieldType type;
  final dynamic defaultValue;
  final List<FormValidator> validators;
  final List<String>? options;
  final String? placeholder;

  const FormFieldSchema({
    required this.name,
    required this.label,
    this.type = FormFieldType.text,
    this.defaultValue,
    this.validators = const [],
    this.options,
    this.placeholder,
  });
}
