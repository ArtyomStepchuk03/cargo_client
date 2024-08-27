import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/order/order_clone.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/reservation/reservation_details/reservation_details_body.dart';
import '../../common/app_bar.dart';
import 'reservation_add_strings.dart' as strings;

class ReservationAddWidget extends StatefulWidget {
  final User user;
  final Order reservation;

  ReservationAddWidget({this.user, this.reservation});
  factory ReservationAddWidget.empty({User user}) => ReservationAddWidget(user: user, reservation: Order());
  factory ReservationAddWidget.clone({User user, Order order}) => ReservationAddWidget(user: user, reservation: cloneReservation(order));

  @override
  State<StatefulWidget> createState() => ReservationAddState();
}

class ReservationAddState extends State<ReservationAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: ReservationDetailsBody(key: _bodyKey, reservation: widget.reservation, user: widget.user, editing: true),
    );
  }

  final _bodyKey = GlobalKey<ReservationDetailsBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final editedReservation = _bodyKey.currentState.validate();
    if (editedReservation != null) {
      showActivityDialog(context, strings.saving);
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      try {
        await serverAPI.createReservation(editedReservation);
        Navigator.pop(context);
        Navigator.pop(context, editedReservation);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }
}
