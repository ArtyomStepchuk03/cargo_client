import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';

export 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';

class CustomerDataSource implements SkipPagedDataSource<Customer> {
  final CustomerServerAPI? serverAPI;
  final Manager? manager;
  final bool? includeDeleted;

  CustomerDataSource(
      {this.serverAPI, this.manager, this.includeDeleted = false});

  Future<List<Customer>> list(int skip, int limit) async {
    return await serverAPI!
        .list(skip, limit, manager: manager, includeDeleted: includeDeleted!);
  }

  @override
  bool operator ==(dynamic other) => other is CustomerDataSource;

  @override
  int get hashCode => includeDeleted.hashCode;
}
