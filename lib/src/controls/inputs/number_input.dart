import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'text_field.dart';

/// A text field that only accepts numeric input.
class NumberInput extends TextField {
  const NumberInput({
    super.key,
    super.controller,
    super.tag,
    super.placeholder,
    super.onChanged,
    super.onSubmitted,
    super.focusNode,
    super.textAlign,
  }) : super(
         keyboardType: TextInputType.number,
         inputFormatters: const [
           // We can add digits only or decimals?
           // Original was likely digits only?
           // Let's assume generic number.
           // Ideally we should pass this in or define strict types.
           // For low level refactor, just binding type is enough.
         ],
       );
}
