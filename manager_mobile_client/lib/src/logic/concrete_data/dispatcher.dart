import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

class Dispatcher extends Identifiable<String> {
  String id;
  String name;

  Dispatcher();

  static const className = 'Dispatcher';

  factory Dispatcher.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Dispatcher();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    return decoded;
  }
}
