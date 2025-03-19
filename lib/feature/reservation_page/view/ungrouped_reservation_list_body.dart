import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/reservation_page/widget/reservation_details/reservation_details_widget.dart';
import 'package:manager_mobile_client/src/logic/core/date_utility.dart';
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_subscription.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'reservation_list_body_state.dart';
import 'reservation_list_cell.dart';

class UngroupedReservationListBody extends StatefulWidget {
  final List<Order?>? reservations;
  final User? user;
  final DateTime? date;

  UngroupedReservationListBody(this.reservations, {this.user, this.date});

  @override
  State<StatefulWidget> createState() => UngroupedReservationListBodyState();
}

class UngroupedReservationListBodyState
    extends State<UngroupedReservationListBody>
    implements ReservationListBodyState {
  void addReservation(Order? reservation) {
    if (reservation?.unloadingBeginDate?.toLocal().beginningOfDay !=
        widget.date) {
      return;
    }
    setState(() => _reservations?.insert(0, reservation!));
  }

  void removeReservation(Order? reservation) {
    setState(() => _reservations?.remove(reservation));
  }

  void updateReservation(Order? reservation) {
    if (reservation?.unloadingBeginDate?.toLocal().beginningOfDay !=
        widget.date) {
      setState(() => _reservations?.remove(reservation));
      return;
    }
    final index = _reservations?.indexOf(reservation!);
    if (index != -1) {
      setState(() => _reservations?[index!] = reservation!);
    }
  }

  @override
  void initState() {
    super.initState();
    _reservations = widget.reservations;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_serverAPI == null) {
      _serverAPI = DependencyHolder.of(context)!.network.serverAPI.orders;
      _subscribe();
    }
  }

  @override
  void didUpdateWidget(covariant UngroupedReservationListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      _serverAPI?.unsubscribe(_subscription);
      _subscribe();
    }
  }

  @override
  void dispose() {
    _serverAPI?.unsubscribe(_subscription);
    super.dispose();
  }

  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    if (_reservations!.isEmpty) {
      return FullscreenPlaceholder(
          icon: Icons.table_view, text: localizationUtil.noEntries);
    }
    return ListView(
      children: _reservations!
          .map((reservation) => _buildCell(context, reservation))
          .toList(),
    );
  }

  List<Order?>? _reservations;
  OrderServerAPI? _serverAPI;
  parse.LiveQuerySubscription<Order?>? _subscription;

  Widget _buildCell(BuildContext context, Order? reservation) {
    return buildReservationListCell(
      context,
      reservation: reservation,
      user: widget.user,
      showArticle: true,
      onTap: () => _showDetails(context, reservation),
      border: _buildBorder(context),
    );
  }

  void _showDetails(BuildContext context, Order? reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ReservationDetailsWidget(
            reservation: reservation, user: widget.user, listBodyState: this),
      ),
    );
  }

  void _subscribe() {
    _subscription =
        _serverAPI!.subscribeToReservations(widget.user, widget.date!);
    _subscription?.onUpdate = (reservation) async {
      await _serverAPI!.fetch(reservation);
      updateReservation(reservation);
    };
    _subscription?.onAdd = (reservation) async {
      await _serverAPI!.fetch(reservation);
      addReservation(reservation);
    };
    _subscription?.onRemove = (reservation) async {
      removeReservation(reservation);
    };
  }

  BoxBorder _buildBorder(BuildContext context) =>
      Border(bottom: BorderSide(color: Theme.of(context).dividerColor));
}
