import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

import 'loading_point.dart';
import 'unloading_point.dart';

export 'loading_point.dart';
export 'unloading_point.dart';

class Distance {
  LoadingPoint? loadingPoint;
  UnloadingPoint? unloadingPoint;
  num? distance;

  Distance();

  static const className = 'Distance';

  static Distance? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = Distance();
    decoded.loadingPoint =
        LoadingPoint.decode(decoder.getDecoder('loadingPoint'));
    decoded.unloadingPoint =
        UnloadingPoint.decode(decoder.getDecoder('unloadingPoint'));
    decoded.distance = decoder.decodeNumber('distance');
    return decoded;
  }
}
