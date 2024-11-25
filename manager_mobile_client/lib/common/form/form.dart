import 'package:flutter/material.dart';

import 'scrollable_form.dart';

export 'scrollable_form.dart';

Widget buildForm({Key key, List<Widget> children}) {
  return ScrollableForm(
    key: key,
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    children: children,
  );
}

Widget buildRefreshableForm(
    {RefreshCallback onRefresh, List<Widget> children}) {
  return RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      children: children,
    ),
  );
}

Widget buildFormGroup(List<Widget> children) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Column(children: children),
  );
}

Widget buildFormRow(IconData icon, Widget first, [Widget second]) {
  const spacing = 16.0;
  final children = <Widget>[];
  children.add(_buildFormRowIcon(icon));
  children.add(SizedBox(width: spacing));
  children.add(Expanded(child: _buildFormFieldContainer(first)));
  if (second != null) {
    children.add(SizedBox(width: spacing));
    children.add(Expanded(child: _buildFormFieldContainer(second)));
  }
  return Row(children: children);
}

Widget _buildFormFieldContainer(Widget field) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: field,
  );
}

Widget _buildFormRowIcon(IconData icon) {
  final size = 24.0;
  if (icon != null) {
    return Icon(icon, size: size);
  }
  return SizedBox(width: size, height: size);
}
