import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/transport_unit_server_api.dart';

export 'package:manager_mobile_client/src/logic/server_api/transport_unit_server_api.dart';

class TransportUnitDataSource implements SkipPagedDataSource<TransportUnit> {
  final TransportUnitServerAPI serverAPI;
  final TransportUnitStatus status;
  final Carrier carrier;

  TransportUnitDataSource(this.serverAPI, this.status, [this.carrier]);

  Future<List<TransportUnit>> list(int skip, int limit) async {
    return await serverAPI.list(status, skip, limit, carrier);
  }

  @override
  bool operator==(dynamic other) {
    if (other is! TransportUnitDataSource) {
      return false;
    }
    final TransportUnitDataSource otherSource = other;
    return status == otherSource.status;
  }

  @override
  int get hashCode => status?.hashCode;
}
