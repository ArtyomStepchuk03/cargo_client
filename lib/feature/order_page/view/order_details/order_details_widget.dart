import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/information_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/outdated_version_dialog.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/common/speed_dial_button.dart';
import 'package:manager_mobile_client/feature/add_order_page/view/add_order_page.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_action_check.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_details/order_details_main_body.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_finish/order_finish_widget.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_list_body.dart';
import 'package:manager_mobile_client/feature/order_page/widget/order_map/order_map_widget.dart';
import 'package:manager_mobile_client/feature/order_page/widget/order_send/carrier_send_widget.dart';
import 'package:manager_mobile_client/feature/order_page/widget/order_send/transport_unit_send_widget.dart';
import 'package:manager_mobile_client/feature/order_page/widget/trip_problem_list/trip_problem_list_widget.dart';
import 'package:manager_mobile_client/src/logic/external/phone_call.dart';
import 'package:manager_mobile_client/src/logic/order/order_progress_notifier.dart';
import 'package:manager_mobile_client/util/format/common_format.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'order_details_progress_body.dart';

class OrderDetailsWidget extends StatefulWidget {
  final Order? order;
  final User? user;
  final OrderListBodyState? listBodyState;

  OrderDetailsWidget({this.order, this.user, this.listBodyState});

  @override
  State<StatefulWidget> createState() => OrderDetailsState();
}

