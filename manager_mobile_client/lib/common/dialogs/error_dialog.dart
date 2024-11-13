import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

Future<void> showErrorDialog(BuildContext context, String text) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => _ErrorDialog(text),
  );
}

Future<void> showDefaultErrorDialog(BuildContext context) async {
  final localizationUtil = LocalizationUtil.of(context);
  await showErrorDialog(context, localizationUtil.errorOccurred);
}

class _ErrorDialog extends StatelessWidget {
  final String text;

  _ErrorDialog(this.text);

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return AlertDialog(
      title: Text(localizationUtil.error),
      content: Text(text),
      actions: [
        TextButton(
          child: Text(localizationUtil.ok),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
