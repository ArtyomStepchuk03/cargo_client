import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/validators/common_validators.dart';
import 'text_form_field.dart';

Widget buildHourOnlyFormField({
  Key key,
  int initialValue,
  String label,
  List<FormFieldValidator<String>> validators,
  bool enabled = true
}) {
  final composedValidator = MultipleValidator<String>([HourValidator(), ...?validators]);
  return CustomTextFormField(
    key: key,
    initialValue: initialValue != null ? '$initialValue' : null,
    label: label,
    inputType: TextInputType.numberWithOptions(signed: false, decimal: false),
    validator: composedValidator,
    enabled: enabled,
  );
}