class OrderDetailsState extends State<OrderDetailsWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  OrderDetailsState() : _editing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_progressNotifier == null) {
      final serverAPI = DependencyHolder.of(context).network.serverAPI;
      _progressNotifier = OrderProgressNotifier(
          serverAPI.orders, serverAPI.offers, serverAPI.trips);
      _progressNotifier?.subscribe(widget.order!);
      _progressNotifier?.onProgressChange = () {
        _refreshProgress(showErrors: false);
      };
    }
  }

  @override
  void dispose() {
    _progressNotifier?.unsubscribe();
    WidgetsBinding.instance.removeObserver(this);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(
            formatWithNumberSafe(localizationUtil.order, widget.order?.number)),
        leading: _buildLeading(),
        actions: _buildActions(context),
        bottom: _buildTabBar(),
      ),
      body: _buildTabBarView(),
      floatingActionButton: _buildCurrentFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshProgress(showErrors: false);
    }
  }

  final _mainBodyKey = GlobalKey<OrderDetailsMainBodyState>();
  TabController? _tabController;
  var _editing = false;
  OrderProgressNotifier? _progressNotifier;

  Widget _buildTabBarView() {
    final mainBody = OrderDetailsMainBody(
      key: _mainBodyKey,
      order: widget.order,
      user: widget.user,
      editing: _editing,
      insetForFloatingActionButton: _needsFloatingActionButton(),
    );
    if (_editing || !_shouldShowProgress()) {
      return mainBody;
    }
    return TabBarView(
      controller: _tabController,
      children: [
        mainBody,
        OrderDetailsProgressBody(
          order: widget.order,
          user: widget.user,
          onRefresh: _refreshProgress,
          insetForFloatingActionButton: _needsFloatingActionButton(),
        )
      ],
    );
  }

  TabBar? _buildTabBar() {
    if (_editing || !_shouldShowProgress()) {
      return null;
    }
    final localizationUtil = LocalizationUtil.of(context);
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(text: localizationUtil.mainTitle),
        Tab(text: localizationUtil.status.toUpperCase()),
      ],
    );
  }

  Widget? _buildLeading() {
    if (_editing) {
      return IconButton(icon: Icon(Icons.close), onPressed: _cancelEditing);
    }
    return null;
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_editing) {
      return [
        IconButton(
            icon: Icon(Icons.done), onPressed: () => _finishEditing(context))
      ];
    }
    return [
      if (_canEditOrder(widget.order))
        IconButton(icon: Icon(Icons.edit), onPressed: _setEditing),
      IconButton(
          icon: Icon(Icons.mode_of_travel), onPressed: () => _showMap(context)),
      _buildMoreMenuButton(context),
    ];
  }

  PopupMenuButton _buildMoreMenuButton(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return PopupMenuButton<GestureTapCallback>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => [
        if (widget.user?.canAddOrders() == true)
          PopupMenuItem<GestureTapCallback>(
              value: () => _showAddWidget(context),
              child: Text(localizationUtil.clone)),
        if (_shouldShowTripProblems(widget.order))
          PopupMenuItem<GestureTapCallback>(
              value: () => _showTripProblems(context),
              child: Text(localizationUtil.orderProblems)),
        if (_canCancelCarrierSend(widget.order))
          PopupMenuItem<GestureTapCallback>(
              value: () => _cancelCarrierSend(context),
              child: Text(localizationUtil.removeAssignment)),
        if (widget.order?.canDeclineCarrierOffer(widget.user) == true)
          PopupMenuItem<GestureTapCallback>(
              value: () => _decline(context),
              child: Text(localizationUtil.decline)),
        if (_canFinishOrderManually(widget.order))
          PopupMenuItem<GestureTapCallback>(
              value: () => _showFinishDialog(context),
              child: Text(localizationUtil.completeOrder)),
        if (_canCancelOrderByCustomer(widget.order!))
          PopupMenuItem<GestureTapCallback>(
              value: () => _cancelByCustomer(context),
              child: Text(localizationUtil.cancel))
        else if (_canCancelOrder(widget.order!))
          PopupMenuItem<GestureTapCallback>(
              value: () => _cancel(context),
              child: Text(localizationUtil.cancel)),
        if (_canDeleteOrder(widget.order!))
          PopupMenuItem<GestureTapCallback>(
              value: () => _delete(context),
              child: Text(localizationUtil.delete)),
        if (widget.user?.role == Role.customer)
          PopupMenuItem<GestureTapCallback>(
              value: () => _contactManager(context),
              child: Text(localizationUtil.contactManager))
      ],
      onSelected: (GestureTapCallback action) => action(),
    );
  }

  Widget? _buildCurrentFloatingActionButton(context) {
    final localizationUtil = LocalizationUtil.of(context);
    if (!_needsFloatingActionButton()) {
      return null;
    }
    if (widget.order!.canAcceptCarrierOffer(widget.user) == true) {
      return buildFloatingActionButtonContainer(
        child: FloatingActionButton.extended(
          icon: Container(),
          label: Text(localizationUtil.confirm.toUpperCase()),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => _accept(context),
        ),
      );
    }
    if (widget.user?.canAssignCarriers() == false) {
      return buildFloatingActionButtonContainer(
        child: FloatingActionButton.extended(
          icon: Container(),
          label: Text(localizationUtil.sendFloatingActionButton),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => _showTransportUnitSendDialog(context),
        ),
      );
    }
    return SpeedDialButton(
      icon: Container(),
      label: Text(localizationUtil.sendFloatingActionButton),
      backgroundColor: Theme.of(context).primaryColor,
      items: [
        SpeedDialButtonItem(
          label: Text(localizationUtil.carriages),
          icon: Icon(Icons.local_shipping),
          onPressed: () => _showTransportUnitSendDialog(context),
        ),
        SpeedDialButtonItem(
          label: Text(localizationUtil.sendToCarriers),
          icon: Icon(Icons.business_center),
          onPressed: () => _showCarrierSendDialog(context),
        ),
      ],
    );
  }

  void _setEditing() {
    if (_tabController?.index == 0) {
      _mainBodyKey.currentState!.setEditing(true);
    } else {
      _tabController?.index = 0;
    }
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    setState(() => _editing = false);
    _mainBodyKey.currentState!.reset();
    _mainBodyKey.currentState!.setEditing(false);
  }

  void _finishEditing(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final editedOrder = _mainBodyKey.currentState!.validate();
    if (editedOrder != null) {
      showActivityDialog(context, localizationUtil.saving);
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      try {
        await serverAPI.update(widget.order, editedOrder);
        widget.order!.assign(editedOrder);
        Navigator.pop(context);
        setState(() => _editing = false);
        _mainBodyKey.currentState!.setEditing(false);
        updateListBody();
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  void _showTripProblems(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              TripProblemListWidget(widget.order!),
        ));
  }

  void _showAddWidget(BuildContext context) async {
    if (!await checkVersionForOrderAddition(context)) {
      return;
    }
    final newOrder = await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              AddOrderPage.clone(user: widget.user, order: widget.order),
          fullscreenDialog: true,
        ));
    if (newOrder != null && widget.listBodyState != null) {
      widget.listBodyState!.addOrder(newOrder);
    }
  }

  void _showMap(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => OrderMapWidget(widget.order!),
        ));
  }

  void _showTransportUnitSendDialog(BuildContext context) async {
    final sentOrder = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => buildTransportUnitSendWidget(
              context, widget.order!, widget.user!),
          fullscreenDialog: true,
        ));
    if (sentOrder != null) {
      _tabController?.index = 1;
      _updateMainBodyIfNeeded();
      setState(() {});
      updateListBody();
    }
  }

  void _showCarrierSendDialog(BuildContext context) async {
    final sentOrder = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              buildCarrierSendWidget(context, widget.order, widget.user),
          fullscreenDialog: true,
        ));
    if (sentOrder != null) {
      _tabController?.index = 0;
      setState(() {});
      updateListBody();
    }
  }

  void _cancelCarrierSend(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final confirmed = await showQuestionDialog(
        context, localizationUtil.confirmCancelCarrierSend);
    if (confirmed) {
      final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
      showDefaultActivityDialog(context);
      try {
        await serverAPI.assignCarrier(widget.order, null);
        Navigator.pop(context);
        setState(() {});
        updateListBody();
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
      await serverAPI.take(widget.order!);
      Navigator.pop(context);
      setState(() {});
      updateListBody();
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  void _decline(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final confirmed =
        await showQuestionDialog(context, localizationUtil.confirmDeclineOrder);
    if (confirmed) {
      showDefaultActivityDialog(context);
      final dependencyState = DependencyHolder.of(context);
      final serverAPI = dependencyState.network.serverAPI.orders;
      try {
        await serverAPI.decline(widget.order!);
        Navigator.pop(context);
        setState(() {});
        updateListBody();
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  void _showFinishDialog(BuildContext context) async {
    final finishedOrder = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => OrderFinishWidget(widget.order!),
          fullscreenDialog: true,
        ));
    if (finishedOrder != null) {
      _updateMainBodyIfNeeded();
      setState(() {});
      updateListBody();
    }
  }

  void _cancel(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final confirmed =
        await showQuestionDialog(context, localizationUtil.confirmCancel);
    if (confirmed) {
      showDefaultActivityDialog(context);
      final dependencyState = DependencyHolder.of(context);
      final serverAPI = dependencyState.network.serverAPI.orders;
      try {
        await serverAPI.cancel(widget.order!);
        Navigator.pop(context);
        _tabController?.index = 0;
        _updateMainBodyIfNeeded();
        setState(() {});
        updateListBody();
      } on CloudFunctionFailedException catch (exception) {
        Navigator.pop(context);
        if (exception.error == ServerError.invalidTripStageForCancel) {
          showErrorDialog(context, localizationUtil.cannotCancel);
          return;
        }
        showDefaultErrorDialog(context);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  void _cancelByCustomer(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final confirmed =
        await showQuestionDialog(context, localizationUtil.confirmCancel);
    if (confirmed) {
      showDefaultActivityDialog(context);
      final dependencyState = DependencyHolder.of(context);
      final serverAPI = dependencyState.network.serverAPI.orders;
      try {
        await serverAPI.cancelByCustomer(widget.order!);
        Navigator.pop(context);
        Navigator.pop(context);
        if (widget.listBodyState != null) {
          widget.listBodyState!.removeOrder(widget.order);
        }
      } on CloudFunctionFailedException catch (exception) {
        Navigator.pop(context);
        if (exception.error == ServerError.cannotCancelByCustomer) {
          showErrorDialog(context, localizationUtil.cannotCancelByCustomer);
          return;
        }
        showDefaultErrorDialog(context);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  void _delete(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final confirmed =
        await showQuestionDialog(context, localizationUtil.confirmDeleteOrder);
    if (confirmed) {
      showDefaultActivityDialog(context);
      final dependencyState = DependencyHolder.of(context);
      final serverAPI = dependencyState.network.serverAPI.orders;
      try {
        await serverAPI.delete(widget.order!);
        Navigator.pop(context);
        Navigator.pop(context);
        if (widget.listBodyState != null) {
          widget.listBodyState?.removeOrder(widget.order);
        }
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  void _contactManager(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final phoneNumber = widget.order?.unloadingPoint?.manager?.phoneNumber;
    if (phoneNumber == null) {
      await showInformationDialog(
          context, localizationUtil.cannotContactManager);
      return;
    }
    await callPhoneNumber(widget.order!.unloadingPoint!.manager!.phoneNumber);
  }

  Future<void> _refreshProgress({bool showErrors = true}) async {
    final dependencyState = DependencyHolder.of(context);
    final serverAPI = dependencyState.network.serverAPI.orders;
    try {
      await serverAPI.fetchProgress(widget.order);
      if (mounted) {
        if (!_shouldShowProgress()) {
          _tabController?.index = 0;
        }
        setState(() {});
      }
    } on Exception {
      if (showErrors) {
        showDefaultErrorDialog(context);
      }
    }
  }

  void _updateMainBodyIfNeeded() {
    if (_mainBodyKey.currentState != null) {
      _mainBodyKey.currentState?.update();
    }
  }

  void updateListBody() {
    if (widget.listBodyState != null) {
      widget.listBodyState?.updateOrder(widget.order);
    }
  }

  bool _needsFloatingActionButton() {
    return !_editing &&
        (widget.order?.canAcceptCarrierOffer(widget.user) == true ||
            _canSendOrder(widget.order));
  }

  bool _shouldShowProgress() {
    return widget.order?.offers != null && widget.order!.offers!.isNotEmpty;
  }

  bool _canEditOrder(Order? order) {
    if (widget.user?.canEditOrders() == false) {
      return false;
    }
    if (widget.user?.role == Role.dispatcher &&
        widget.order!.isActionsAllowedForDispatcher(widget.user) == false) {
      return false;
    }
    if (order?.deleted == true) {
      return false;
    }
    final offer = order?.getAcceptedOffer();
    if (widget.user?.role == Role.customer) {
      return offer == null;
    } else {
      return offer == null || offer.trip?.stage != TripStage.unloaded;
    }
  }

  bool _shouldShowTripProblems(Order? order) {
    if (widget.user?.role == Role.customer) {
      return false;
    }
    if (order?.deleted == true) {
      return false;
    }
    return order?.getAcceptedOffer() != null;
  }

  bool _canCancelCarrierSend(Order? order) {
    if (widget.user?.canAssignCarriers() == false) {
      return false;
    }
    if (order?.deleted == true) {
      return false;
    }
    if (order!.hasTripOnMinimumStage(TripStage.loaded)) {
      return false;
    }
    return order.carrierOffers != null && order.carrierOffers!.isNotEmpty;
  }

  bool _canFinishOrderManually(Order? order) {
    if (widget.user?.role == Role.customer) {
      return false;
    }
    if (order?.deleted == true) {
      return false;
    }
    final offer = order?.getAcceptedOffer();
    if (offer == null) {
      return false;
    }
    return offer.trip?.stage != TripStage.unloaded;
  }

  bool _canCancelOrder(Order order) {
    if (widget.user?.role == Role.customer) {
      return false;
    }
    if (order.deleted == true) {
      return false;
    }
    if (order.offers == null || order.offers!.isEmpty) {
      return false;
    }
    return !order.hasTripOnMinimumStage(TripStage.loaded);
  }

  bool _canCancelOrderByCustomer(Order order) {
    if (widget.user?.role != Role.customer) {
      return false;
    }
    return order.distributedTonnage == 0;
  }

  bool _canDeleteOrder(Order order) {
    if (widget.user?.canDeleteOrders() == false) {
      return false;
    }
    if (widget.user?.role == Role.dispatcher &&
        (order.author == null || order.author?.id != widget.user?.id)) {
      return false;
    }
    if (order.deleted == true) {
      return false;
    }
    if (order.offers != null && order.offers!.isNotEmpty) {
      return false;
    }
    return true;
  }

  bool _canSendOrder(Order? order) {
    if (widget.user?.role == Role.customer) {
      return false;
    }
    if (widget.user?.role == Role.dispatcher &&
        widget.order!.isActionsAllowedForDispatcher(widget.user) == false) {
      return false;
    }
    if (order?.deleted == true) {
      return false;
    }
    if (order?.undistributedTonnage == 0) {
      return false;
    }
    return true;
  }
}
