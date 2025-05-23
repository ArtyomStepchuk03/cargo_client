import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'package:manager_mobile_client/src/logic/core/search_predicate.dart';

class CustomerSearchFilterPredicate implements FilterPredicate<Customer> {
  final String query;

  CustomerSearchFilterPredicate(this.query);

  bool call(Customer object) =>
      satisfiesQuery(object.name, query) || satisfiesQuery(object.itn, query);
}
