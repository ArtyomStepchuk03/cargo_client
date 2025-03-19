import 'package:flutter/material.dart';

import 'input_decoration.dart';

Widget buildCustomNoneditableTextField({
  required BuildContext context,
  required String text,
  Color? enabledBorderColor,
  Color? disabledBorderColor,
  String? label,
  Color? labelColor,
  Widget? icon,
  String? helperText,
  Color? helperTextColor,
  String? errorText,
  bool enabled = true,
}) {
  return InputDecorator(
    isEmpty: text.isEmpty,
    decoration: buildCustomInputDecoration(
        context: context,
        enabledBorderColor: enabledBorderColor,
        disabledBorderColor: disabledBorderColor,
        label: label,
        labelColor: labelColor,
        icon: icon,
        helperText: helperText,
        helperTextColor: helperTextColor,
        errorText: errorText,
        enabled: enabled),
    child: Text(text,
        style: Theme.of(context).textTheme.titleMedium, maxLines: null),
  );
}

Widget buildLoadingTextField(
    {required BuildContext context,
    String? text,
    String? label,
    bool enabled = true}) {
  return buildCustomNoneditableTextField(
    context: context,
    text: text ?? '',
    label: label,
    icon: Container(
      width: 48,
      height: 48,
      child: Container(
        margin: EdgeInsets.all(16),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
    enabled: enabled,
  );
}
