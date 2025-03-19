import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';

import 'contact.dart';
import 'entrance.dart';
import 'manager.dart';
import 'vehicle.dart';

export 'contact.dart';
export 'entrance.dart';

class UnloadingPoint extends Identifiable<String> implements DeletionMarking {
  String? id;
  String? address;
  List<Contact?>? contacts;
  List<Entrance?>? entrances;
  VehicleEquipment? equipmentRequirements;
  Manager? manager;
  bool? deleted;

  UnloadingPoint();

  void assign(UnloadingPoint other) {
    id = other.id;
    address = other.address;
    contacts = other.contacts;
    entrances = other.entrances;
    equipmentRequirements = other.equipmentRequirements;
    manager = other.manager;
    deleted = other.deleted;
  }

  static const className = 'UnloadingPoint';

  static UnloadingPoint? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = UnloadingPoint();
    decoded.id = decoder.decodeId();
    decoded.address = decoder.decodeString('address');
    decoded.contacts =
        decoder.decodeMapList('contacts', (data) => Contact.decode(data));
    decoded.entrances = decoder.decodeObjectList(
        'entrances', (Decoder decoder) => Entrance.decode(decoder));
    decoded.equipmentRequirements =
        VehicleEquipment.decode(decoder.decodeMap('equipmentRequirements'));
    decoded.manager = Manager.decode(decoder.getDecoder('manager'));
    decoded.deleted = decoder.decodeBooleanDefault('deleted');
    return decoded;
  }

  void encode(Encoder encoder) {
    encoder.encodeString('address', address);
  }
}
