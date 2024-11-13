import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/validators/number_validator.dart';

import 'text_form_field.dart';

Widget buildCustomNumberFormField(BuildContext context,
    {Key key,
    String initialValue,
    String label,
    ValueChanged<String> onChanged,
    bool loading = false,
    FormFieldValidator<String> validator,
    bool enabled = true}) {
  final actualValidator =
      validator ?? NumberValidator.required(context, decimal: true);
  return CustomTextFormField(
    key: key,
    initialValue: initialValue,
    label: label,
    onChanged: onChanged,
    loading: loading,
    inputType: TextInputType.numberWithOptions(signed: false, decimal: true),
    validator: actualValidator,
    enabled: enabled,
  );
}

Widget buildCustomIntegerFormField(BuildContext context,
    {Key key,
    String initialValue,
    String label,
    ValueChanged<String> onChanged,
    bool loading = false,
    FormFieldValidator<String> validator,
    bool enabled = true}) {
  final actualValidator =
      validator ?? NumberValidator.required(context, decimal: false);
  return CustomTextFormField(
    key: key,
    initialValue: initialValue,
    label: label,
    onChanged: onChanged,
    loading: loading,
    inputType: TextInputType.numberWithOptions(signed: false, decimal: false),
    validator: actualValidator,
    enabled: enabled,
  );
}
