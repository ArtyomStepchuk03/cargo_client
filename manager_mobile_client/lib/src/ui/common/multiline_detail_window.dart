import 'package:flutter/material.dart';

class MultilineDetailWindow extends StatelessWidget {
  final List<String> lines;

  MultilineDetailWindow({this.lines});

  @override
  Widget build(BuildContext context) {
    final children = lines.map((line) => Text(line)).toList();
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

void showMultilineDetailWindow({BuildContext context, List<String> lines}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => MultilineDetailWindow(lines: lines),
  );
}
