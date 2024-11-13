import 'package:flutter/material.dart';

extension MaterialStateColorUtility on MaterialStateProperty<Color> {
  static MaterialStateProperty<Color> allExceptDisabled(Color color, {Color disabledColor}) {
    return MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return disabledColor ?? Colors.grey[300];
      }
      return color;
    });
  }
}

Widget buildButton(BuildContext context, {VoidCallback onPressed, Widget child}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ButtonStyle(
      backgroundColor: MaterialStateColorUtility.allExceptDisabled(Theme.of(context).primaryColor),
    ),
    child: child,
  );
}
