import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/driver.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/form/attachment/multiple_attachment_form_group.dart';
import 'package:manager_mobile_client/src/ui/validators/common_validators.dart';
import 'package:manager_mobile_client/src/ui/common/common_strings.dart' as strings;

class DriverCreateInformation {
  String name;
  Carrier carrier;
  List<File> files;
}

class DriverAddBody extends StatefulWidget {
  final Carrier carrier;

  DriverAddBody({Key key, this.carrier}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DriverAddBodyState();
}

class DriverAddBodyState extends State<DriverAddBody> {
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

  @override
  Widget build(BuildContext context) {
    return buildForm(key: _formKey, children: [
      _buildMainGroup(),
      MultipleAttachmentFormGroup(key: _attachmentFormGroupKey),
    ]);
  }

  final _formKey = GlobalKey<ScrollableFormState>();
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _attachmentFormGroupKey = GlobalKey<MultipleAttachmentFormGroupState>();

  Widget _buildMainGroup() {
    return buildFormGroup([
      buildFormRow(Icons.person,
        CustomTextFormField(key: _nameKey, initialValue: '', label: strings.personName, validator: RequiredValidator())
      ),
    ]);
  }
}
