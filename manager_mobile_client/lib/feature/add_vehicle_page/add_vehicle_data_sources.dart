import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/vehicle_model_server_api.dart';

export 'package:manager_mobile_client/src/logic/server_api/vehicle_model_server_api.dart';

class VehicleModelDataSource implements SkipPagedDataSource<VehicleModel> {
  final VehicleModelServerAPI serverAPI;
  final VehicleBrand brand;

  VehicleModelDataSource(this.serverAPI, this.brand);

  Future<List<VehicleModel>> list(int skip, int limit) async {
    return await serverAPI.list(skip, limit, brand);
  }

  @override
  bool operator==(dynamic other) {
    if (other is! VehicleModelDataSource) {
      return false;
    }
    final VehicleModelDataSource otherSource = other;
    return brand == otherSource.brand;
  }

  @override
  int get hashCode => brand?.hashCode;
}
