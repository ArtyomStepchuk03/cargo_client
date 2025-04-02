import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';

import 'driver.dart';
import 'trailer.dart';
import 'vehicle.dart';

export 'driver.dart';
export 'trailer.dart';
export 'vehicle.dart';

enum TransportUnitStatus {
  notReady,
  ready,
  breakage,
  invisible,
  working,
  resting,
  underRepair,
}

class TransportUnit extends Identifiable<String> {
  String? id;
  Driver? driver;
  Vehicle? vehicle;
  Trailer? trailer;
  bool? application;
  TransportUnitStatus? status;
  DateTime? lastVisitDate;
  LatLng? coordinate;
  num? speed;

  TransportUnit();

  void assign(TransportUnit other) {
    id = other.id;
    driver = other.driver;
    vehicle = other.vehicle;
    trailer = other.trailer;
    application = other.application;
    status = other.status;
    lastVisitDate = other.lastVisitDate;
    coordinate = other.coordinate;
    speed = other.speed;
  }

  static const className = 'TransportUnit';

  static TransportUnit? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = TransportUnit();
    decoded.id = decoder.decodeId();
    decoded.driver = Driver.decode(decoder.getDecoder('driver'));
    decoded.vehicle = Vehicle.decode(decoder.getDecoder('vehicle'));
    decoded.trailer = Trailer.decode(decoder.getDecoder('trailer'));
    decoded.application = decoder.decodeBooleanDefault('application', true);
    decoded.status =
        decoder.decodeEnumeration('status', TransportUnitStatus.values);
    decoded.lastVisitDate = decoder.decodeDate('lastVisitDate');
    decoded.coordinate = decoder.decodeCoordinate('coordinate');
    decoded.speed = decoder.decodeNumber('speed');
    return decoded;
  }
}
