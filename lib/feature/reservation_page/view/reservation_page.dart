import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/date_control.dart';
import 'package:manager_mobile_client/common/fullscreen_activity_widget.dart';
import 'package:manager_mobile_client/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/feature/auth_page/cubit/auth_cubit.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
import 'package:manager_mobile_client/src/logic/core/date_utility.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/util/data_load_status.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'reservation_summary.dart';

class ReservationListLoadResult {
  final List<Order?>? reservations;
  final List<Order?>? reservationsDayBefore;
  ReservationListLoadResult(this.reservations, {this.reservationsDayBefore});
}

class ReservationListSharedData {
  final Configuration? configuration;
  final Map<Tuple3<ArticleBrand?, Supplier?, LoadingPoint?>, num>?
      purchaseTariffMap;
  ReservationListSharedData({this.configuration, this.purchaseTariffMap});
}

typedef ReservationListBuilder = Widget Function(
    BuildContext context,
    ReservationListLoadResult? loadResult,
    ReservationListSharedData? sharedData,
    User? user,
    DateTime? date);

class ReservationPage extends StatefulWidget {
  final Drawer? drawer;
  final TransitionBuilder? containerBuilder;
  final ReservationListBuilder? builder;

  ReservationPage(this.drawer, this.containerBuilder, this.builder);

  @override
  State<StatefulWidget> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  @override
  void initState() {
    super.initState();
    _date = DateTime.now().add(Duration(days: 1)).beginningOfDay;
    _loadStatus = DataLoadStatus.inProgress(null, null);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_serverAPI == null) {
      _serverAPI = DependencyHolder.of(context)?.network.serverAPI.orders;
      _user = context.read<AuthCubit>().state.user;
      await _loadSharedData();
      if (_sharedData == null) {
        return;
      }
      await _load(_date!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.requests),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: DateControl(
            color: Colors.white,
            initialValue: _date!,
            onChanged: _handleDateChange,
            enabled: _sharedData != null,
          ),
        ),
      ),
      drawer: widget.drawer,
      body: widget.containerBuilder!(context, _buildBody()),
    );
  }

  OrderServerAPI? _serverAPI;
  User? _user;
  ReservationListSharedData? _sharedData;
  DateTime? _date;
  DataLoadStatus<ReservationListLoadResult, Exception>? _loadStatus;

  Widget _buildBody() {
    if (_loadStatus!.inProgress) {
      return FullscreenActivityWidget();
    }
    if (_loadStatus!.failed) {
      return buildFullscreenError(context);
    }
    return widget.builder!(
        context, _loadStatus?.result, _sharedData, _user, _date);
  }

  void _handleDateChange(DateTime date) {
    _date = date;
    setState(() => _loadStatus = DataLoadStatus.inProgress(null, null));
    _load(date);
  }

  Future<void> _loadSharedData() async {
    final dependencyState = DependencyHolder.of(context);
    try {
      await dependencyState?.network.configurationLoader.reload();
      final configuration =
          dependencyState?.network.configurationLoader.configuration;
      final purchaseTariffs =
          await dependencyState?.network.serverAPI.purchaseTariffs.list();
      final purchaseTariffMap = PurchaseTariffMap.build(purchaseTariffs);
      if (!mounted) {
        return;
      }
      if (configuration == null) {
        setState(() => _loadStatus = DataLoadStatus.failed(null, null));
        return;
      }
      setState(() => _sharedData = ReservationListSharedData(
          configuration: configuration, purchaseTariffMap: purchaseTariffMap));
    } catch (exception) {
      if (!mounted) {
        return;
      }
      setState(() =>
          _loadStatus = DataLoadStatus.failed(null, exception as Exception?));
    }
  }

  Future<void> _load(DateTime date) async {
    DataLoadStatus<ReservationListLoadResult, Exception> status;
    try {
      final reservations = await _serverAPI?.listReservations(_user, date);
      final reservationsDayBefore = await _serverAPI?.listReservations(
          _user, date.subtract(Duration(days: 1)));
      status = DataLoadStatus.succeeded(
          ReservationListLoadResult(reservations,
              reservationsDayBefore: reservationsDayBefore),
          null);
    } catch (exception) {
      status = DataLoadStatus.failed(null, exception as Exception?);
    }

    if (!mounted) {
      return;
    }
    if (date != _date) {
      return;
    }

    setState(() => _loadStatus = status);
  }
}
