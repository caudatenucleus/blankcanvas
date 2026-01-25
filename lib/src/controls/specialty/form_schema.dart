// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'form_field_schema.dart';

/// Schema for building a form.
class FormSchema {
  final List<FormFieldSchema> fields;
  final String? submitLabel;

  const FormSchema({required this.fields, this.submitLabel = 'Submit'});
}

/// A dynamic form builder widget.
/// Note: Forms require state management for values/validation,
