import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/article_shape.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/article_shape.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class ArticleShapeServerAPI implements SkipPagedDataSource<ArticleShape> {
  final ServerManager serverManager;

  ArticleShapeServerAPI(this.serverManager);

  Future<List<ArticleShape>> list(int skip, int limit) async {
    final builder = parse.QueryBuilder(ArticleShape.className);
    builder.equalTo('deleted', false);
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server!);
    return results
        .map((json) => ArticleShape.decode(Decoder(json)))
        .whereType<ArticleShape>()
        .toList();
  }

  @override
  bool operator ==(dynamic other) => other is ArticleShapeServerAPI;

  @override
  int get hashCode => super.hashCode;
}
