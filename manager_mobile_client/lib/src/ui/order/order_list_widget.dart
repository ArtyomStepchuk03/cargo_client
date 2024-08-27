import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/floating_action_button.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/authorization/authorization_widget.dart';
import 'order_search/order_search.dart';
import 'order_add/order_add_widget.dart';
import 'order_add/outdated_version_dialog.dart';
import 'order_interval_filter_predicate.dart';
import 'order_list_body.dart';
import 'order_list_strings.dart' as strings;

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
    final authorizationState = AuthorizationWidget.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: RichText(
          text: TextSpan(
            text: strings.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            children: <TextSpan>[
              TextSpan(
                text: _formatSubtitle(_filter),
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ]
          ),
        ),
        actions: _buildActions(authorizationState.user),
        bottom: _showIntervalFilter ? PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: _buildIntervalFilterWidget(),
        ) : null,
      ),
      drawer: widget.drawer,
      body: widget.containerBuilder(context, OrderListBody(
        key: _bodyKey,
        user: authorizationState.user,
        filter: _filter,
        filterPredicate: _showIntervalFilter ? _makeIntervalFilterPredicate() : null,
        sort: _sort,
        insetForFloatingActionButton: true,
      )),
      floatingActionButton: _buildAddOrderButton(context, authorizationState.user),
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
    final authorizationState = AuthorizationWidget.of(context);
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        showOrderSearch(
          context: context,
          user: authorizationState.user,
          filter: _filter,
          filterPredicate: _showIntervalFilter ? _makeIntervalFilterPredicate() : null,
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

  CheckedPopupMenuItem<OrderFilter> _buildPopupFilterMenuItem(OrderFilter filter) {
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
            Expanded(child: DateFormField(pickerMode: CupertinoDatePickerMode.date, label: strings.begin, onChanged: _handleBeginDateChanged)),
            SizedBox(width: 6),
            Expanded(child: DateFormField(pickerMode: CupertinoDatePickerMode.date, label: strings.end, onChanged: _handleEndDateChanged))
          ],
        ),
      ),
    );
  }

  Widget _buildAddOrderButton(BuildContext context, User user) {
    if (!user.canAddOrders()) {
      return null;
    }
    return buildFloatingActionButtonContainer(
      child: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text(strings.addOrder),
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
    final authorizationState = AuthorizationWidget.of(context);
    final order = await Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => OrderAddWidget.empty(user: authorizationState.user),
      fullscreenDialog: true,
    ));
    if (order != null) {
      _bodyKey.currentState.addOrder(order);
    }
  }

  OrderIntervalFilterPredicate _makeIntervalFilterPredicate() {
    return OrderIntervalFilterPredicate(_beginDate?.toUtc(), _endDate?.add(Duration(days: 1))?.toUtc());
  }

  String _formatSubtitle(OrderFilter filter) {
    return "\n"+_formatFilter(filter);
  }

  String _formatFilter(OrderFilter filter) {
    if (filter.deleted) {
      return strings.deleted;
    }
    if (filter.progress == null) {
      return strings.all;
    }
    switch (filter.progress) {
      case OrderProgress.notFullyDistributed: return strings.notFullyDistributed;
      case OrderProgress.notFullyFinished: return strings.notFullyFinished;
      case OrderProgress.fullyFinished: return strings.fullyFinished;
      default: return '';
    }
  }

  String _formatSort(OrderSort sort) {
    switch (sort.sortType) {
      case OrderSortType.byDefault: return strings.sortByStatus;
      case OrderSortType.byUnloadingDate: return strings.sortByUnloadingDate;
    }
    return '';
  }
}
