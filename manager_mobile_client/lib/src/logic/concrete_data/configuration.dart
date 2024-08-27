import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';

class Configuration {
  String minimumVersion;
  num maximumEntranceDeviation;
  List<Supplier> suppliers;

  Configuration();

  static const className = 'Configuration';

  factory Configuration.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Configuration();
    decoded.minimumVersion = decoder.decodeString('minimumManagerAppVersion');
    decoded.maximumEntranceDeviation = decoder.decodeNumber('maxDistanceDifference');
    decoded.suppliers = decoder.decodeObjectList('supplierOrder', (Decoder decoder) => Supplier.decode(decoder))?.excludeDeleted();
    return decoded;
  }
}
