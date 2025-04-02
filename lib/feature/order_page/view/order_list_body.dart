import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_subscription.dart'
    as parse;

import '../../../feature/order_page/view/order_data_source.dart';
import 'order_details/order_details_widget.dart';
import 'order_list_card.dart';

export 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';

class OrderListBody extends StatefulWidget {
  final User? user;
  final OrderFilter? filter;
  final OrderSort? sort;
  final FilterPredicate<Order>? filterPredicate;
  final bool? insetForFloatingActionButton;

  OrderListBody({
    Key? key,
    this.user,
    this.filter,
    this.sort,
    this.filterPredicate,
    this.insetForFloatingActionButton = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrderListBodyState();
}

class OrderListBodyState extends State<OrderListBody> {
  void addOrder(Order? order) => _listViewKey.currentState?.addItem(order);
  void removeOrder(Order? order) =>
      _listViewKey.currentState?.removeItem(order);
  void updateOrder(Order? order) =>
      _listViewKey.currentState?.updateItem(order);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_serverAPI == null) {
      _serverAPI = DependencyHolder.of(context)!.network.serverAPI.orders;
      _subscribe();
    }
  }

  @override
  void didUpdateWidget(covariant OrderListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter || widget.sort != oldWidget.sort) {
      _serverAPI?.unsubscribe(_subscription);
      _subscribe();
    }
  }

  @override
  void dispose() {
    _serverAPI?.unsubscribe(_subscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingListView(
      key: _listViewKey,
      dataSource: makeOrderDataSource(
          serverAPI: _serverAPI,
          user: widget.user,
          sort: widget.sort,
          filter: widget.filter),
      filterPredicate: widget.filterPredicate,
      builder: (BuildContext context, Order? order) {
        return _buildCard(
            context,
            order,
            DependencyHolder.of(context)!
                .network
                .configurationLoader
                .configuration);
      },
      activityFooterTile: ActivityListFooterTile(),
      placeholderFooterTile: PlaceholderListFooterTile(),
      errorFooterTile: ErrorListFooterTile(),
      insetForFloatingActionButton: widget.insetForFloatingActionButton,
    );
  }

  final _listViewKey = GlobalKey<LoadingListViewState>();
  OrderServerAPI? _serverAPI;
  parse.LiveQuerySubscription<Order?>? _subscription;

  Widget _buildCard(
      BuildContext context, Order? order, Configuration? configuration) {
    return OrderListCard(
      order: order,
      user: widget.user,
      configuration: configuration,
      onTap: () => _showDetails(context, order),
    );
  }

  void _showDetails(BuildContext context, Order? order) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => OrderDetailsWidget(
              order: order, user: widget.user, listBodyState: this),
        ));
  }

  void _subscribe() {
    _subscription = _serverAPI!.subscribe(widget.user!, filter: widget.filter);
    _subscription?.onUpdate = (order) async {
      await _serverAPI?.fetch(order);
      updateOrder(order);
    };
    _subscription?.onAdd = (order) async {
      await _serverAPI?.fetch(order);
      addOrder(order);
    };
    _subscription?.onRemove = (order) async {
      removeOrder(order);
    };
  }
}
