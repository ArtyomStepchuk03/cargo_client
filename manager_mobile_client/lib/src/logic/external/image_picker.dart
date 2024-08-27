import 'dart:io';
import 'package:image_picker/image_picker.dart';

export 'package:image_picker/image_picker.dart';

Future<File> pickImage(ImagePicker imagePicker) async {
  final internalFile = await imagePicker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 612,
    maxHeight: 816,
  );
  if (internalFile == null) {
    return null;
  }
  return File(internalFile.path);
}
