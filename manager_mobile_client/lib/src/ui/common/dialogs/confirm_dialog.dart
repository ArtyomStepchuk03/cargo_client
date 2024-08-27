import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/common_strings.dart' as strings;

Future<bool> showQuestionDialog(BuildContext context, String text) async {
  final result = await showDialog<bool>(context: context, builder: (BuildContext context) => _ConfirmDialog(
    text: text,
    cancelButtonTitle: strings.no,
    confirmButtonTitle: strings.yes,
  ));
  if (result == null) {
    return false;
  }
  return result;
}

Future<bool> showContinueDialog(BuildContext context, String text, {String confirmButtonTitle = strings.continue_}) async {
  final result = await showDialog<bool>(context: context, builder: (BuildContext context) => _ConfirmDialog(
    text: text,
    cancelButtonTitle: strings.cancel,
    confirmButtonTitle: confirmButtonTitle,
  ));
  if (result == null) {
    return false;
  }
  return result;
}

class _ConfirmDialog extends StatelessWidget {
  final String text;
  final String cancelButtonTitle;
  final String confirmButtonTitle;

  _ConfirmDialog({this.text, this.cancelButtonTitle, this.confirmButtonTitle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(text),
      actions: [
        TextButton(
          child: Text(cancelButtonTitle),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: Text(confirmButtonTitle),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
