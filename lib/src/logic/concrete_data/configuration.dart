import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';

class Configuration {
  String? minimumVersion;
  num? maximumEntranceDeviation;
  List<Supplier?>? suppliers;

  Configuration();

  static const className = 'Configuration';

  static Configuration? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Configuration();
    decoded.minimumVersion = decoder.decodeString('minimumManagerAppVersion');
    decoded.maximumEntranceDeviation =
        decoder.decodeNumber('maxDistanceDifference');
    decoded.suppliers = decoder.decodeObjectList(
        'supplierOrder', (Decoder decoder) => Supplier.decode(decoder));
    return decoded;
  }
}
