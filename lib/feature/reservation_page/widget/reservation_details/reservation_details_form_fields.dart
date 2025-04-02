import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_add/customer_add_widget.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_verify/customer_verify_widget.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_details/order_details_data_sources.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_details/order_details_form_fields.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/fixed_items_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/map_data_source.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/required_validator.dart';

class ReservationCustomerAssignment {
  final Customer? customer;

  ReservationCustomerAssignment(this.customer);
  ReservationCustomerAssignment.unassigned() : customer = null;

  @override
  bool operator ==(dynamic other) {
    if (other is! ReservationCustomerAssignment) {
      return false;
    }
    final ReservationCustomerAssignment otherCustomerAssignment = other;
    return customer == otherCustomerAssignment.customer;
  }

  @override
  int get hashCode => customer.hashCode;
}

Widget buildReservationCustomerFormField(
  BuildContext context, {
  required DependencyState dependencyState,
  Key? key,
  ReservationCustomerAssignment? initialValue,
  User? user,
  ValueChanged<ReservationCustomerAssignment?>? onChanged,
  bool enabled = true,
}) {
  if (user?.role == Role.dispatcher &&
      user?.carrier?.showAllCustomers == false) {
    return _buildReservationCustomerFormField(
      context,
      key: key,
      initialValue: initialValue,
      user: user,
      dataSource: LimitedDataSourceAdapter(CachedLimitedDataSource(
        AllowedCustomerDataSource(
            dependencyState.network.serverAPI.carriers, user!.carrier!),
        dependencyState.caches.allowedCustomer.getCache(user.carrier!),
      )),
      onChanged: onChanged,
      onRefresh: () => dependencyState.caches.allowedCustomer
          .getCache(user.carrier!)
          .clear(),
      enabled: enabled,
    );
  }
  return _buildReservationCustomerFormField(
    context,
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

class ReservationCustomerSearchPredicate
    implements SearchPredicate<ReservationCustomerAssignment> {
  bool call(ReservationCustomerAssignment object, String query) {
    if (object.customer == null) {
      return false;
    }
    return _base.call(object.customer!, query);
  }

  final _base = CustomerSearchPredicate();
}

Widget _buildReservationCustomerFormField(
  BuildContext context, {
  Key? key,
  ReservationCustomerAssignment? initialValue,
  User? user,
  DataSource<Customer>? dataSource,
  ValueChanged<ReservationCustomerAssignment?>? onChanged,
  VoidCallback? onRefresh,
  bool enabled = true,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<ReservationCustomerAssignment>(
    context,
    key: key,
    initialValue: initialValue,
    dataSource: FixedItemsDataSource(
      MapDataSource(
          dataSource, (customer) => ReservationCustomerAssignment(customer)),
      [
        if (user?.role != Role.dispatcher)
          ReservationCustomerAssignment.unassigned()
      ],
    ),
    searchPredicate: ReservationCustomerSearchPredicate(),
    formatter: (context, customerAssignment) {
      if (customerAssignment == null) {
        return '';
      }
      if (customerAssignment.customer == null) {
        return localizationUtil.unassignedReservation;
      }
      return short.formatCustomerSafe(context, customerAssignment.customer);
    },
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context,
        ReservationCustomerAssignment? customerAssignment) {
      if (customerAssignment?.customer == null) {
        return SimpleListTile(localizationUtil.unassignedReservation);
      }
      return SimpleListTile(
          customerAssignment?.customer?.name,
          customerAssignment?.customer?.itn,
          customerAssignment?.customer?.internal == true
              ? null
              : Icons.keyboard_arrow_right);
    },
    onChanged: onChanged,
    onRefresh: onRefresh,
    onSelect: (BuildContext context,
        ReservationCustomerAssignment customerAssignment) async {
      if (customerAssignment.customer == null ||
          customerAssignment.customer!.internal == true) {
        Navigator.pop(context, customerAssignment);
      } else {
        final accepted = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  CustomerVerifyWidget(customerAssignment.customer),
            ));
        if (accepted != null && accepted) {
          Navigator.pop(context, customerAssignment);
        }
      }
    },
    onAdd: (BuildContext context) async {
      final customer = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                CustomerAddWidget(manager: user?.manager),
            fullscreenDialog: true,
          ));
      return ReservationCustomerAssignment(customer);
    },
    label: localizationUtil.customer,
    validator: RequiredValidator(context),
    enabled: enabled,
  );
}
