import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

enum TripStage {
  drivingForLoading,
  inLoadingPoint,
  loaded,
  drivingForUnloading,
  inUnloadingPoint,
  unloaded
}

class TripHistoryAdditionalData {
  final num distance;
  final String waybillNumber;

  TripHistoryAdditionalData({this.distance, this.waybillNumber});

  factory TripHistoryAdditionalData.decode(Map<String, dynamic> data) {
    if (data == null) return null;
    return TripHistoryAdditionalData(
      distance: data['kilometers'],
      waybillNumber: data['waybillNumber'],
    );
  }
}

class TripHistoryRecord extends Identifiable<String> {
  String id;
  TripStage stage;
  DateTime date;
  LatLng coordinate;
  String comment;
  RemoteFile photo;
  RemoteFile thumbnail;
  String address;
  num tonnage;
  TripHistoryAdditionalData additionalData;
  bool ignoreWrongCoordinate;

  TripHistoryRecord();

  static const className = 'TripHistoryRecord';

  factory TripHistoryRecord.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = TripHistoryRecord();
    decoded.id = decoder.decodeId();
    decoded.stage = decoder.decodeEnumeration('stage', TripStage.values);
    decoded.date = decoder.decodeDate('date');
    decoded.coordinate = decoder.decodeCoordinate('coordinate');
    decoded.comment = decoder.decodeString('comment');
    decoded.photo = decoder.decodeFile('photo');
    decoded.thumbnail = decoder.decodeFile('thumbnail');
    decoded.address = decoder.decodeString('address');
    decoded.tonnage = decoder.decodeNumber('tonnage');
    decoded.additionalData = TripHistoryAdditionalData.decode(decoder.decodeMap('additionalData'));
    decoded.ignoreWrongCoordinate = decoder.decodeBooleanDefault('ignoreWrongCoordinate');
    return decoded;
  }
}
