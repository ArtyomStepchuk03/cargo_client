import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/src/logic/external/image_picker.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class AttachmentFormGroup extends StatefulWidget {
  final String buttonTitle;
  final String notAttachedText;

  AttachmentFormGroup(
      {Key? key, required this.buttonTitle, required this.notAttachedText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AttachmentFormGroupState();
}

class AttachmentFormGroupState extends State<AttachmentFormGroup> {
  File? get file => _file;

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
          null,
          buildButton(
            context,
            child: Text(widget.buttonTitle),
            onPressed: _attachFile,
          )),
      buildFormRow(
        null,
        _file != null ? Image.file(_file!) : Text(widget.notAttachedText),
        buildButton(
          context,
          child: Text(localizationUtil.remove),
          onPressed: () => _file != null ? _removeFile : null,
        ),
      ),
    ]);
  }

  File? _file;
  final _imagePicker = ImagePicker();

  void _attachFile() async {
    final file = await pickImage(_imagePicker);
    setState(() => _file = file);
  }

  void _removeFile() {
    setState(() => _file = null);
  }
}
