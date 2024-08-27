import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/ui/format/common_format.dart';
import 'package:manager_mobile_client/src/ui/common/floating_action_button.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/order/order_action_check.dart';
import 'package:manager_mobile_client/src/ui/order/order_add/order_add_widget.dart';
import 'package:manager_mobile_client/src/ui/order/order_add/outdated_version_dialog.dart';
import 'package:manager_mobile_client/src/ui/reservation/reservation_list_body_state.dart';
import 'package:manager_mobile_client/src/ui/reservation/reservation_add/reservation_add_widget.dart';
import 'package:manager_mobile_client/src/ui/reservation/carrier_prior_assign/carrier_prior_assign_widget.dart';
import '../../common/app_bar.dart';
import 'reservation_details_body.dart';
import 'reservation_details_strings.dart' as strings;

class ReservationDetailsWidget extends StatefulWidget {
  final Order reservation;
  final User user;
  final ReservationListBodyState listBodyState;

  ReservationDetailsWidget({this.reservation, this.user, this.listBodyState});

  @override
  State<StatefulWidget> createState() => ReservationDetailsState();
}

class ReservationDetailsState extends State<ReservationDetailsWidget> {
  ReservationDetailsState() : _editing = false;

  @override
  Widget build(BuildContext context) {
    final floatingActionButton = _buildCurrentFloatingActionButton(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(formatWithNumberSafe(strings.title, widget.reservation.number)),
        leading: _buildLeading(),
        actions: _buildActions(context),
      ),
      body: ReservationDetailsBody(
        key: _bodyKey,
        reservation: widget.reservation,
        user: widget.user,
        editing: _editing,
        insetForFloatingActionButton: floatingActionButton != null,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  final _bodyKey = GlobalKey<ReservationDetailsBodyState>();
  var _editing = false;

  Widget _buildLeading() {
    if (_editing) {
      return IconButton(icon: Icon(Icons.close), onPressed: _cancelEditing);
    }
    return null;
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_editing) {
      return [IconButton(icon: Icon(Icons.done), onPressed: () => _finishEditing(context))];
    }
    final editAction = IconButton(icon: Icon(Icons.edit), onPressed: _setEditing);
    final moreMenuAction = _buildMoreMenuButton(context);
    return [
      if (_canEditReservation())
        editAction,
      if (moreMenuAction != null)
        moreMenuAction,
    ];
  }

  PopupMenuButton _buildMoreMenuButton(BuildContext context) {
    final items = [
      if (widget.user.canAddOrders())
        PopupMenuItem<GestureTapCallback>(value: () => _showAddWidget(context), child: Text(strings.clone)),
      if (_canRemoveAssignment())
        PopupMenuItem<GestureTapCallback>(value: () => _removeAssignment(context), child: Text(strings.removeAssignment))
      else if (_canAssignReservation())
        PopupMenuItem<GestureTapCallback>(value: () => _showCarrierPriorAssignDialog(context), child: Text(strings.assignCarrier))
      else if (_canSelfAssignReservation())
        PopupMenuItem<GestureTapCallback>(value: () => _selfAssignReservation(context), child: Text(strings.assignCarrier)),
      if (widget.reservation.canDeclineCarrierOffer(widget.user))
        PopupMenuItem<GestureTapCallback>(value: () => _decline(context), child: Text(strings.decline)),
      if (_canDeleteReservation())
        PopupMenuItem<GestureTapCallback>(value: () => _delete(context), child: Text(strings.delete)),
    ];
    if (items.isEmpty) {
      return null;
    }
    return PopupMenuButton<GestureTapCallback>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => items,
      onSelected: (GestureTapCallback action) => action(),
    );
  }

  Widget _buildCurrentFloatingActionButton(context) {
    if (_editing) {
      return null;
    }
    if (widget.reservation.canAcceptCarrierOffer(widget.user)) {
      return _buildFloatingActionButton(context: context, label: strings.confirmUppercase, onTap: () => _accept(context));
    } else if (_canTakeReservationIntoWork()) {
      return _buildFloatingActionButton(context: context, label: strings.takeIntoWork, onTap: () => _takeIntoWork(context));
    } else if (_canProcessReservation()) {
      return _buildFloatingActionButton(context: context, label: strings.processReservation, onTap: () => _showReservationProcessWidget(context));
    } else {
      return null;
    }
  }

