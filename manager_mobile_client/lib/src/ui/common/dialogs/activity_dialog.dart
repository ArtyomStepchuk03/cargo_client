import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/common_strings.dart' as strings;

void showActivityDialog(BuildContext context, [String text]) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _ActivityDialog(text: text),
  );
}

void showDefaultActivityDialog(BuildContext context) => showActivityDialog(context, strings.processing);

class _ActivityDialog extends StatelessWidget {
  final String text;

  _ActivityDialog({this.text});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: CircularProgressIndicator()
              ),
            ),
            if (text != null) Text(text),
          ],
        ),
      ),
    );
  }
}
