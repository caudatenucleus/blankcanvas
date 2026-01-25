import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  testWidgets('FormBuilder renders fields from schema', (
    WidgetTester tester,
  ) async {
    final schema = FormSchema(
      fields: [
        FormFieldSchema(
          name: 'email',
          label: 'Email',
          type: FormFieldType.email,
        ),
        FormFieldSchema(name: 'name', label: 'Name', type: FormFieldType.text),
      ],
    );

    await tester.pumpWidget(
      w.Directionality(
        textDirection: w.TextDirection.ltr,
        child: FormBuilder(schema: schema, onSubmit: (values) {}),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  test('RequiredValidator validates correctly', () {
    final validator = RequiredValidator();
    expect(validator.validate(null), isNotNull);
    expect(validator.validate(''), isNotNull);
    expect(validator.validate('hello'), isNull);
  });

  test('EmailValidator validates correctly', () {
    final validator = EmailValidator();
    expect(validator.validate('invalid'), isNotNull);
    expect(validator.validate('test@example.com'), isNull);
  });

  test('MinLengthValidator validates correctly', () {
    final validator = MinLengthValidator(5);
    expect(validator.validate('abc'), isNotNull);
    expect(validator.validate('abcdef'), isNull);
  });
}
