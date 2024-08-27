import 'package:manager_mobile_client/src/logic/data_source/combined_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';

export 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';

DataSource<Order> makeOrderDataSource({OrderServerAPI serverAPI, User user, OrderSort sort, OrderFilter filter}) {
  if (!filter.deleted && sort.sortType == OrderSortType.byDefault) {
    if (filter.progress == null) {
      return CombinedDataSource([
        _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: OrderFilter.notFullyDistributed(OrderOfferingStatus.none), sort: sort),
        _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: OrderFilter.notFullyDistributed(OrderOfferingStatus.carriersOnly), sort: sort),
        _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: OrderFilter.notFullyDistributed(OrderOfferingStatus.drivers), sort: sort),
        _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: OrderFilter.notFullyFinished(), sort: sort),
        _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: OrderFilter.fullyFinished(), sort: sort),
      ]);
    }
    if (filter.progress == OrderProgress.notFullyDistributed) {
      return CombinedDataSource([
        _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: OrderFilter.notFullyDistributed(OrderOfferingStatus.none), sort: sort),
        _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: OrderFilter.notFullyDistributed(OrderOfferingStatus.carriersOnly), sort: sort),
        _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: OrderFilter.notFullyDistributed(OrderOfferingStatus.drivers), sort: sort),
      ]);
    }
  }
  return _PlainOrderDataSource(serverAPI: serverAPI, user: user, filter: filter, sort: sort);
}

class _PlainOrderDataSource implements DataSource<Order> {
  final OrderServerAPI serverAPI;
  final User user;
  final OrderFilter filter;
  final OrderSort sort;

  _PlainOrderDataSource({this.serverAPI, this.user, this.filter, this.sort});

  Future<DataPortion<Order>> loadPortion(dynamic token, int suggestedLimit) async {
    DateTime sortDate = token;
    final items = await serverAPI.list(user, sortDate, suggestedLimit, filter: filter, sort: sort);
    if (items.length < suggestedLimit) {
      return DataPortion.finished(items);
    }

    DateTime nextToken = this.sort.sortType == OrderSortType.byDefault ? items.last.lastProgressDate : items.last.unloadingBeginDate;
    return DataPortion(items, nextPortionToken: nextToken);
  }

  @override
  bool operator==(dynamic other) {
    if (other is! _PlainOrderDataSource) {
      return false;
    }
    final _PlainOrderDataSource otherSource = other;
    return filter == otherSource.filter && sort == otherSource.sort;
  }

  @override
  int get hashCode => filter.hashCode + sort.hashCode;
}