  Widget _buildFloatingActionButton({BuildContext context, String label, VoidCallback onTap}) {
    return buildFloatingActionButtonContainer(
      child: FloatingActionButton.extended(
        icon: Container(),
        label: Text(label),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: onTap,
      ),
    );
  }

  void _showReservationProcessWidget(BuildContext context) async {
    var reservation = Order();
    reservation.assign(widget.reservation);
    reservation.loadingDate = DateTime.now();
    final order = await Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => OrderAddWidget(user: widget.user, order: reservation),
      fullscreenDialog: true,
    ));
    if (order != null) {
      widget.reservation.assign(order);
      _bodyKey.currentState.update();
      setState(() {});
      if (widget.listBodyState != null) {
        widget.listBodyState.updateReservation(order);
      }
    }
  }

  void _takeIntoWork(BuildContext context) async {
    final confirmed = await showQuestionDialog(context, strings.confirmTakeIntoWork);
    if (!confirmed) {
      return;
    }
    showDefaultActivityDialog(context);
    final dependencyState = DependencyHolder.of(context);
    final serverAPI = dependencyState.network.serverAPI.orders;
    try {
      await serverAPI.setStatus(widget.reservation, OrderStatus.inWork);
      Navigator.pop(context);
      setState(() {});
      if (widget.listBodyState != null) {
        widget.listBodyState.updateReservation(widget.reservation);
      }
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  void _setEditing() {
    _bodyKey.currentState.setEditing(true);
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    setState(() => _editing = false);
    _bodyKey.currentState.reset();
    _bodyKey.currentState.setEditing(false);
  }

  void _finishEditing(BuildContext context) async {
    final editedReservation = _bodyKey.currentState.validate();
    if (editedReservation != null) {
      showActivityDialog(context, strings.saving);
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      try {
        await serverAPI.update(widget.reservation, editedReservation);
        widget.reservation.assign(editedReservation);
        Navigator.pop(context);
        setState(() => _editing = false);
        _bodyKey.currentState.setEditing(false);
        if (widget.listBodyState != null) {
          widget.listBodyState.updateReservation(editedReservation);
        }
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  void _showAddWidget(BuildContext context) async {
    if (!await checkVersionForOrderAddition(context, reservation: true)) {
      return;
    }
    final newReservation = await Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (BuildContext context) => ReservationAddWidget.clone(user: widget.user, order: widget.reservation),
      fullscreenDialog: true,
    ));
    if (newReservation != null && widget.listBodyState != null) {
      widget.listBodyState.addReservation(newReservation);
    }
  }

  void _showCarrierPriorAssignDialog(BuildContext context) async {
    final assignedReservation = await Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => buildCarrierPriorAssignWidget(context, widget.reservation),
      fullscreenDialog: true,
    ));
    if (assignedReservation != null) {
      setState(() {});
      if (widget.listBodyState != null) {
        widget.listBodyState.updateReservation(assignedReservation);
      }
    }
  }

  void _removeAssignment(BuildContext context) async {
    final confirmed = await showQuestionDialog(context, strings.confirmRemoveAssignment);
    if (confirmed) {
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      showDefaultActivityDialog(context);
      try {
        await serverAPI.fetchProgress(widget.reservation);
        if (!isPriorAssignmentAllowed(widget.reservation)) {
          Navigator.pop(context);
          await showErrorDialog(context, strings.cannotAssign);
          return;
        }
        await serverAPI.assignCarrier(widget.reservation, null);
        Navigator.pop(context);
        setState(() {});
        if (widget.listBodyState != null) {
          widget.listBodyState.updateReservation(widget.reservation);
        }
      } on Exception {
        Navigator.pop(context);
        await showDefaultErrorDialog(context);
      }
    }
  }

  void _selfAssignReservation(BuildContext context) async {
    final confirmed = await showQuestionDialog(context, strings.confirmSelfAssign);
    if (confirmed) {
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      showDefaultActivityDialog(context);
      try {
        await serverAPI.fetchProgress(widget.reservation);
        if (!isPriorAssignmentAllowed(widget.reservation)) {
          Navigator.pop(context);
          await showErrorDialog(context, strings.cannotAssign);
          return;
        }
        await serverAPI.reserve(widget.reservation);
        Navigator.pop(context);
        setState(() {});
        if (widget.listBodyState != null) {
          widget.listBodyState.updateReservation(widget.reservation);
        }
      } on Exception {
        Navigator.pop(context);
        await showDefaultErrorDialog(context);
      }
    }
  }

  void _accept(BuildContext context) async {
    showDefaultActivityDialog(context);
    final dependencyState = DependencyHolder.of(context);
    final serverAPI = dependencyState.network.serverAPI.orders;
    try {
      await serverAPI.take(widget.reservation);
      Navigator.pop(context);
      setState(() {});
      if (widget.listBodyState != null) {
        widget.listBodyState.updateReservation(widget.reservation);
      }
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  void _decline(BuildContext context) async {
    final confirmed = await showQuestionDialog(context, strings.confirmDecline);
    if (confirmed) {
      showDefaultActivityDialog(context);
      final dependencyState = DependencyHolder.of(context);
      final serverAPI = dependencyState.network.serverAPI.orders;
      try {
        await serverAPI.decline(widget.reservation);
        Navigator.pop(context);
        setState(() {});
        if (widget.listBodyState != null) {
          widget.listBodyState.updateReservation(widget.reservation);
        }
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  void _delete(BuildContext context) async {
    final confirmed = await showQuestionDialog(context, strings.confirmDelete);
    if (confirmed) {
      showDefaultActivityDialog(context);
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      try {
        await serverAPI.delete(widget.reservation);
        Navigator.pop(context);
        Navigator.pop(context);
        if (widget.listBodyState != null) {
          widget.listBodyState.removeReservation(widget.reservation);
        }
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  bool _canEditReservation() {
    if (!widget.user.canEditOrders()) {
      return false;
    }
    if (widget.user.role == Role.dispatcher && !widget.reservation.isActionsAllowedForDispatcher(widget.user)) {
      return false;
    }
    return widget.reservation.status != OrderStatus.ready;
  }

  bool _canProcessReservation() {
    if (!widget.user.canAddOrders()) {
      return false;
    }
    if (widget.user.role == Role.dispatcher && !widget.reservation.isActionsAllowedForDispatcher(widget.user)) {
      return false;
    }
    return widget.reservation.status != OrderStatus.ready;
  }

  bool _canTakeReservationIntoWork() {
    if (!Role.isManagerOrHigher(widget.user.role)) {
      return false;
    }
    return widget.reservation.status != OrderStatus.inWork && widget.reservation.status != OrderStatus.ready;
  }

  bool _canAssignReservation() {
    if (!Role.isManagerOrHigher(widget.user.role)) {
      return false;
    }
    if (widget.reservation.customer == null) {
      return false;
    }
    return isPriorAssignmentAllowed(widget.reservation);
  }

  bool _canRemoveAssignment() {
    if (!Role.isManagerOrHigher(widget.user.role)) {
      return false;
    }
    if (!isPriorAssignmentAllowed(widget.reservation)) {
      return false;
    }
    return widget.reservation.carrierOffers != null && widget.reservation.carrierOffers.isNotEmpty;
  }

  bool _canSelfAssignReservation() {
    if (widget.user.role != Role.dispatcher) {
      return false;
    }
    if (!widget.user.carrier.orderPermissions.reserveOrder) {
      return false;
    }
    if (widget.reservation.offers != null && widget.reservation.offers.isNotEmpty) {
      return false;
    }
    if (widget.reservation.carriers != null && widget.reservation.carriers.isNotEmpty) {
      return false;
    }
    return true;
  }

  bool _canDeleteReservation() {
    if (!widget.user.canDeleteOrders()) {
      return false;
    }
    if (widget.user.role == Role.dispatcher && (widget.reservation.author == null || widget.reservation.author.id != widget.user.id)) {
      return false;
    }
    return widget.reservation.status != OrderStatus.ready;
  }
}
