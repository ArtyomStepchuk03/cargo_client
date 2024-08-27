import 'package:flutter/material.dart';

Widget buildAppBar({Widget title, List<Widget> actions, Widget leading, Widget bottom}) {
  return AppBar(
    leading: leading,
    actions: actions,
    title: title,
    bottom: bottom,
    titleSpacing: 0,
  );
}