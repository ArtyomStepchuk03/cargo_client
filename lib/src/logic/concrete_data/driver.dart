import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';

import 'carrier.dart';

export 'carrier.dart';

class Driver extends Identifiable<String> {
  String? id;
  String? name;
  String? phoneNumber;
  Carrier? carrier;
  List<RemoteFile>? attachedDocuments;
  bool? internal;

  static const className = 'Driver';

  static Driver? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Driver();
    decoded.id = decoder.decodeId();
    decoded.name = decoder.decodeString('name');
    decoded.phoneNumber = decoder.decodeString('phoneNumber');
    decoded.carrier = Carrier.decode(decoder.getDecoder('carrier'));
    decoded.internal = decoder.decodeBooleanDefault('internal');
    return decoded;
  }

  void encode(Encoder encoder) {
    encoder.encodeString('name', name);
    encoder.encodePointer('carrier', Carrier.className, carrier?.id);
    encoder.encodeList(
        'attachedDocuments',
        attachedDocuments,
        (ListEncoder listEncoder, RemoteFile? file) =>
            listEncoder.addFile(file));
  }
}
