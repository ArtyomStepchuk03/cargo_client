import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_manager.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

import 'utility.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class TransportUnitServerAPI {
  final ServerManager serverManager;

  TransportUnitServerAPI(this.serverManager);

  Future<List<TransportUnit>> list(
      TransportUnitStatus? status, int skip, int limit,
      [Carrier? carrier]) async {
    final builder = parse.QueryBuilder(TransportUnit.className);
    builder.equalTo('disbanded', false);

    if (status != null) {
      builder.equalTo('status', status.index);
    }
    if (carrier != null) {
      _driverMatchesCarrier(builder, carrier);
    }

    builder.includeAll(_getBaseIncludes());
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');

    final results = await builder.find(serverManager.server!);
    return results
        .map((json) => TransportUnit.decode(Decoder(json)))
        .whereType<TransportUnit>()
        .toList();
  }

  Future<List<TransportUnit?>> listForMap(TransportUnitStatus? status,
      [Carrier? carrier]) async {
    final builder = parse.QueryBuilder(TransportUnit.className);
    builder.equalTo('disbanded', false);
    builder.exists('coordinate');

    if (status != null) {
      builder.equalTo('status', status.index);
    }
    if (carrier != null) {
      _driverMatchesCarrier(builder, carrier);
    }

    builder.include('driver');
    builder.include('vehicle');

    builder.limit(1000);

    final results = await builder.find(serverManager.server!);
    return results
        .map((json) => TransportUnit.decode(Decoder(json)))
        .whereType<TransportUnit>()
        .toList();
  }

  Future<TransportUnit> create(
      Driver? driver, Vehicle? vehicle, Trailer? trailer) async {
    final parameters = <String, dynamic>{};
    parameters['driverId'] = driver?.id;
    parameters['vehicleId'] = vehicle?.id;
    if (trailer != null) {
      parameters['trailerId'] = trailer.id;
    }
    final result = await callCloudFunction(
        serverManager.server!, 'Dispatcher_makeTransportUnit', parameters);
    final id = result['id'];
    if (id is! String) {
      throw InvalidResponseException();
    }
    final data = await parse.getById(
        serverManager.server!, TransportUnit.className, id,
        include: _getBaseIncludes());
    final transportUnit = TransportUnit.decode(Decoder(data));
    if (transportUnit == null) {
      throw InvalidResponseException();
    }
    return transportUnit;
  }

  Future<void> fetch(TransportUnit transportUnit) async {
    final data = await parse.getById(
        serverManager.server!, TransportUnit.className, transportUnit.id,
        include: _getBaseIncludes());
    final fetchedTransportUnit = TransportUnit.decode(Decoder(data));
    if (fetchedTransportUnit == null) {
      return;
    }
    transportUnit.assign(fetchedTransportUnit);
  }

  Future<void> disband(TransportUnit? transportUnit) async {
    final parameters = {
      'transportUnitId': transportUnit?.id,
    };
    await callCloudFunction(
        serverManager.server!, 'Dispatcher_disbandTransportUnit', parameters);
  }

  parse.LiveQuerySubscription<TransportUnit?> subscribeToChanges(
          TransportUnit transportUnit) =>
      serverManager.liveQueryManager!.subscribeToObjectChanges(
          TransportUnit.className,
          transportUnit.id!,
          (decoder) => TransportUnit.decode(decoder));
  void unsubscribe(parse.LiveQuerySubscription<TransportUnit?> subscription) =>
      serverManager.liveQueryManager?.unsubscribe(subscription);

  void _driverMatchesCarrier(parse.QueryBuilder queryBuilder, Carrier carrier) {
    final driverQueryBuilder = parse.QueryBuilder(Driver.className);
    driverQueryBuilder.equalToObject('carrier', Carrier.className, carrier.id);
    queryBuilder.matchesQuery('driver', driverQueryBuilder);
  }

  List<String> _getBaseIncludes() {
    return [
      'driver',
      'vehicle',
      'vehicle.model',
      'vehicle.model.brand',
      'trailer',
    ];
  }
}
