import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';

import 'carrier.dart';

export 'carrier.dart';

class CarrierOffer extends Identifiable<String> {
  String? id;
  Carrier? carrier;
  bool? accepted;

  CarrierOffer();

  static const className = 'CarrierOffer';

  static CarrierOffer? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = CarrierOffer();
    decoded.id = decoder.decodeId();
    decoded.carrier = Carrier.decode(decoder.getDecoder('carrier'));
    decoded.accepted = decoder.decodeBoolean('accepted');
    return decoded;
  }
}
