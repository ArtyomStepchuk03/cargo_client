import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'package:manager_mobile_client/src/logic/data_source/limited_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/article_brand_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/carrier_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/supplier_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/loading_point_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/unloading_point_server_api.dart';

export 'package:manager_mobile_client/src/logic/server_api/article_brand_server_api.dart';
export 'package:manager_mobile_client/src/logic/server_api/carrier_server_api.dart';
export 'package:manager_mobile_client/src/logic/server_api/supplier_server_api.dart';
export 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
export 'package:manager_mobile_client/src/logic/server_api/loading_point_server_api.dart';
export 'package:manager_mobile_client/src/logic/server_api/unloading_point_server_api.dart';

class ArticleBrandDataSource implements SkipPagedDataSource<ArticleBrand> {
  final ArticleBrandServerAPI serverAPI;
  final ArticleType type;

  ArticleBrandDataSource(this.serverAPI, this.type);

  Future<List<ArticleBrand>> list(int skip, int limit) async {
    return await serverAPI.list(skip, limit, type);
  }

  @override
  bool operator==(dynamic other) {
    if (other is! ArticleBrandDataSource) {
      return false;
    }
    final ArticleBrandDataSource otherSource = other;
    return type == otherSource.type;
  }

  @override
  int get hashCode => type?.hashCode;
}

class SupplierDataSource implements SkipPagedDataSource<Supplier> {
  final SupplierServerAPI serverAPI;
  final bool transfer;

  SupplierDataSource(this.serverAPI, this.transfer);

  Future<List<Supplier>> list(int skip, int limit) async {
    return await serverAPI.list(skip, limit, transfer: transfer);
  }

  @override
  bool operator==(dynamic other) {
    if (other is! SupplierDataSource) {
      return false;
    }
    final SupplierDataSource otherSource = other;
    return transfer == otherSource.transfer;
  }

  @override
  int get hashCode => transfer.hashCode;
}

class AllowedCustomerDataSource implements LimitedDataSource<Customer> {
  final CarrierServerAPI carrierServerAPI;
  final Carrier carrier;

  AllowedCustomerDataSource(this.carrierServerAPI, this.carrier);

  Future<List<Customer>> list() async {
    await carrierServerAPI.fetchCustomers(carrier);
    if (carrier.customers == null) {
      return [];
    }
    return carrier.customers;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! AllowedCustomerDataSource) {
      return false;
    }
    final AllowedCustomerDataSource otherSource = other;
    return carrier == otherSource.carrier;
  }

  @override
  int get hashCode => carrier?.hashCode;
}

class AllowedSupplierDataSource implements LimitedDataSource<Supplier> {
  final CarrierServerAPI carrierServerAPI;
  final Carrier carrier;

  AllowedSupplierDataSource(this.carrierServerAPI, this.carrier);

  Future<List<Supplier>> list() async {
    await carrierServerAPI.fetchSuppliers(carrier);
    if (carrier.suppliers == null) {
      return [];
    }
    return carrier.suppliers;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! AllowedSupplierDataSource) {
      return false;
    }
    final AllowedSupplierDataSource otherSource = other;
    return carrier == otherSource.carrier;
  }

  @override
  int get hashCode => carrier?.hashCode;
}

class TransferSupplierPredicate implements FilterPredicate<Supplier> {
  final bool transfer;

  TransferSupplierPredicate(this.transfer);

  bool call(Supplier object) => object.transfer == transfer;

  @override
  bool operator==(dynamic other) {
    if (other is! TransferSupplierPredicate) {
      return false;
    }
    final TransferSupplierPredicate otherPredicate = other;
    return transfer == otherPredicate.transfer;
  }

  @override
  int get hashCode => transfer.hashCode;
}

class SupplierArticleTypeDataSource implements LimitedDataSource<ArticleType> {
  final SupplierServerAPI supplierServerAPI;
  final Supplier supplier;

  SupplierArticleTypeDataSource(this.supplierServerAPI, this.supplier);

  Future<List<ArticleType>> list() async {
    await supplierServerAPI.fetchArticleBrands(supplier);
    if (supplier.articleBrands == null) {
      return [];
    }
    return supplier.articleBrands.map((brand) => brand.type).toSet().toList();
  }

  @override
  bool operator==(dynamic other) {
    if (other is! SupplierArticleTypeDataSource) {
      return false;
    }
    final SupplierArticleTypeDataSource otherSource = other;
    return supplier == otherSource.supplier;
  }

