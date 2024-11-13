import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/color.dart';
import 'package:manager_mobile_client/common/dialogs/outdated_version_dialog.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/reservation_page/widget/reservation_add/add_reservation_widget.dart';
import 'package:manager_mobile_client/feature/reservation_page/widget/reservation_details/reservation_details_widget.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
import 'package:manager_mobile_client/src/logic/core/date_utility.dart';
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_subscription.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';

import 'reservation_list_body_state.dart';
import 'reservation_list_cell.dart';
import 'reservation_summary.dart';

class SupplierGroupReservationListBody extends StatefulWidget {
  final Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMap;
  final Map<Supplier, Map<ArticleBrand, List<Order>>> reservationMapDayBefore;
  final Configuration configuration;
  final Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num>
      purchaseTariffMap;
  final User user;
  final DateTime date;

  SupplierGroupReservationListBody(this.reservationMap,
      {this.reservationMapDayBefore,
      this.configuration,
      this.purchaseTariffMap,
      this.user,
      this.date});

  factory SupplierGroupReservationListBody.fromList(
    List<Order> reservations, {
    List<Order> reservationsDayBefore,
    Configuration configuration,
    Map<Tuple3<ArticleBrand, Supplier, LoadingPoint>, num> purchaseTariffMap,
    User user,
    DateTime date,
  }) {
    var reservationMap = <Supplier, Map<ArticleBrand, List<Order>>>{};
    var reservationMapDayBefore = <Supplier, Map<ArticleBrand, List<Order>>>{};
    for (final reservation in reservations) {
      reservationMap.addReservation(reservation);
    }
    for (final reservation in reservationsDayBefore) {
      reservationMapDayBefore.addReservation(reservation);
    }
    return SupplierGroupReservationListBody(reservationMap,
        reservationMapDayBefore: reservationMapDayBefore,
        configuration: configuration,
        purchaseTariffMap: purchaseTariffMap,
        user: user,
        date: date);
  }

  @override
  State<StatefulWidget> createState() =>
      SupplierGroupReservationListBodyState();
}

