import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'vehicle.dart';

export 'carrier.dart';

class Trailer extends Identifiable<String> {
  String id;
  String number;
  num tonnage;
  VehicleAdmissionData admissionData;
  Carrier carrier;

  Trailer();

  static const className = 'Trailer';

  factory Trailer.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Trailer();
    decoded.id = decoder.decodeId();
    decoded.number = decoder.decodeString('number');
    decoded.tonnage = decoder.decodeNumber('tonnage');
    decoded.admissionData = VehicleAdmissionData.decode(decoder.decodeMap('admissionData'));
    decoded.carrier = Carrier.decode(decoder.getDecoder('carrier'));
    return decoded;
  }

  void encode(Encoder encoder) {
    encoder.encodeString('number', number);
    encoder.encodeNumber('tonnage', tonnage);
    encoder.encodePointer('carrier', Carrier.className, carrier.id);
  }
}
