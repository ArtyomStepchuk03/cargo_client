import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'transport_unit.dart';
import 'trip.dart';

export 'transport_unit.dart';
export 'trip.dart';

class Offer extends Identifiable<String> {
  String id;
  TransportUnit transportUnit;
  bool declined;
  Trip trip;
  bool isQueue;

  Offer();

  static const className = 'Offer';

  factory Offer.decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Offer();
    decoded.id = decoder.decodeId();
    decoded.transportUnit =
        TransportUnit.decode(decoder.getDecoder('transportUnit'));
    decoded.declined = decoder.decodeBooleanDefault('declined');
    decoded.trip = Trip.decode(decoder.getDecoder('trip'));
    decoded.isQueue = decoder.decodeString("queueStatus") == "queued";
    return decoded;
  }
}
