import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/common_strings.dart' as strings;

Future<void> showErrorDialog(BuildContext context, String text) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => _ErrorDialog(text),
  );
}

Future<void> showDefaultErrorDialog(BuildContext context) async => await showErrorDialog(context, strings.errorOccurred);

class _ErrorDialog extends StatelessWidget {
  final String text;

  _ErrorDialog(this.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(strings.error),
      content: Text(text),
      actions: [
        TextButton(
          child: Text(strings.ok),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
