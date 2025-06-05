import 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';
import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'package:manager_mobile_client/src/logic/core/search_predicate.dart';

class TransportUnitSearchFilterPredicate
    implements FilterPredicate<TransportUnit> {
  final String query;

  TransportUnitSearchFilterPredicate(this.query);

  bool call(TransportUnit object) {
    if (satisfiesQuery(object.driver?.name, query)) {
      return true;
    }
    if (satisfiesQuery(object.vehicle?.number, query)) {
      return true;
    }
    if (satisfiesQuery(object.trailer?.number, query)) {
      return true;
    }
    return false;
  }
}
