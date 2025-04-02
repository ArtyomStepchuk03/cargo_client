import 'package:manager_mobile_client/src/logic/parse/constants.dart';

Map<String, dynamic>? jsonForPointer(String className, String? id) {
  if (id == null) {
    return null;
  }
  return {typeKey: 'Pointer', 'className': className, idKey: id};
}
