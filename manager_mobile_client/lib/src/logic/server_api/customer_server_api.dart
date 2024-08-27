import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/manager.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';
import 'contractor_verify_result.dart';
import 'utility.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
export 'package:manager_mobile_client/src/logic/concrete_data/manager.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
export 'contractor_verify_result.dart';

class CustomerServerAPI implements SkipPagedDataSource<Customer> {
  final ServerManager serverManager;

  CustomerServerAPI(this.serverManager);

  Future<bool> exists(String name) async {
    final builder = parse.QueryBuilder(Customer.className);
    builder.equalTo('deleted', false);
    builder.equalTo('name', name);
    final count = await builder.count(serverManager.server);
    return count != 0;
  }

  Future<List<Customer>> list(int skip, int limit, {Manager manager, bool includeDeleted = false}) async {
    final builder = parse.QueryBuilder(Customer.className);
    if (!includeDeleted) {
      builder.equalTo('deleted', false);
    }
    if (manager != null) {
      final unloadingPointBuilder = parse.QueryBuilder(UnloadingPoint.className);
      unloadingPointBuilder.equalToObject('manager', Manager.className, manager.id);
      builder.matchesQuery('unloadingPoints', unloadingPointBuilder);
    }
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server);
    return results.map((json) => Customer.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  Future<void> fetchUnloadingPoints(Customer customer) async {
    final fetched = await parse.getById(serverManager.server, Customer.className, customer.id, include: ['unloadingPoints', 'unloadingPoints.manager']);
    if (fetched == null) {
      throw RequestFailedException();
    }
    customer.unloadingPoints = Decoder(fetched).decodeObjectList('unloadingPoints', (Decoder decoder) => UnloadingPoint.decode(decoder))?.excludeDeleted();
  }

  Future<void> create(Customer customer) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    customer.encode(encoder);
    final id = await parse.create(serverManager.server, Customer.className, data);
    customer.id = id;
    customer.internal = true;
    customer.deleted = false;
  }

  Future<void> addUnloadingPoint(Customer customer, UnloadingPoint unloadingPoint, Manager manager) async {
    final unloadingPointData = <String, dynamic>{};
    final unloadingPointEncoder = Encoder(unloadingPointData);
    if (manager != null) {
      unloadingPointEncoder.encodePointer('manager', Manager.className, manager.id);
    }
    unloadingPoint.encode(unloadingPointEncoder);

    final id = await parse.create(serverManager.server, UnloadingPoint.className, unloadingPointData);
    unloadingPoint.id = id;

    final customerData = <String, dynamic>{};
    final customerEncoder = Encoder(customerData);
    ListEncoder listEncoder = customerEncoder.getAddOperationListEncoder('unloadingPoints');
    listEncoder.addPointer(UnloadingPoint.className, unloadingPoint.id);

    await parse.update(serverManager.server, Customer.className, customer.id, customerData);
    if (customer.unloadingPoints != null) {
      customer.unloadingPoints.add(unloadingPoint);
    } else {
      customer.unloadingPoints = [unloadingPoint];
    }
  }

  Future<ContractorVerifyResult> verify(Customer customer) async {
    final parameters = {
      'customerId': customer.id,
    };
    final resultData = await callCloudFunction(serverManager.server, 'Dispatcher_verifyCustomer', parameters);
    final result = ContractorVerifyResultDecode.decode(resultData);
    if (result == null) {
      throw InvalidResponseException();
    }
    return result;
  }

  Future<ContractorVerifyResult> getStatus() async {
    final resultData = await callCloudFunction(serverManager.server, 'Customer_getStatus');
    final result = ContractorVerifyResultDecode.decode(resultData);
    if (result == null) {
      throw InvalidResponseException();
    }
    return result;
  }

  @override
  bool operator==(dynamic other) => other is CustomerServerAPI;

  @override
  int get hashCode => super.hashCode;
}
