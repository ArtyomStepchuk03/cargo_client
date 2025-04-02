import 'package:flutter/material.dart';

InputDecoration buildCustomInputDecoration(
    {required BuildContext context,
    Color? enabledBorderColor,
    Color? disabledBorderColor,
    String? label,
    Color? labelColor,
    Widget? icon,
    String? helperText,
    Color? helperTextColor,
    String? errorText,
    bool enabled = true}) {
  return InputDecoration(
    labelText: label,
    labelStyle: labelColor != null ? TextStyle(color: labelColor) : null,
    suffixIcon: icon,
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: enabledBorderColor != null
                ? enabledBorderColor
                : Theme.of(context).colorScheme.primary)),
    disabledBorder: disabledBorderColor != null
        ? OutlineInputBorder(borderSide: BorderSide(color: disabledBorderColor))
        : null,
    helperText: helperText,
    helperStyle:
        helperTextColor != null ? TextStyle(color: helperTextColor) : null,
    errorText: errorText,
    enabled: enabled,
  );
}
