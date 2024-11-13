import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/auth_page/auth_page.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import '../../../common/dialogs/outdated_version_dialog.dart';
import '../../../feature/add_order_page/view/add_order_page.dart';
import '../../../feature/order_page/view/order_interval_filter_predicate.dart';
import 'order_list_body.dart';
import 'order_search/order_search.dart';

class OrderListWidget extends StatefulWidget {
  final Drawer drawer;
  final TransitionBuilder containerBuilder;

  OrderListWidget(this.drawer, this.containerBuilder);

  @override
  State<StatefulWidget> createState() => OrderListState();
}

class OrderListState extends State<OrderListWidget> {
  OrderListState() : _showIntervalFilter = false;

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    final authorizationState = AuthPage.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: RichText(
          text: TextSpan(
              text: localizationUtil.orders,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              children: <TextSpan>[
                TextSpan(
                  text: _formatSubtitle(_filter),
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ]),
        ),
        actions: _buildActions(authorizationState.user),
        bottom: _showIntervalFilter
            ? PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: _buildIntervalFilterWidget(),
              )
            : null,
      ),
      drawer: widget.drawer,
      body: widget.containerBuilder(
          context,
          OrderListBody(
            key: _bodyKey,
            user: authorizationState.user,
            filter: _filter,
            filterPredicate:
                _showIntervalFilter ? _makeIntervalFilterPredicate() : null,
            sort: _sort,
            insetForFloatingActionButton: true,
          )),
      floatingActionButton:
          _buildAddOrderButton(context, authorizationState.user),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  final _bodyKey = GlobalKey<OrderListBodyState>();
  OrderFilter _filter = OrderFilter.allExceptDeleted();
  OrderSort _sort = OrderSort.byDefault();
  bool _showIntervalFilter;
  DateTime _beginDate;
  DateTime _endDate;

  List<Widget> _buildActions(User user) {
    final actions = <Widget>[];
    actions.add(_buildSearchButton(context));
    if (_filter.progress == OrderProgress.fullyFinished) {
      actions.add(IconButton(
        icon: Icon(_showIntervalFilter ? Icons.close : Icons.event_note),
        onPressed: _toggleIntervalFilter,
      ));
    }
    actions.add(_buildSortButton(context));
    actions.add(_buildFilterMenuButton(user));
    return actions;
  }

  Widget _buildSearchButton(BuildContext context) {
    final authorizationState = AuthPage.of(context);
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        showOrderSearch(
          context: context,
          user: authorizationState.user,
          filter: _filter,
          filterPredicate:
              _showIntervalFilter ? _makeIntervalFilterPredicate() : null,
          sort: _sort,
        );
      },
    );
  }

  PopupMenuButton _buildFilterMenuButton(User user) {
    final items = [
      _buildPopupFilterMenuItem(OrderFilter.allExceptDeleted()),
      _buildPopupFilterMenuItem(OrderFilter.notFullyDistributed()),
      _buildPopupFilterMenuItem(OrderFilter.notFullyFinished()),
      _buildPopupFilterMenuItem(OrderFilter.fullyFinished()),
      if (user.role != Role.customer)
        _buildPopupFilterMenuItem(OrderFilter.deleted()),
    ];
    return PopupMenuButton<OrderFilter>(
      icon: Icon(Icons.filter_list),
      itemBuilder: (BuildContext context) => items,
      onSelected: (OrderFilter filter) {
        setState(() {
          _filter = filter;
          if (_filter.progress != OrderProgress.fullyFinished) {
            _showIntervalFilter = false;
            _beginDate = null;
            _endDate = null;
          }
        });
      },
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final items = [
      _buildPopupSortMenuItem(OrderSort.byDefault()),
      _buildPopupSortMenuItem(OrderSort.byUnloadingDate()),
    ];
    return PopupMenuButton<OrderSort>(
      icon: Icon(Icons.sort),
      itemBuilder: (BuildContext context) => items,
      onSelected: (OrderSort sort) {
        setState(() {
          _sort = sort;
        });
      },
    );
  }

  CheckedPopupMenuItem<OrderFilter> _buildPopupFilterMenuItem(
      OrderFilter filter) {
    return CheckedPopupMenuItem<OrderFilter>(
      value: filter,
      checked: filter == _filter,
      child: Text(_formatFilter(filter)),
    );
  }

  CheckedPopupMenuItem<OrderSort> _buildPopupSortMenuItem(OrderSort sort) {
    return CheckedPopupMenuItem<OrderSort>(
      value: sort,
      checked: sort == _sort,
      child: Text(_formatSort(sort)),
    );
  }

  Widget _buildIntervalFilterWidget() {
    final localizationUtil = LocalizationUtil.of(context);
    final themeData = Theme.of(context);
    return Theme(
      data: themeData.copyWith(
        brightness: Brightness.dark,
        colorScheme: themeData.colorScheme.copyWith(secondary: Colors.white),
        hintColor: Colors.white,
        textTheme: themeData.textTheme.copyWith(
          subtitle1: themeData.textTheme.subtitle1.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
                child: DateFormField(
                    pickerMode: CupertinoDatePickerMode.date,
                    label: localizationUtil.begin,
                    onChanged: _handleBeginDateChanged)),
            SizedBox(width: 6),
            Expanded(
                child: DateFormField(
                    pickerMode: CupertinoDatePickerMode.date,
                    label: localizationUtil.end,
                    onChanged: _handleEndDateChanged))
          ],
        ),
      ),
    );
  }

  Widget _buildAddOrderButton(BuildContext context, User user) {
    final localizationUtil = LocalizationUtil.of(context);
    if (!user.canAddOrders()) {
      return null;
    }
    return buildFloatingActionButtonContainer(
      child: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text(localizationUtil.newOrder.toUpperCase()),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _showAddWidget(context),
      ),
    );
  }

  void _handleBeginDateChanged(DateTime date) {
    setState(() => _beginDate = date);
  }

  void _handleEndDateChanged(DateTime date) {
    setState(() => _endDate = date);
  }

  void _toggleIntervalFilter() {
    setState(() {
      if (_showIntervalFilter) {
        _showIntervalFilter = false;
        _beginDate = null;
        _endDate = null;
      } else {
        _showIntervalFilter = true;
      }
    });
  }

  void _showAddWidget(BuildContext context) async {
    if (!await checkVersionForOrderAddition(context)) {
      return;
    }
    final authorizationState = AuthPage.of(context);
    final order = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              AddOrderPage.empty(user: authorizationState.user),
          fullscreenDialog: true,
        ));
    if (order != null) {
      _bodyKey.currentState.addOrder(order);
    }
  }

  OrderIntervalFilterPredicate _makeIntervalFilterPredicate() {
    return OrderIntervalFilterPredicate(
        _beginDate?.toUtc(), _endDate?.add(Duration(days: 1))?.toUtc());
  }

  String _formatSubtitle(OrderFilter filter) {
    return "\n" + _formatFilter(filter);
  }

  String _formatFilter(OrderFilter filter) {
    final localizationUtil = LocalizationUtil.of(context);
    if (filter.deleted) {
      return localizationUtil.deleted;
    }
    if (filter.progress == null) {
      return localizationUtil.all;
    }
    switch (filter.progress) {
      case OrderProgress.notFullyDistributed:
        return localizationUtil.notFullyDistributed;
      case OrderProgress.notFullyFinished:
        return localizationUtil.notFullyFinished;
      case OrderProgress.fullyFinished:
        return localizationUtil.fullyFinished;
      default:
        return '';
    }
  }

  String _formatSort(OrderSort sort) {
    final localizationUtil = LocalizationUtil.of(context);
    switch (sort.sortType) {
      case OrderSortType.byDefault:
        return localizationUtil.sortByStatus;
      case OrderSortType.byUnloadingDate:
        return localizationUtil.sortByUnloadingDate;
    }
    return '';
  }
}
