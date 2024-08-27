import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/contact.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/validators/required_validator.dart';
import 'package:manager_mobile_client/src/ui/common/form/contact/contact_form_rows.dart';

class ContactAddBody extends StatefulWidget {
  ContactAddBody({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ContactAddBodyState();
}

class ContactAddBodyState extends State<ContactAddBody> {
  Contact validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    return Contact(
      name: _contactNameKey.currentState.value,
      phoneNumber: _contactPhoneNumberKey.currentState.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildForm(key: _formKey, children: [
      buildFormGroup([
        buildContactNameFormRow(key: _contactNameKey, validator: RequiredValidator(), autofocus: true),
        buildContactPhoneNumberFormRow(key: _contactPhoneNumberKey, validator: RequiredValidator()),
      ]),
    ]);
  }

  final _formKey = GlobalKey<ScrollableFormState>();

  final _contactNameKey = GlobalKey<FormFieldState<String>>();
  final _contactPhoneNumberKey = GlobalKey<FormFieldState<String>>();
}