class SupplierGroupReservationListBodyState
    extends State<SupplierGroupReservationListBody>
    implements ReservationListBodyState {
  void addReservation(Order reservation) {
    if (reservation.unloadingBeginDate.toLocal().beginningOfDay !=
        widget.date) {
      return;
    }
    setState(() {
      _reservationMap.addReservation(reservation, toBeginning: true);
      if (_reservationMap.getCount(
              reservation.supplier, reservation.articleBrand) ==
          1) {
        _expand(reservation);
      }
    });
  }

  void removeReservation(Order reservation) {
    setState(() => _reservationMap.removeReservation(reservation));
  }

  void updateReservation(Order reservation) {
    if (reservation.unloadingBeginDate.toLocal().beginningOfDay !=
        widget.date) {
      setState(() => _reservationMap.removeReservation(reservation));
      return;
    }
    setState(() {
      _reservationMap.replaceReservation(reservation);
      if (_reservationMap.getCount(
              reservation.supplier, reservation.articleBrand) ==
          1) {
        _expand(reservation);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _reservationMap = widget.reservationMap;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _supplierExpansionState = <Supplier, bool>{};
    _articleBrandExpansionState = <Tuple2<Supplier, ArticleBrand>, bool>{};
    if (_serverAPI == null) {
      _serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      _subscribe();
    }
  }

  @override
  void didUpdateWidget(covariant SupplierGroupReservationListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      _serverAPI.unsubscribe(_subscription);
      _subscribe();
    }
  }

  @override
  void dispose() {
    _serverAPI.unsubscribe(_subscription);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSupplierList(context),
          _buildTotalSummaryCell(context),
        ],
      ),
    );
  }

  Map<Supplier, Map<ArticleBrand, List<Order>>> _reservationMap;
  Map<Supplier, bool> _supplierExpansionState;
  Map<Tuple2<Supplier, ArticleBrand>, bool> _articleBrandExpansionState;
  OrderServerAPI _serverAPI;
  parse.LiveQuerySubscription<Order> _subscription;

  Widget _buildSupplierList(BuildContext context) {
    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 1,
      expansionCallback: (int index, bool isExpanded) => setState(() =>
          _supplierExpansionState[widget.configuration.suppliers[index]] =
              !isExpanded),
      children: widget.configuration.suppliers
          .map((supplier) => _buildSupplierTile(context, supplier))
          .toList(),
    );
  }

  ExpansionPanel _buildSupplierTile(BuildContext context, Supplier supplier) {
    final reservationMap = _reservationMap[supplier] ?? {};
    final reservationMapDayBefore =
        widget.reservationMapDayBefore[supplier] ?? {};

    if (_supplierExpansionState[supplier] == null) {
      _supplierExpansionState[supplier] =
          reservationMap.values.any((reservations) => reservations.isNotEmpty);
    }

    return ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        title: Text(short.formatSupplierSafe(context, supplier)),
        subtitle: buildSupplierReservationSummary(context,
            reservationMap.values.expand((reservation) => reservation).toList(),
            purchaseTariffMap: widget.purchaseTariffMap),
        contentPadding: EdgeInsets.only(left: 16),
        onTap: () => setState(() => _supplierExpansionState[supplier] =
            !_supplierExpansionState[supplier]),
      ),
      backgroundColor: CommonColors.reservationsSupplierHeader,
      body: _buildArticleBrandList(
          context, supplier, reservationMap, reservationMapDayBefore),
      isExpanded: _supplierExpansionState[supplier],
    );
  }

  Widget _buildArticleBrandList(
      BuildContext context,
      Supplier supplier,
      Map<ArticleBrand, List<Order>> reservationMap,
      Map<ArticleBrand, List<Order>> reservationMapDayBefore) {
    if (supplier.articleBrands == null || supplier.articleBrands.isEmpty) {
      final localizationUtil = LocalizationUtil.of(context);
      return buildReservationListPlaceholderCell(
          context: context,
          text: localizationUtil.noArticleBrands,
          border: _buildBorder(context));
    }
    return Container(
      color: Colors.white,
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        elevation: 1,
        expansionCallback: (int index, bool isExpanded) => setState(() =>
            _articleBrandExpansionState[
                Tuple2(supplier, supplier.articleBrands[index])] = !isExpanded),
        children: supplier.articleBrands
            .map((articleBrand) => _buildArticleBrandTile(context, supplier,
                articleBrand, reservationMap, reservationMapDayBefore))
            .toList(),
      ),
    );
  }

  ExpansionPanel _buildArticleBrandTile(
      BuildContext context,
      Supplier supplier,
      ArticleBrand articleBrand,
      Map<ArticleBrand, List<Order>> reservationMap,
      Map<ArticleBrand, List<Order>> reservationMapDayBefore) {
    final reservations = reservationMap[articleBrand] ?? [];
    final reservationsDayBefore = reservationMapDayBefore[articleBrand] ?? [];

    if (_articleBrandExpansionState[Tuple2(supplier, articleBrand)] == null) {
      _articleBrandExpansionState[Tuple2(supplier, articleBrand)] =
          reservations.isNotEmpty;
    }

    return ExpansionPanel(
      headerBuilder: (context, isExpanded) => ListTile(
        title: Text(short.formatArticleBrandSafe(context, articleBrand)),
        subtitle: buildArticleReservationSummary(context, reservations,
            reservationsDayBefore: reservationsDayBefore),
        trailing: widget.user.canAddOrders()
            ? IconButton(
                icon: Icon(Icons.add_circle_outline),
                color: Theme.of(context).primaryColor,
                onPressed: () => _showAddWidget(
                    context: context,
                    supplier: supplier,
                    articleBrand: articleBrand),
              )
            : null,
        onTap: () => setState(() =>
            _articleBrandExpansionState[Tuple2(supplier, articleBrand)] =
                !_articleBrandExpansionState[Tuple2(supplier, articleBrand)]),
        contentPadding: EdgeInsets.only(left: 16),
      ),
      backgroundColor: CommonColors.reservationsArticleBrandHeader,
      body: _buildReservationList(context, reservations),
      isExpanded: _articleBrandExpansionState[Tuple2(supplier, articleBrand)],
    );
  }

  Widget _buildReservationList(BuildContext context, List<Order> reservations) {
    final localizationUtil = LocalizationUtil.of(context);
    if (reservations.isEmpty) {
      return buildReservationListPlaceholderCell(
          context: context,
          text: localizationUtil.noEntries,
          border: _buildBorder(context));
    }
    return Column(
      children: reservations
          .map((reservation) => _buildReservationCell(context, reservation))
          .toList(),
    );
  }

  Widget _buildReservationCell(BuildContext context, Order reservation) {
    return buildReservationListCell(
      context,
      reservation: reservation,
      user: widget.user,
      border: _buildBorder(context),
      onTap: () => _showDetails(context, reservation),
    );
  }

  Widget _buildTotalSummaryCell(BuildContext context) {
    return buildReservationListMultipleFieldCell(
      context: context,
      children: [
        buildReservationsCountWidget(context, _reservationMap),
        buildTotalPurchasePriceWidget(
            context, _reservationMap, widget.purchaseTariffMap),
      ],
      border: _buildBorder(context),
    );
  }

  void _showDetails(BuildContext context, Order reservation) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ReservationDetailsWidget(
              reservation: reservation, user: widget.user, listBodyState: this),
        ));
  }

  void _showAddWidget(
      {BuildContext context,
      Supplier supplier,
      ArticleBrand articleBrand}) async {
    if (!await checkVersionForOrderAddition(context, reservation: true)) {
      return;
    }
    var reservation = Order();
    reservation.articleBrand = articleBrand;
    reservation.supplier = supplier;
    reservation.unloadingBeginDate = widget.date;
    final newReservation = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ReservationAddWidget(user: widget.user, reservation: reservation),
          fullscreenDialog: true,
        ));
    if (newReservation != null) {
      addReservation(newReservation);
    }
  }

  void _expand(Order reservation) {
    _supplierExpansionState[reservation.supplier] = true;
    _articleBrandExpansionState[
        Tuple2(reservation.supplier, reservation.articleBrand)] = true;
  }

  void _subscribe() {
    _subscription =
        _serverAPI.subscribeToReservations(widget.user, widget.date);
    _subscription.onUpdate = (reservation) async {
      await _serverAPI.fetch(reservation);
      updateReservation(reservation);
    };
    _subscription.onAdd = (reservation) async {
      await _serverAPI.fetch(reservation);
      addReservation(reservation);
    };
    _subscription.onRemove = (reservation) async {
      removeReservation(reservation);
    };
  }

  BoxBorder _buildBorder(BuildContext context) =>
      Border(top: BorderSide(color: Theme.of(context).dividerColor));
}

