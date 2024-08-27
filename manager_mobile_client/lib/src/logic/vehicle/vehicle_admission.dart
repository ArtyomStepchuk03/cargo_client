import 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';

class VehicleAdmissionProblems {
  final bool vehicleInspectionExpired;
  final bool trailerInspectionExpired;
  final bool mtplExpired;
  final bool passExpired;
  final bool passCanceled;
  VehicleAdmissionProblems({this.vehicleInspectionExpired, this.trailerInspectionExpired, this.mtplExpired, this.passExpired, this.passCanceled});
  bool get hasProblems => vehicleInspectionExpired || trailerInspectionExpired || mtplExpired || passExpired || passCanceled;
}

extension VehicleAdmission on TransportUnit {
  VehicleAdmissionProblems checkAdmission(DateTime dateTime) {
    return VehicleAdmissionProblems(
      vehicleInspectionExpired: vehicle.admissionData?.inspectionEndDate?.isBefore(dateTime) ?? false,
      trailerInspectionExpired: trailer?.admissionData?.inspectionEndDate?.isBefore(dateTime) ?? false,
      mtplExpired: vehicle.admissionData?.mtplEndDate?.isBefore(dateTime) ?? false,
      passExpired: vehicle.passes?.any((pass) => pass.endDate?.isBefore(dateTime) ?? false) ?? false,
      passCanceled: vehicle.passes?.any((pass) => pass.canceled ?? false) ?? false,
    );
  }
}
