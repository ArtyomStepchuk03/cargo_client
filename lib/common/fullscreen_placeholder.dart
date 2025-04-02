import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class FullscreenPlaceholder extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? button;

  FullscreenPlaceholder({required this.icon, required this.text, this.button});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
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
            Padding(padding: EdgeInsets.only(top: 16), child: button),
        ],
      ),
    );
  }
}

Widget buildFullscreenError(BuildContext context) {
  final localizationUtil = LocalizationUtil.of(context);
  return FullscreenPlaceholder(
    icon: Icons.error_outline,
    text: localizationUtil.errorOccurred,
  );
}
