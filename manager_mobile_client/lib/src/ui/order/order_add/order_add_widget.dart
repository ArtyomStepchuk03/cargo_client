import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/src/logic/order/order_clone.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/order/order_details/order_details_main_body.dart';
import '../../common/app_bar.dart';
import 'order_add_strings.dart' as strings;

class OrderAddWidget extends StatefulWidget {
  final User user;
  final Order order;

  OrderAddWidget({this.user, this.order});
  factory OrderAddWidget.empty({User user}) => OrderAddWidget(user: user, order: Order());
  factory OrderAddWidget.clone({User user, Order order}) => OrderAddWidget(user: user, order: cloneOrder(order, user));

  @override
  State<StatefulWidget> createState() => OrderAddState();
}

class OrderAddState extends State<OrderAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: OrderDetailsMainBody(key: _bodyKey, order: widget.order, user: widget.user, editing: true),
    );
  }

  final _bodyKey = GlobalKey<OrderDetailsMainBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final editedOrder = _bodyKey.currentState.validate();
    if (editedOrder != null) {
      showActivityDialog(context, strings.saving);
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      try {
        if (editedOrder.id != null && editedOrder.status != OrderStatus.ready) {
          await serverAPI.update(widget.order, editedOrder);
          await serverAPI.setStatus(editedOrder, OrderStatus.ready);
        } else {
          await serverAPI.create(editedOrder, widget.user);
        }
        Navigator.pop(context);
        Navigator.pop(context, editedOrder);
      } on CloudFunctionFailedException catch (exception) {
        Navigator.pop(context);
        if (exception.error == ServerError.noSupplierForArticle) {
          showErrorDialog(context, strings.articleNotAvailableForSale);
          return;
        }
        showDefaultErrorDialog(context);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }
}
