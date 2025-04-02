import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';

import 'entrance.dart';

export 'entrance.dart';

class LoadingPoint extends Identifiable<String> implements DeletionMarking {
  String? id;
  String? address;
  List<Entrance?>? entrances;
  bool? deleted;

  LoadingPoint();

  static const className = 'LoadingPoint';

  static LoadingPoint? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = LoadingPoint();
    decoded.id = decoder.decodeId();
    decoded.address = decoder.decodeString('address');
    decoded.entrances = decoder.decodeObjectList(
        'entrances', (Decoder decoder) => Entrance.decode(decoder));
    decoded.deleted = decoder.decodeBooleanDefault('deleted');
    return decoded;
  }
}
