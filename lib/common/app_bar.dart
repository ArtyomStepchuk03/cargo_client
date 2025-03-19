import 'package:flutter/material.dart';

PreferredSizeWidget buildAppBar(
    {Widget? title,
    List<Widget>? actions,
    Widget? leading,
    PreferredSizeWidget? bottom}) {
  return AppBar(
    leading: leading,
    actions: actions,
    title: title,
    bottom: bottom,
    titleSpacing: 0,
  );
}
