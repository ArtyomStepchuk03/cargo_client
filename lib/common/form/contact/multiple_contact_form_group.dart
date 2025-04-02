import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/contact.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'contact_form_rows.dart';

class MultipleContactFormGroup extends StatefulWidget {
  final List<Contact?> contacts;

  MultipleContactFormGroup(this.contacts);

  @override
  State<StatefulWidget> createState() => MultipleContactFormGroupState();
}

class MultipleContactFormGroupState extends State<MultipleContactFormGroup> {
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    if (widget.contacts.isEmpty) {
      children.add(buildContactNameFormRow(context, enabled: false));
      children.add(buildContactPhoneNumberFormRow(context, enabled: false));
    } else {
      final firstContact = widget.contacts.first;
      children.add(buildContactNameFormRow(context,
          initialValue: firstContact?.name, enabled: false));
      children.add(buildContactPhoneNumberFormRow(context,
          initialValue: firstContact?.phoneNumber, enabled: false));

      if (widget.contacts.length > 1) {
        if (_expanded) {
          for (var counter = 1; counter < widget.contacts.length; ++counter) {
            final contact = widget.contacts[counter];
            children.add(SizedBox(height: 8));
            children.add(buildContactNameFormRow(context,
                initialValue: contact?.name, enabled: false));
            children.add(buildContactPhoneNumberFormRow(context,
                initialValue: contact?.phoneNumber, enabled: false));
          }
        } else {
          children.add(_buildShowAllButton());
        }
      }
    }

    return buildFormGroup(children);
  }

  var _expanded = false;

  Widget _buildShowAllButton() {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormRow(
        null,
        buildButton(
          context,
          child: Text(localizationUtil.showAll),
          onPressed: _showAll,
        ));
  }

  void _showAll() {
    setState(() => _expanded = true);
  }
}
