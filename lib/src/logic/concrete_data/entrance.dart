import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';

export 'package:manager_mobile_client/src/logic/core/location.dart';

class Entrance extends Identifiable<String> implements DeletionMarking {
  String? id;
  String? name;
  String? address;
  LatLng? coordinate;
  bool? deleted;

  Entrance();

  static const className = 'Entrance';

  static Entrance? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Entrance();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    decoded.address = decoder.decodeString('address');
    decoded.coordinate = decoder.decodeCoordinate('coordinate');
    decoded.deleted = decoder.decodeBooleanDefault('deleted');
    return decoded;
  }

  void encode(Encoder encoder) {
    encoder.encodeString('name', name!);
    encoder.encodeString('address', address!);
    encoder.encodeCoordinate('coordinate', coordinate!);
  }
}
