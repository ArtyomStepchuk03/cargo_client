import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';

export 'package:manager_mobile_client/src/logic/core/location.dart';

class Waypoint extends Identifiable<String> {
  String? id;
  LatLng? coordinate;
  num? speed;
  DateTime? date;

  Waypoint();

  static const className = 'Waypoint';

  static Waypoint? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Waypoint();
    decoded.id = decoder.decodeId();
    decoded.coordinate = decoder.decodeCoordinate('coordinate');
    decoded.speed = decoder.decodeNumber('speed');
    decoded.date = decoder.decodeDate('date');
    return decoded;
  }
}
