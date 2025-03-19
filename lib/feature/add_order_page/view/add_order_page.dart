import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_details/order_details_main_body.dart';
import 'package:manager_mobile_client/src/logic/order/order_clone.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class AddOrderPage extends StatefulWidget {
  final User? user;
  final Order? order;

  AddOrderPage({this.user, this.order});
  factory AddOrderPage.empty({User? user}) =>
      AddOrderPage(user: user, order: Order());
  factory AddOrderPage.clone({required User user, required Order order}) =>
      AddOrderPage(user: user, order: cloneOrder(order, user));

  @override
  State<StatefulWidget> createState() => AddOrderPageState();
}

class AddOrderPageState extends State<AddOrderPage> {
  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newOrder),
        actions: _buildActions(context),
      ),
      body: OrderDetailsMainBody(
          key: _bodyKey, order: widget.order, user: widget.user, editing: true),
    );
  }

  final _bodyKey = GlobalKey<OrderDetailsMainBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final editedOrder = _bodyKey.currentState?.validate();
    final localizationUtil = LocalizationUtil.of(context);
    if (editedOrder != null) {
      showActivityDialog(context, localizationUtil.saving);
      final serverAPI = DependencyHolder.of(context)?.network.serverAPI.orders;
      try {
        if (editedOrder.id != null && editedOrder.status != OrderStatus.ready) {
          await serverAPI?.update(widget.order, editedOrder);
          await serverAPI?.setStatus(editedOrder, OrderStatus.ready);
        } else {
          await serverAPI?.create(editedOrder, widget.user);
        }
        Navigator.pop(context);
        Navigator.pop(context, editedOrder);
      } on CloudFunctionFailedException catch (exception) {
        Navigator.pop(context);
        if (exception.error == ServerError.noSupplierForArticle) {
          showErrorDialog(context, localizationUtil.articleNotAvailableForSale);
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
