import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'package:manager_mobile_client/src/logic/core/search_predicate.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/ui/format/stage.dart';

class OrderSearchFilterPredicate implements FilterPredicate<Order> {
  final User user;
  final String query;

  OrderSearchFilterPredicate(this.user, this.query);

  bool call(Order object) {
    if (satisfiesQuery('${object.number}', query)) {
      return true;
    }
    if (satisfiesQuery(object.customer.name, query)) {
      return true;
    }
    if (satisfiesQuery(object.unloadingPoint.address, query)) {
      return true;
    }
    if (satisfiesQuery(formatOrderStatus(object, user), query)) {
      return true;
    }
    if (object.offers != null && object.offers.isNotEmpty) {
      if (satisfiesQuery(object.offers[0].transportUnit?.driver?.name, query)) {
        return true;
      }
    } else if (object.carriers != null && object.carriers.isNotEmpty) {
      if (satisfiesQuery(object.carriers[0].name, query)) {
        return true;
      }
    }
    return false;
  }
}
