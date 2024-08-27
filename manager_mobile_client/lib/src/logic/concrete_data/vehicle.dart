import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'vehicle_model.dart';
import 'carrier.dart';

export 'vehicle_model.dart';
export 'carrier.dart';

class VehicleEquipment {
  final bool compressor;

  VehicleEquipment({this.compressor = false});

  factory VehicleEquipment.decode(Map<String, dynamic> data) {
    if (data == null) return VehicleEquipment();
    return VehicleEquipment(compressor: data['compressor'] ?? false);
  }
}

class VehicleAdmissionData {
  final DateTime inspectionEndDate;
  final DateTime mtplEndDate;

  VehicleAdmissionData({this.inspectionEndDate, this.mtplEndDate});

  factory VehicleAdmissionData.decode(Map<String, dynamic> data) {
    if (data == null) return null;
    return VehicleAdmissionData(
      inspectionEndDate: data['inspectionEndDate'] != null ? DateTime.tryParse(data['inspectionEndDate']) : null,
      mtplEndDate: data['mtplEndDate'] != null ? DateTime.tryParse(data['mtplEndDate']) : null,
    );
  }
}

enum VehiclePassMoscowZone {
  gardenRing,
  thirdRingRoad,
  mkad,
}

enum VehiclePassTimeOfAction {
  day,
  night,
}

class VehiclePass {
  final String city;
  final VehiclePassMoscowZone zone;
  final VehiclePassTimeOfAction timeOfAction;
  final DateTime beginDate;
  final DateTime endDate;
  final bool canceled;

  VehiclePass({this.city, this.zone, this.timeOfAction, this.beginDate, this.endDate, this.canceled});

  factory VehiclePass.decode(Map<String, dynamic> data) {
    if (data == null) return null;
    return VehiclePass(
      city: data['city'],
      zone: validateEnumeration(data['zone'], VehiclePassMoscowZone.values),
      timeOfAction: enumerationFromString(data['timeOfAction'], VehiclePassTimeOfAction.values),
      beginDate: data['beginDate'] != null ? DateTime.tryParse(data['beginDate']) : null,
      endDate: data['endDate'] != null ? DateTime.tryParse(data['endDate']) : null,
      canceled: data['canceled']
    );
  }
}

class Vehicle extends Identifiable<String> {
  String id;
  String number;
  VehicleModel model;
  num tonnage;
  VehicleAdmissionData admissionData;
  List<VehiclePass> passes;
  Carrier carrier;

  Vehicle();

  static const className = 'Vehicle';

  factory Vehicle.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = Vehicle();
    decoded.id = decoder.decodeId();
    decoded.number = decoder.decodeString('number');
    decoded.model = VehicleModel.decode(decoder.getDecoder('model'));
    decoded.tonnage = decoder.decodeNumber('tonnage');
    decoded.admissionData = VehicleAdmissionData.decode(decoder.decodeMap('admissionData'));
    decoded.passes = decoder.decodeMapList('passes', (data) => VehiclePass.decode(data));
    decoded.carrier = Carrier.decode(decoder.getDecoder('carrier'));
    return decoded;
  }

  void encode(Encoder encoder) {
    encoder.encodeString('number', number);
    encoder.encodePointer('model', VehicleModel.className, model.id);
    encoder.encodeNumber('tonnage', tonnage);
    encoder.encodePointer('carrier', Carrier.className, carrier.id);
  }
}
