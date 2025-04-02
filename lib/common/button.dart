import 'package:flutter/material.dart';

extension MaterialStateColorUtility on WidgetStateProperty<Color> {
  static WidgetStateProperty<Color?> allExceptDisabled(Color? color,
      {Color? disabledColor}) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return disabledColor ?? Colors.grey[300];
      }
      return color;
    });
  }
}

Widget buildButton(BuildContext context,
    {VoidCallback? onPressed, required Widget child}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ButtonStyle(
      backgroundColor: MaterialStateColorUtility.allExceptDisabled(
          Theme.of(context).primaryColor),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
    ),
    child: child,
  );
}
