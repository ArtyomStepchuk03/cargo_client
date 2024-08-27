import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'vehicle_brand.dart';

export 'vehicle_brand.dart';

class VehicleModel extends Identifiable<String> {
  String id;
  VehicleBrand brand;
  String name;

  VehicleModel();

  static const className = 'VehicleModel';

  factory VehicleModel.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = VehicleModel();
    decoded.id = decoder.decodeId();
    decoded.brand = VehicleBrand.decode(decoder.getDecoder('brand'));
    decoded.name = decoder.decodeString('name');
    return decoded;
  }
}
