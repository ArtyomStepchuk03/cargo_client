import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

Future<bool> showQuestionDialog(BuildContext context, String text) async {
  final localizationUtil = LocalizationUtil.of(context);
  final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => _ConfirmDialog(
            text: text,
            cancelButtonTitle: localizationUtil.no,
            confirmButtonTitle: localizationUtil.yes,
          ));
  if (result == null) {
    return false;
  }
  return result;
}

Future<bool> showContinueDialog(BuildContext context, String text,
    {String? confirmButtonTitle}) async {
  final localizationUtil = LocalizationUtil.of(context);
  if (confirmButtonTitle == null) {
    confirmButtonTitle = localizationUtil.continueText;
  }
  final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => _ConfirmDialog(
            text: text,
            cancelButtonTitle: localizationUtil.cancel,
            confirmButtonTitle: confirmButtonTitle!,
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

  _ConfirmDialog(
      {required this.text,
      required this.cancelButtonTitle,
      required this.confirmButtonTitle});

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
