import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

Future<void> showInformationDialog(BuildContext context, String? text) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => _InformationDialog(text),
  );
}

class _InformationDialog extends StatelessWidget {
  final String? text;

  _InformationDialog(this.text);

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return AlertDialog(
      content: Text(text ?? ""),
      actions: [
        TextButton(
          child: Text(localizationUtil.ok),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
