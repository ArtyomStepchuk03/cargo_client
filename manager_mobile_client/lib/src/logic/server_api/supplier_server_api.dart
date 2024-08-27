import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/article_brand.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';
import 'contractor_verify_result.dart';
import 'utility.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
export 'contractor_verify_result.dart';

class SupplierServerAPI implements SkipPagedDataSource<Supplier> {
  final ServerManager serverManager;

  SupplierServerAPI(this.serverManager);

  Future<List<Supplier>> list(int skip, int limit, {bool transfer, bool includeDeleted = false}) async {
    final builder = parse.QueryBuilder(Supplier.className);
    if (!includeDeleted) {
      builder.equalTo('deleted', false);
    }
    if (transfer != null) {
      builder.equalTo('transfer', transfer);
    }
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server);
    return results.map((json) => Supplier.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  Future<List<Supplier>> listForMap() async {
    final builder = parse.QueryBuilder(Supplier.className);
    builder.equalTo('deleted', false);
    builder.include('loadingPoints');
    builder.include('loadingPoints.entrances');
    final results = await builder.findAll(serverManager.server);
    return results.map((json) => Supplier.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  Future<void> fetchArticleBrands(Supplier supplier) async {
    final fetched = await parse.getById(serverManager.server, Supplier.className, supplier.id, include: ['articleBrands.type']);
    if (fetched == null) {
      throw RequestFailedException();
    }
    supplier.articleBrands = Decoder(fetched).decodeObjectList('articleBrands', (Decoder decoder) => ArticleBrand.decode(decoder))?.excludeDeleted();
  }

  Future<void> fetchLoadingPoints(Supplier supplier) async {
    final fetched = await parse.getById(serverManager.server, Supplier.className, supplier.id, include: ['loadingPoints']);
    if (fetched == null) {
      throw RequestFailedException();
    }
    supplier.loadingPoints = Decoder(fetched).decodeObjectList('loadingPoints', (Decoder decoder) => LoadingPoint.decode(decoder))?.excludeDeleted();
  }

  Future<ContractorVerifyResult> verify(Supplier supplier) async {
    final parameters = {
      'supplierId': supplier.id,
    };
    final resultData = await callCloudFunction(serverManager.server, 'Dispatcher_verifySupplier', parameters);
    final result = ContractorVerifyResultDecode.decode(resultData);
    if (result == null) {
      throw InvalidResponseException();
    }
    return result;
  }

  @override
  bool operator==(dynamic other) => other is SupplierServerAPI;

  @override
  int get hashCode => super.hashCode;
}
