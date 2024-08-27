import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

class Logistician extends Identifiable<String> {
  String id;
  String name;

  Logistician();

  static const className = 'Logistician';

  factory Logistician.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Logistician();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    return decoded;
  }
}