  @override
  int get hashCode => supplier?.hashCode;
}

class SupplierArticleBrandDataSource implements LimitedDataSource<ArticleBrand> {
  final SupplierServerAPI supplierServerAPI;
  final Supplier supplier;

  SupplierArticleBrandDataSource(this.supplierServerAPI, this.supplier);

  Future<List<ArticleBrand>> list() async {
    await supplierServerAPI.fetchArticleBrands(supplier);
    if (supplier.articleBrands == null) {
      return [];
    }
    return supplier.articleBrands;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! SupplierArticleBrandDataSource) {
      return false;
    }
    final SupplierArticleBrandDataSource otherSource = other;
    return supplier == otherSource.supplier;
  }

  @override
  int get hashCode => supplier?.hashCode;
}

class UnloadingContactDataSource implements LimitedDataSource<Contact> {
  final UnloadingPointServerAPI unloadingPointServerAPI;
  final UnloadingPoint unloadingPoint;

  UnloadingContactDataSource(this.unloadingPointServerAPI, this.unloadingPoint);

  Future<List<Contact>> list() async {
    await unloadingPointServerAPI.fetch(unloadingPoint);
    if (unloadingPoint.contacts == null) {
      return [];
    }
    return unloadingPoint.contacts;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! UnloadingContactDataSource) {
      return false;
    }
    final UnloadingContactDataSource otherSource = other;
    return unloadingPoint == otherSource.unloadingPoint;
  }

  @override
  int get hashCode => unloadingPoint?.hashCode;
}

class LoadingPointDataSource implements LimitedDataSource<LoadingPoint> {
  final SupplierServerAPI supplierServerAPI;
  final Supplier supplier;

  LoadingPointDataSource(this.supplierServerAPI, this.supplier);

  Future<List<LoadingPoint>> list() async {
    await supplierServerAPI.fetchLoadingPoints(supplier);
    if (supplier.loadingPoints == null) {
      return [];
    }
    return supplier.loadingPoints;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! LoadingPointDataSource) {
      return false;
    }
    final LoadingPointDataSource otherSource = other;
    return supplier == otherSource.supplier;
  }

  @override
  int get hashCode => supplier?.hashCode;
}

class UnloadingPointDataSource implements LimitedDataSource<UnloadingPoint> {
  final CustomerServerAPI customerServerAPI;
  final Customer customer;

  UnloadingPointDataSource(this.customerServerAPI, this.customer);

  Future<List<UnloadingPoint>> list() async {
    await customerServerAPI.fetchUnloadingPoints(customer);
    if (customer.unloadingPoints == null) {
      return [];
    }
    return customer.unloadingPoints;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! UnloadingPointDataSource) {
      return false;
    }
    final UnloadingPointDataSource otherSource = other;
    return customer == otherSource.customer;
  }

  @override
  int get hashCode => customer?.hashCode;
}

class LoadingEntranceDataSource implements LimitedDataSource<Entrance> {
  final LoadingPointServerAPI loadingPointServerAPI;
  final LoadingPoint loadingPoint;

  LoadingEntranceDataSource(this.loadingPointServerAPI, this.loadingPoint);

  Future<List<Entrance>> list() async {
    await loadingPointServerAPI.fetchEntrances(loadingPoint);
    if (loadingPoint.entrances == null) {
      return [];
    }
    return loadingPoint.entrances;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! LoadingEntranceDataSource) {
      return false;
    }
    final LoadingEntranceDataSource otherSource = other;
    return loadingPoint == otherSource.loadingPoint;
  }

  @override
  int get hashCode => loadingPoint?.hashCode;
}

class UnloadingEntranceDataSource implements LimitedDataSource<Entrance> {
  final UnloadingPointServerAPI unloadingPointServerAPI;
  final UnloadingPoint unloadingPoint;

  UnloadingEntranceDataSource(this.unloadingPointServerAPI, this.unloadingPoint);

  Future<List<Entrance>> list() async {
    await unloadingPointServerAPI.fetchEntrances(unloadingPoint);
    if (unloadingPoint.entrances == null) {
      return [];
    }
    return unloadingPoint.entrances;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! UnloadingEntranceDataSource) {
      return false;
    }
    final UnloadingEntranceDataSource otherSource = other;
    return unloadingPoint == otherSource.unloadingPoint;
  }

  @override
  int get hashCode => unloadingPoint?.hashCode;
}
