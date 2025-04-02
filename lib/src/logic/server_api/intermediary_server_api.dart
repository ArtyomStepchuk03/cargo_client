import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/intermediary.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/intermediary.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class IntermediaryServerAPI implements SkipPagedDataSource<Intermediary> {
  final ServerManager serverManager;

  IntermediaryServerAPI(this.serverManager);

  Future<List<Intermediary>> list(int skip, int limit) async {
    final builder = parse.QueryBuilder(Intermediary.className);
    builder.equalTo('deleted', false);
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server!);
    return results
        .map((json) => Intermediary.decode(Decoder(json)))
        .whereType<Intermediary>()
        .toList();
  }

  @override
  bool operator ==(dynamic other) => other is IntermediaryServerAPI;

  @override
  int get hashCode => super.hashCode;
}
