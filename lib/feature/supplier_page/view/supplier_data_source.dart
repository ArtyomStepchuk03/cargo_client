import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/supplier_server_api.dart';

export 'package:manager_mobile_client/src/logic/server_api/supplier_server_api.dart';

class SupplierDataSource implements SkipPagedDataSource<Supplier> {
  final SupplierServerAPI serverAPI;
  final bool includeDeleted;

  SupplierDataSource({required this.serverAPI, this.includeDeleted = false});

  Future<List<Supplier>> list(int skip, int limit) async {
    return await serverAPI.list(skip, limit, includeDeleted: includeDeleted);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! SupplierDataSource) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => includeDeleted.hashCode;
}
