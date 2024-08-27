import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/purchase_tariff.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_card.dart';
import 'reservation_list_strings.dart' as strings;

export 'package:tuple/tuple.dart';

extension PurchaseTariffMap on Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> {
  static Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> build(List<PurchaseTariff> purchaseTariffs) {
    var map = <Tuple3<ArticleBrand, Supplier, LoadingPoint>, num>{};
    for (final purchaseTariff in purchaseTariffs) {
      final key = Tuple3(purchaseTariff.articleBrand, purchaseTariff.supplier, purchaseTariff.loadingPoint);
      final existingValue = map[key];
      if (existingValue != null) {
        map[key] = max(existingValue, purchaseTariff.tariff);
      } else {
        map[key] = purchaseTariff.tariff;
      }
    }
    return map;
  }

  num getTariff(Order order) {
    final key = Tuple3(order.articleBrand, order.supplier, order.loadingPoint);
    return this[key];
  }
}

Widget buildSupplierReservationSummary(List<Order> reservations, {Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap}) {
  return Wrap(
    children: [
      _buildGroupReservationCountWidget(reservations),
      _buildSpacing(),
      _buildGroupTotalTonnageWidget(reservations),
      _buildSpacing(),
      _buildGroupTotalPurchasePriceWidget(reservations, purchaseTariffMap),
    ],
  );
}

Widget buildArticleReservationSummary(List<Order> reservations, {List<Order> reservationsDayBefore}) {
  return Wrap(
    children: [
      _buildGroupReservationCountWidget(reservations),
      _buildSpacing(),
      _buildGroupTotalTonnageWidget(reservations),
      _buildSpacing(),
      _buildGroupRemainCountWidget(reservationsDayBefore),
    ],
  );
}

Widget buildReservationsCountWidget(Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap) {
  return ListCardField(name: strings.reservationsCount, value: '${_getReservationCountInReservationMap(reservationMap)}');
}

Widget buildTotalPurchasePriceWidget(Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap, Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap) {
  return ListCardField(name: strings.totalPrice, value: '${_getTotalPurchasePriceInReservationMap(reservationMap, purchaseTariffMap)}');
}

Widget _buildGroupReservationCountWidget(List<Order> reservations) {
  return _buildText(strings.groupReservationsCount('${reservations.length}'));
}

Widget _buildGroupTotalTonnageWidget(List<Order> reservations) {
  return _buildText(strings.groupTotalTonnage('${_getTotalTonnage(reservations)}'));
}

Widget _buildGroupTotalPurchasePriceWidget(List<Order> reservations, Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap) {
  return _buildText(strings.groupTotalPrice('${_getTotalPurchasePrice(reservations, purchaseTariffMap)}'));
}

Widget _buildGroupRemainCountWidget(List<Order> reservationsDayBefore) {
  return _buildText(strings.groupRemainCount('${_getRemainCount(reservationsDayBefore)}'));
}

Widget _buildText(String text) => Text(text, style: TextStyle(fontSize: 13));
Widget _buildSpacing() => SizedBox(width: 4);

int _getReservationCountInReservationMap(Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap) {
  return reservationMap.values.fold(0, (previousValue, supplierReservationMap) {
    return previousValue + supplierReservationMap.values.fold(0, (supplierPreviousValue, reservations) => supplierPreviousValue + reservations.length);
  });
}

num _getTotalTonnage(List<Order> reservations) {
  return reservations.fold(0, (previousValue, reservation) => previousValue + reservation.tonnage);
}

num _getTotalPurchasePrice(List<Order> reservations, Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap) {
  return reservations.fold(0, (previousValue, reservation) {
    final purchaseTariff = purchaseTariffMap.getTariff(reservation) ?? 0;
    final purchasePrice = reservation.tonnage * purchaseTariff;
    return previousValue + purchasePrice;
  });
}

num _getTotalPurchasePriceInReservationMap(Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap, Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap) {
  return reservationMap.values.fold(0, (previousValue, supplierReservationMap) {
    return previousValue + supplierReservationMap.values.fold(0, (supplierPreviousValue, reservations) => supplierPreviousValue + _getTotalPurchasePrice(reservations, purchaseTariffMap));
  });
}

num _getRemainCount(List<Order> reservationsDayBefore) {
  return reservationsDayBefore.where((reservation) {
    return !reservation.hasTripOnMinimumStage(TripStage.loaded);
  }).length;
}
