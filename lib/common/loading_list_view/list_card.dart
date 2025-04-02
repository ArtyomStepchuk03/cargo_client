import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/intersperse.dart';

class ListCard extends StatelessWidget {
  final Color? backgroundColor;
  final Color? highlightColor;
  final List<Widget> children;
  final Widget? expandedWidget;
  final GestureTapCallback? onTap;

  ListCard(
      {this.backgroundColor,
      this.highlightColor,
      required this.children,
      this.expandedWidget,
      this.onTap});

  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        side: highlightColor != null
            ? BorderSide(color: highlightColor!)
            : BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            child: _buildListCardContent(
              children: children,
            ),
            onTap: onTap,
          ),
          if (expandedWidget != null) expandedWidget!,
        ],
      ),
    );
  }
}

class SelectableListCard extends StatelessWidget {
  final List<Widget> children;
  final bool checked;
  final GestureTapCallback? onTap;

  SelectableListCard(
      {required this.children, this.checked = false, this.onTap});

  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: Row(children: [
          _buildCheckmark(context, checked),
          Expanded(
            child: _buildListCardContent(
              children: children,
            ),
          ),
        ]),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCheckmark(BuildContext context, bool checked) {
    return Container(
      width: 24,
      height: 24,
      margin: EdgeInsets.all(6),
      child: checked
          ? Icon(
              Icons.check_box,
              color: Theme.of(context).primaryColor,
            )
          : Icon(Icons.check_box_outline_blank, color: Colors.grey),
    );
  }
}

class ListCardField extends StatelessWidget {
  final String? name;
  final String value;
  final Color textColor;

  ListCardField(
      {this.name, required this.value, this.textColor = Colors.black});

  Widget build(BuildContext context) {
    if (name != null) {
      return RichText(
        text: TextSpan(children: [
          TextSpan(text: '$name: ', style: TextStyle(color: Colors.indigo)),
          TextSpan(text: value, style: TextStyle(color: textColor)),
        ]),
      );
    }
    return Text(value, style: TextStyle(color: textColor));
  }
}

Widget _buildListCardContent({required List<Widget> children}) {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.intersperse(SizedBox(height: 8)).toList(),
    ),
  );
}
