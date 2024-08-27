import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

class Manager extends Identifiable<String> {
  String id;
  String name;
  String phoneNumber;

  Manager();

  static const className = 'Manager';

  factory Manager.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Manager();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    decoded.phoneNumber = decoder.decodeString('phoneNumber');
    return decoded;
  }
}
