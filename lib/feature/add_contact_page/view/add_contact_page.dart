import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/contact/contact_form_rows.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class AddContactPage extends StatefulWidget {
  final UnloadingPoint? unloadingPoint;

  AddContactPage({this.unloadingPoint});

  @override
  State<StatefulWidget> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<ScrollableFormState>();

  final _contactNameKey = GlobalKey<FormFieldState<String>>();
  final _contactPhoneNumberKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newContact),
        actions: [
          IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
        ],
      ),
      body: buildForm(key: _formKey, children: [
        buildFormGroup([
          buildContactNameFormRow(context,
              key: _contactNameKey,
              validator: RequiredValidator(context),
              autofocus: true),
          buildContactPhoneNumberFormRow(context,
              key: _contactPhoneNumberKey,
              validator: RequiredValidator(context)),
        ]),
      ]),
    );
  }

  void _save(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final contact = validate();
    if (contact == null) {
      return;
    }
    showActivityDialog(context, localizationUtil.saving);
    final serverAPI =
        DependencyHolder.of(context).network.serverAPI.unloadingPoints;
    try {
      await serverAPI.addContact(widget.unloadingPoint, contact);
      Navigator.pop(context);
      Navigator.pop(context, contact);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  Contact? validate() {
    if (_formKey.currentState?.validate() != true) {
      return null;
    }
    return Contact(
      name: _contactNameKey.currentState?.value,
      phoneNumber: _contactPhoneNumberKey.currentState?.value,
    );
  }
}
