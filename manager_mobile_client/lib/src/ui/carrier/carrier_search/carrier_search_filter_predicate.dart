import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'package:manager_mobile_client/src/logic/core/search_predicate.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/carrier.dart';

class CarrierSearchFilterPredicate implements FilterPredicate<Carrier> {
  final String query;

  CarrierSearchFilterPredicate(this.query);

  bool call(Carrier object) {
    return satisfiesQuery(object.name, query);
  }
}
