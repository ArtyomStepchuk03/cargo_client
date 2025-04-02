import 'package:flutter/material.dart';

Widget buildVerifyPermitField(String text) {
  return _buildVerifyField(
    text: text,
    color: Colors.green,
  );
}

Widget buildVerifyWarningField(String text) {
  return _buildVerifyField(
    text: text,
    color: Colors.orange,
  );
}

Widget buildVerifyErrorField(String text) {
  return _buildVerifyField(
    text: text,
    color: Colors.red,
  );
}

Widget _buildVerifyField({required String text, Color? color}) {
  return Container(
    decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.black),
        )),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Text(text),
    ),
  );
}
