import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/trip.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/waypoint.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_manager.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_api/utility.dart';
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/trip.dart';
export 'package:manager_mobile_client/src/logic/concrete_data/waypoint.dart';

class TripServerAPI {
  final ServerManager serverManager;

  TripServerAPI(this.serverManager);

  Future<List<Waypoint>> listWaypoints(Trip trip) async {
    final builder = parse.QueryBuilder(Waypoint.className);
    builder.equalToObject('trip', Trip.className, trip.id);
    builder.addAscending('index');

    final results = await builder.findAll(serverManager.server);
    return results
        .map((json) => Waypoint.decode(Decoder(json)))
        .where((decoded) => decoded != null)
        .toList();
  }

  Future<void> ignoreCoordinateMismatch(TripHistoryRecord historyRecord) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    encoder.encodeBoolean('ignoreWrongCoordinate', true);
    await parse.update(serverManager.server, TripHistoryRecord.className,
        historyRecord.id, data);
    historyRecord.ignoreWrongCoordinate = true;
  }

  Future<void> deletePhoto(TripHistoryRecord tripHistoryRecord) async {
    final parameters = {
      'recordId': tripHistoryRecord.id,
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_deleteTripHistoryImage', parameters);
  }

  Future<void> updatePhoto(
      TripHistoryRecord tripHistoryRecord, String base64Image) async {
    final parameters = {
      'recordId': tripHistoryRecord.id,
      'image': base64Image,
    };
    await callCloudFunction(
        serverManager.server, 'Dispatcher_changeTripHistoryImage', parameters);
  }

  parse.LiveQuerySubscription<Trip> subscribeToChanges(Trip trip) =>
      serverManager.liveQueryManager.subscribeToObjectChanges(
          Trip.className, trip.id, (decoder) => Trip.decode(decoder));
  void unsubscribe(parse.LiveQuerySubscription<Trip> subscription) =>
      serverManager.liveQueryManager.unsubscribe(subscription);
}
