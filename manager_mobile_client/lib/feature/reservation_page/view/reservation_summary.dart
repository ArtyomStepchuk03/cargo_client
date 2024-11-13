import 'dart:math';

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/purchase_tariff.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:tuple/tuple.dart';

export 'package:tuple/tuple.dart';

extension PurchaseTariffMap
    on Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> {
  static Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> build(
      List<PurchaseTariff> purchaseTariffs) {
    var map = <Tuple3<ArticleBrand, Supplier, LoadingPoint>, num>{};
    for (final purchaseTariff in purchaseTariffs) {
      final key = Tuple3(purchaseTariff.articleBrand, purchaseTariff.supplier,
          purchaseTariff.loadingPoint);
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

Widget buildSupplierReservationSummary(
    BuildContext context, List<Order> reservations,
    {Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num>
        purchaseTariffMap}) {
  return Wrap(
    children: [
      _buildGroupReservationCountWidget(context, reservations),
      _buildSpacing(),
      _buildGroupTotalTonnageWidget(context, reservations),
      _buildSpacing(),
      _buildGroupTotalPurchasePriceWidget(
          context, reservations, purchaseTariffMap),
    ],
  );
}

Widget buildArticleReservationSummary(
    BuildContext context, List<Order> reservations,
    {List<Order> reservationsDayBefore}) {
  return Wrap(
    children: [
      _buildGroupReservationCountWidget(context, reservations),
      _buildSpacing(),
      _buildGroupTotalTonnageWidget(context, reservations),
      _buildSpacing(),
      _buildGroupRemainCountWidget(context, reservationsDayBefore),
    ],
  );
}

Widget buildReservationsCountWidget(BuildContext context,
    Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap) {
  final localizationUtil = LocalizationUtil.of(context);
  return ListCardField(
      name: localizationUtil.reservationsCount,
      value: '${_getReservationCountInReservationMap(reservationMap)}');
}

Widget buildTotalPurchasePriceWidget(
    BuildContext context,
    Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap,
    Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap) {
  final localizationUtil = LocalizationUtil.of(context);
  return ListCardField(
      name: localizationUtil.totalPrice,
      value:
          '${_getTotalPurchasePriceInReservationMap(reservationMap, purchaseTariffMap)}');
}

Widget _buildGroupReservationCountWidget(
    BuildContext context, List<Order> reservations) {
  final localizationUtil = LocalizationUtil.of(context);
  return _buildText('${localizationUtil.requests}: ${reservations.length}');
}

Widget _buildGroupTotalTonnageWidget(
    BuildContext context, List<Order> reservations) {
  final localizationUtil = LocalizationUtil.of(context);
  return _buildText(
      '${localizationUtil.tonnage}: ${_getTotalTonnage(reservations)}');
}

Widget _buildGroupTotalPurchasePriceWidget(
    BuildContext context,
    List<Order> reservations,
    Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap) {
  final localizationUtil = LocalizationUtil.of(context);
  return _buildText(
      '${localizationUtil.total}: ${_getTotalPurchasePrice(reservations, purchaseTariffMap)}');
}

Widget _buildGroupRemainCountWidget(
    BuildContext context, List<Order> reservationsDayBefore) {
  final localizationUtil = LocalizationUtil.of(context);
  return _buildText(
      '${localizationUtil.leftOvers}: ${_getRemainCount(reservationsDayBefore)}');
}

Widget _buildText(String text) => Text(text, style: TextStyle(fontSize: 13));
Widget _buildSpacing() => SizedBox(width: 4);

int _getReservationCountInReservationMap(
    Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap) {
  return reservationMap.values.fold(0, (previousValue, supplierReservationMap) {
    return previousValue +
        supplierReservationMap.values.fold(
            0,
            (supplierPreviousValue, reservations) =>
                supplierPreviousValue + reservations.length);
  });
}

num _getTotalTonnage(List<Order> reservations) {
  return reservations.fold(
      0, (previousValue, reservation) => previousValue + reservation.tonnage);
}

num _getTotalPurchasePrice(List<Order> reservations,
    Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap) {
  return reservations.fold(0, (previousValue, reservation) {
    final purchaseTariff = purchaseTariffMap.getTariff(reservation) ?? 0;
    final purchasePrice = reservation.tonnage * purchaseTariff;
    return previousValue + purchasePrice;
  });
}

num _getTotalPurchasePriceInReservationMap(
    Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap,
    Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap) {
  return reservationMap.values.fold(0, (previousValue, supplierReservationMap) {
    return previousValue +
        supplierReservationMap.values.fold(
            0,
            (supplierPreviousValue, reservations) =>
                supplierPreviousValue +
                _getTotalPurchasePrice(reservations, purchaseTariffMap));
  });
}

num _getRemainCount(List<Order> reservationsDayBefore) {
  return reservationsDayBefore.where((reservation) {
    return !reservation.hasTripOnMinimumStage(TripStage.loaded);
  }).length;
}
