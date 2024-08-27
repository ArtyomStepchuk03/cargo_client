import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/carrier.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/carrier.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class CarrierServerAPI implements SkipPagedDataSource<Carrier> {
  final ServerManager serverManager;

  CarrierServerAPI(this.serverManager);

  Future<List<Carrier>> list(int skip, int limit) async {
    final builder = parse.QueryBuilder(Carrier.className);
    builder.equalTo('deleted', false);
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server);
    return results.map((json) => Carrier.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  Future<void> fetchSuppliers(Carrier carrier) async {
    final fetched = await parse.getById(serverManager.server, Carrier.className, carrier.id, include: ['suppliers']);
    if (fetched == null) {
      throw RequestFailedException();
    }
    carrier.suppliers = Decoder(fetched).decodeObjectList('suppliers', (Decoder decoder) => Supplier.decode(decoder))?.excludeDeleted();
  }

  Future<void> fetchCustomers(Carrier carrier) async {
    final fetched = await parse.getById(serverManager.server, Carrier.className, carrier.id, include: ['customers']);
    if (fetched == null) {
      throw RequestFailedException();
    }
    carrier.customers = Decoder(fetched).decodeObjectList('customers', (Decoder decoder) => Customer.decode(decoder))?.excludeDeleted();
  }

  @override
  bool operator==(dynamic other) => other is CarrierServerAPI;

  @override
  int get hashCode => super.hashCode;
}