extension _ReservationMap on Map<Supplier, Map<ArticleBrand, List<Order>>> {
  void addReservation(Order reservation, {bool toBeginning = false}) {
    final reservationList = _accessReservationList(reservation);
    if (reservationList.contains(reservation)) {
      return;
    }
    if (toBeginning) {
      reservationList.insert(0, reservation);
    } else {
      reservationList.add(reservation);
    }
  }

  void removeReservation(Order reservation) {
    for (final supplierReservationMap in this.values) {
      for (final reservationList in supplierReservationMap.values) {
        reservationList.remove(reservation);
      }
    }
  }

  void replaceReservation(Order reservation) {
    final reservationList = _accessReservationList(reservation);
    final index = reservationList.indexOf(reservation);
    if (index != -1) {
      reservationList[index] = reservation;
      return;
    }
    removeReservation(reservation);
    addReservation(reservation, toBeginning: true);
  }

  int getCount(Supplier supplier, ArticleBrand articleBrand) {
    var supplierReservationMap = this[supplier];
    if (supplierReservationMap == null) {
      return 0;
    }
    var reservationList = supplierReservationMap[articleBrand];
    if (reservationList == null) {
      return 0;
    }
    return reservationList.length;
  }

  List<Order> _accessReservationList(Order reservation) {
    var supplierReservationMap = this[reservation.supplier];
    if (supplierReservationMap == null) {
      supplierReservationMap = <ArticleBrand, List<Order>>{};
      this[reservation.supplier] = supplierReservationMap;
    }
    var reservationList = supplierReservationMap[reservation.articleBrand];
    if (reservationList == null) {
      reservationList = <Order>[];
      supplierReservationMap[reservation.articleBrand] = reservationList;
    }
    return reservationList;
  }
}
