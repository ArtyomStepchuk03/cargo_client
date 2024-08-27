import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/fixed_items_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/map_data_source.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/validators/required_validator.dart';
import 'package:manager_mobile_client/src/ui/customer/customer_verify/customer_verify_widget.dart';
import 'package:manager_mobile_client/src/ui/customer/customer_add/customer_add_widget.dart';
import 'package:manager_mobile_client/src/ui/order/order_details/order_details_form_fields.dart';
import 'package:manager_mobile_client/src/ui/order/order_details/order_details_data_sources.dart';
import 'reservation_details_strings.dart' as strings;

export 'package:manager_mobile_client/src/ui/order/order_details/order_details_form_fields.dart';

class ReservationCustomerAssignment {
  final Customer customer;

  ReservationCustomerAssignment(this.customer);
  ReservationCustomerAssignment.unassigned() : customer = null;

  @override
  bool operator==(dynamic other) {
    if (other is! ReservationCustomerAssignment) {
      return false;
    }
    final ReservationCustomerAssignment otherCustomerAssignment = other;
    return customer == otherCustomerAssignment.customer;
  }

  @override
  int get hashCode => customer?.hashCode;
}

Widget buildReservationCustomerFormField({
  DependencyState dependencyState,
  Key key,
  ReservationCustomerAssignment initialValue,
  User user,
  ValueChanged<ReservationCustomerAssignment> onChanged,
  bool enabled = true,
}) {
  if (user.role == Role.dispatcher && !user.carrier.showAllCustomers) {
    return _buildReservationCustomerFormField(
      key: key,
      initialValue: initialValue,
      user: user,
      dataSource: LimitedDataSourceAdapter(CachedLimitedDataSource(
        AllowedCustomerDataSource(dependencyState.network.serverAPI.carriers, user.carrier),
        dependencyState.caches.allowedCustomer.getCache(user.carrier),
      )),
      onChanged: onChanged,
      onRefresh: () => dependencyState.caches.allowedCustomer.getCache(user.carrier).clear(),
      enabled: enabled,
    );
  }
  return _buildReservationCustomerFormField(
    key: key,
    initialValue: initialValue,
    user: user,
    dataSource: SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(
      dependencyState.network.serverAPI.customers,
      dependencyState.caches.customer,
    )),
    onChanged: onChanged,
    onRefresh: dependencyState.caches.customer.clear,
    enabled: enabled,
  );
}

class ReservationCustomerSearchPredicate implements SearchPredicate<ReservationCustomerAssignment> {
  bool call(ReservationCustomerAssignment object, String query) {
    if (object.customer == null) {
      return false;
    }
    return _base.call(object.customer, query);
  }
  final _base = CustomerSearchPredicate();
}

Widget _buildReservationCustomerFormField({
  Key key,
  ReservationCustomerAssignment initialValue,
  User user,
  DataSource<Customer> dataSource,
  ValueChanged<ReservationCustomerAssignment> onChanged,
  VoidCallback onRefresh,
  bool enabled = true,
}) {
  return LoadingListFormField<ReservationCustomerAssignment>(
    key: key,
    initialValue: initialValue,
    dataSource: FixedItemsDataSource(
      MapDataSource(dataSource, (customer) => ReservationCustomerAssignment(customer)),
      [if (user.role != Role.dispatcher) ReservationCustomerAssignment.unassigned()],
    ),
    searchPredicate: ReservationCustomerSearchPredicate(),
    formatter: (customerAssignment) {
      if (customerAssignment == null) {
        return '';
      }
      if (customerAssignment.customer == null) {
        return strings.unassignedReservation;
      }
      return short.formatCustomerSafe(customerAssignment.customer);
    },
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, ReservationCustomerAssignment customerAssignment) {
      if (customerAssignment.customer == null) {
        return SimpleListTile(strings.unassignedReservation);
      }
      return SimpleListTile(customerAssignment.customer.name, customerAssignment.customer.itn, customerAssignment.customer.internal ? null : Icons.keyboard_arrow_right);
    },
    onChanged: onChanged,
    onRefresh: onRefresh,
    onSelect: (BuildContext context, ReservationCustomerAssignment customerAssignment) async {
      if (customerAssignment.customer == null || customerAssignment.customer.internal) {
        Navigator.pop(context, customerAssignment);
      } else {
        final accepted = await Navigator.push(context, MaterialPageRoute(
          builder: (BuildContext context) => CustomerVerifyWidget(customerAssignment.customer),
        ));
        if (accepted != null && accepted) {
          Navigator.pop(context, customerAssignment);
        }
      }
    },
    onAdd: (BuildContext context) async {
      final customer = await Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => CustomerAddWidget(manager: user.manager),
        fullscreenDialog: true,
      ));
      return ReservationCustomerAssignment(customer);
    },
    label: strings.customer,
    validator: RequiredValidator(),
    enabled: enabled,
  );
}
