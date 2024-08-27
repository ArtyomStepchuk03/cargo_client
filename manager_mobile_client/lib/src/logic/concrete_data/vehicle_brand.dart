import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

class VehicleBrand extends Identifiable<String> {
  String id;
  String name;

  VehicleBrand();

  static const className = 'VehicleBrand';

  factory VehicleBrand.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = VehicleBrand();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    return decoded;
  }
}
