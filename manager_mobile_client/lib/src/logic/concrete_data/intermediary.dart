import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

class Intermediary extends Identifiable<String> {
  String id;
  String name;

  Intermediary();

  static const className = 'Intermediary';

  factory Intermediary.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Intermediary();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    return decoded;
  }
}
