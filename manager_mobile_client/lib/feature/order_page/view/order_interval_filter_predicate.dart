import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';

class OrderIntervalFilterPredicate implements FilterPredicate<Order> {
  final DateTime begin;
  final DateTime end;

  OrderIntervalFilterPredicate(this.begin, this.end);

  bool call(Order object) {
    if (begin != null && object.createdAt.compareTo(begin) < 0) {
      return false;
    }
    if (end != null && object.createdAt.compareTo(end) >= 0) {
      return false;
    }
    return true;
  }
}
