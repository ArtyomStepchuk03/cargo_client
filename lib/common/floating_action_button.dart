import 'package:flutter/material.dart';

const floatingActionButtonWidth = 200.0;
const floatingActionButtonHeight = 56.0;

Widget buildFloatingActionButtonContainer({Widget? child}) {
  return SizedBox(
    width: floatingActionButtonWidth,
    height: floatingActionButtonHeight,
    child: child,
  );
}

Widget buildFloatingActionButtonSpacer([bool? visible = true]) {
  return SizedBox(height: visible == true ? 68 : 0);
}
