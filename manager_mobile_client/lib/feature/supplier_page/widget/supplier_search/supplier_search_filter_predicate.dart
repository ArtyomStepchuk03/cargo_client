import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'package:manager_mobile_client/src/logic/core/search_predicate.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';

class SupplierSearchFilterPredicate implements FilterPredicate<Supplier> {
  final String query;

  SupplierSearchFilterPredicate(this.query);

  bool call(Supplier object) {
    if (satisfiesQuery(object.name, query)) {
      return true;
    }
    if (satisfiesQuery(object.itn, query)) {
      return true;
    }
    return false;
  }
}
