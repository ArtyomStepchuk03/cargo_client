import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/attachment/multiple_attachment_form_group.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/driver.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class DriverCreateInformation {
  String name;
  Carrier carrier;
  List<File> files;
}

class AddDriverPage extends StatefulWidget {
  final Carrier carrier;

  AddDriverPage({this.carrier});

  @override
  State<StatefulWidget> createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  final _formKey = GlobalKey<ScrollableFormState>();
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _attachmentFormGroupKey = GlobalKey<MultipleAttachmentFormGroupState>();

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newDriver),
        actions: _buildActions(context),
      ),
      body: buildForm(key: _formKey, children: [
        buildFormGroup([
          buildFormRow(
            Icons.person,
            CustomTextFormField(
              key: _nameKey,
              initialValue: '',
              label: localizationUtil.personName,
              validator: RequiredValidator(context),
            ),
          ),
        ]),
        MultipleAttachmentFormGroup(key: _attachmentFormGroupKey),
      ]),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final createInformation = validate();
    if (createInformation != null) {
      showActivityDialog(context, localizationUtil.saving);

      final serverAPI = DependencyHolder.of(context).network.serverAPI;

      try {
        final driver = Driver();
        driver.name = createInformation.name;
        driver.carrier = createInformation.carrier;

        if (createInformation.files != null) {
          driver.attachedDocuments = [];
          for (final file in createInformation.files) {
            final remoteFile = await serverAPI.files.createImage(file);
            driver.attachedDocuments.add(remoteFile);
          }
        }

        await serverAPI.drivers.create(driver);

        Navigator.pop(context);
        Navigator.pop(context, driver);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  DriverCreateInformation validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final createInformation = DriverCreateInformation();
    createInformation.name = _nameKey.currentState.value;
    if (_attachmentFormGroupKey.currentState.files.isNotEmpty) {
      createInformation.files = _attachmentFormGroupKey.currentState.files;
    }
    createInformation.carrier = widget.carrier;
    return createInformation;
  }
}
