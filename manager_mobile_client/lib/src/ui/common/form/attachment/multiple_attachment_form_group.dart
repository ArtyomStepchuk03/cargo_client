import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/external/image_picker.dart';
import 'package:manager_mobile_client/src/ui/common/button.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'attachment_strings.dart' as strings;

class MultipleAttachmentFormGroup extends StatefulWidget {
  MultipleAttachmentFormGroup({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MultipleAttachmentFormGroupState();
}

class MultipleAttachmentFormGroupState extends State<MultipleAttachmentFormGroup> {
  MultipleAttachmentFormGroupState() : _files = [];

  List<File> get files => _files;

  @override
  Widget build(BuildContext context) {
    return buildFormGroup([
      buildFormRow(null,
        buildButton(context,
          child: Text(strings.attachDocuments),
          onPressed: _attachDocument,
        ),
      ),
      buildFormRow(null,
        Text(strings.documentCount(_files.length)),
        buildButton(context,
          child: Text(strings.clear),
          onPressed: _files.isNotEmpty ? _clearAttachments : null,
        ),
      ),
    ]);
  }

  List<File> _files;
  final _imagePicker = ImagePicker();

  void _attachDocument() async {
    final file = await pickImage(_imagePicker);
    if (file != null) {
      setState(() => _files.add(file));
    }
  }

  void _clearAttachments() {
    setState(() => _files.clear());
  }
}
