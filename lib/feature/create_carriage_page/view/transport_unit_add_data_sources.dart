import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/driver_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/trailer_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/vehicle_server_api.dart';

export 'package:manager_mobile_client/src/logic/server_api/driver_server_api.dart';
export 'package:manager_mobile_client/src/logic/server_api/trailer_server_api.dart';
export 'package:manager_mobile_client/src/logic/server_api/vehicle_server_api.dart';

class DriverDataSource implements SkipPagedDataSource<Driver> {
  final DriverServerAPI serverAPI;
  final Carrier carrier;

  DriverDataSource(this.serverAPI, this.carrier);

  Future<List<Driver>> list(int skip, int limit) async {
    return await serverAPI.listFree(skip, limit, carrier);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! DriverDataSource) {
      return false;
    }
    final DriverDataSource otherSource = other;
    return carrier == otherSource.carrier;
  }

  @override
  int get hashCode => carrier.hashCode;
}

class VehicleDataSource implements SkipPagedDataSource<Vehicle> {
  final VehicleServerAPI serverAPI;
  final Carrier? carrier;

  VehicleDataSource(this.serverAPI, this.carrier);

  Future<List<Vehicle>> list(int skip, int limit) async {
    return await serverAPI.listFree(skip, limit, carrier);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! VehicleDataSource) {
      return false;
    }
    final VehicleDataSource otherSource = other;
    return carrier == otherSource.carrier;
  }

  @override
  int get hashCode => carrier.hashCode;
}

class TrailerDataSource implements SkipPagedDataSource<Trailer> {
  final TrailerServerAPI serverAPI;
  final Carrier carrier;

  TrailerDataSource(this.serverAPI, this.carrier);

  Future<List<Trailer>> list(int skip, int limit) async {
    return await serverAPI.listFree(skip, limit, carrier);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! TrailerDataSource) {
      return false;
    }
    final TrailerDataSource otherSource = other;
    return carrier == otherSource.carrier;
  }

  @override
  int get hashCode => carrier.hashCode;
}
