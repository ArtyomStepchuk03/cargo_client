import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/external/phone_call.dart';
import 'package:manager_mobile_client/src/ui/common/form/noneditable_text_field.dart';

class PhoneNumberDialField extends StatefulWidget {
  final String phoneNumber;
  final String text;
  final String label;

  PhoneNumberDialField({this.phoneNumber, this.text, this.label});

  @override
  State<StatefulWidget> createState() => _PhoneNumberDialFieldState();
}

class _PhoneNumberDialFieldState extends State<PhoneNumberDialField> {
  @override
  Widget build(BuildContext context) {
    if (widget.phoneNumber == null || widget.phoneNumber.isEmpty) {
      return _buildTextField(context: context, enabled: false);
    }
    return InkWell(
      child: _buildTextField(context: context),
      onTap: _dial,
    );
  }

  Widget _buildTextField({BuildContext context, bool enabled = true}) {
    return buildCustomNoneditableTextField(
      context: context,
      text: widget.text ?? widget.phoneNumber ?? "",
      label: widget.label,
      icon: Icon(Icons.phone, color: enabled ? Theme.of(context).colorScheme.primary : null),
      enabled: enabled,
    );
  }

  void _dial() async {
    await callPhoneNumber(widget.phoneNumber);
  }
}
