import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/article_brand.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/article_brand.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class ArticleBrandServerAPI implements SkipPagedDataSource<ArticleBrand> {
  final ServerManager serverManager;

  ArticleBrandServerAPI(this.serverManager);

  Future<List<ArticleBrand>> list(int skip, int limit,
      [ArticleType? type]) async {
    final builder = parse.QueryBuilder(ArticleBrand.className);
    builder.equalTo('deleted', false);
    if (type != null) {
      builder.equalToObject('type', ArticleType.className, type.id);
    }
    builder.include('type');
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server!);
    return results
        .map((json) => ArticleBrand.decode(Decoder(json)))
        .whereType<ArticleBrand>()
        .toList();
  }

  @override
  bool operator ==(dynamic other) => other is ArticleBrandServerAPI;

  @override
  int get hashCode => super.hashCode;
}
