import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/common/fullscreen_activity_widget.dart';
import 'package:manager_mobile_client/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/util/data_load_status.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';

import 'customer_verify_field.dart';

class CustomerVerifyWidget extends StatefulWidget {
  CustomerVerifyWidget(this.customer);

  final Customer? customer;

  @override
  State<StatefulWidget> createState() => CustomerVerifyState();
}

class CustomerVerifyState extends State<CustomerVerifyWidget> {
  CustomerVerifyState() : _status = DataLoadStatus.inProgress();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_status.inProgress) {
      _verify(context, widget.customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
          title: Text(short.formatCustomerSafe(context, widget.customer))),
      body: _buildBody(),
      floatingActionButton: _status.succeeded && _status.result?.allowed == true
          ? _buildContinueButton(context)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  DataLoadStatus<ContractorVerifyResult, Exception> _status;

  Widget _buildBody() {
    if (_status.inProgress) {
      return FullscreenActivityWidget();
    } else if (_status.failed) {
      return buildFullscreenError(context);
    }
    return _buildResultWidget(_status.result);
  }

  Widget _buildResultWidget(ContractorVerifyResult? result) {
    final localizationUtil = LocalizationUtil.of(context);
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildAccountsReceivableField(result),
          if (result?.allowed == false && result?.stopFactor != null)
            _buildRow(buildVerifyErrorField(
                '${localizationUtil.stopFactor}: ${result?.stopFactor}')),
        ],
      ),
    );
  }

  Widget buildAccountsReceivableField(ContractorVerifyResult? result) {
    final localizationUtil = LocalizationUtil.of(context);
    final text =
        '${localizationUtil.accountsReceivable}: ${result?.accountsReceivable}'; // strings.accountsReceivableWithValue(formatCurrencySafe(result.accountsReceivable));
    if (result?.allowed == true) {
      return _buildRow(buildVerifyPermitField(text));
    }
    return _buildRow(buildVerifyWarningField(text));
  }

  Widget _buildRow(Widget child) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: child,
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFloatingActionButtonContainer(
      child: FloatingActionButton.extended(
        icon: Container(),
        label: Text(localizationUtil.continueText.toUpperCase()),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _continue(context),
      ),
    );
  }

  void _verify(BuildContext context, Customer? customer) async {
    final serverAPI = DependencyHolder.of(context).network.serverAPI.customers;
    try {
      final result = await serverAPI.verify(customer);
      if (mounted) {
        setState(() => _status = DataLoadStatus.succeeded(result));
      }
    } on Exception catch (exception) {
      if (mounted) {
        setState(() => _status = DataLoadStatus.failed(exception));
      }
    }
  }

  void _continue(BuildContext context) {
    Navigator.pop(context, true);
  }
}
