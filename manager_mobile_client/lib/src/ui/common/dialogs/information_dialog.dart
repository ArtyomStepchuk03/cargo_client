import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/common_strings.dart' as strings;

Future<void> showInformationDialog(BuildContext context, String text) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => _InformationDialog(text),
  );
}

class _InformationDialog extends StatelessWidget {
  final String text;

  _InformationDialog(this.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
