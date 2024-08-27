import 'package:manager_mobile_client/src/logic/core/safe_cast.dart';
import 'package:manager_mobile_client/src/logic/core/remote_file.dart';
import 'package:manager_mobile_client/src/logic/parse/constants.dart';

RemoteFile fileFromJson(Map<String, dynamic> json) {
  if (json == null) {
    return null;
  }
  final name = safeCast<String>(json['name']);
  final url = safeCast<String>(json['url']);
  if (name == null || url == null) {
    return null;
  }
  return RemoteFile(name, url);
}

Map<String, dynamic> jsonFromFile(RemoteFile file) {
  return {
    typeKey: 'File',
    'name': file.name,
    'url': file.url
  };
}
