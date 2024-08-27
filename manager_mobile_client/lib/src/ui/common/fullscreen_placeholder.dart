import 'package:flutter/material.dart';
import 'common_strings.dart' as strings;

class FullscreenPlaceholder extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget button;

  FullscreenPlaceholder({this.icon, this.text, this.button});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64, height: 64,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Icon(icon, color: Colors.black26),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Text(text, textAlign: TextAlign.center),
            ),
          ),
          if (button != null)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: button
            ),
        ],
      ),
    );
  }
}

Widget buildFullscreenError() {
  return FullscreenPlaceholder(
    icon: Icons.error_outline,
    text: strings.errorOccurred,
  );
}
