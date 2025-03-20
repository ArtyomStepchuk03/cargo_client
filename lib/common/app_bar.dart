import 'package:flutter/material.dart';

PreferredSizeWidget buildAppBar(
    {Widget? title,
    List<Widget>? actions,
    Widget? leading,
    PreferredSizeWidget? bottom}) {
  return AppBar(
    leading: leading,
    actions: actions,
    foregroundColor: Colors.white,
    title: title,
    bottom: bottom,
    titleSpacing: 0,
  );
}
