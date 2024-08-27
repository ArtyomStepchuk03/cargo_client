import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/utility/data_load_status.dart';
import 'package:manager_mobile_client/src/ui/common/floating_action_button.dart';
import 'package:manager_mobile_client/src/ui/common/fullscreen_activity_widget.dart';
import 'package:manager_mobile_client/src/ui/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/src/ui/format/currency.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'customer_verify_field.dart';
import 'customer_verify_strings.dart' as strings;

class CustomerVerifyWidget extends StatefulWidget {
  final Customer customer;

  CustomerVerifyWidget(this.customer);

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
      appBar: buildAppBar(title: Text(short.formatCustomerSafe(widget.customer))),
      body: _buildBody(),
      floatingActionButton: _status.succeeded && _status.result.allowed ? _buildContinueButton(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  DataLoadStatus<ContractorVerifyResult, Exception> _status;

  Widget _buildBody() {
    if (_status.inProgress) {
      return FullscreenActivityWidget();
    } else if (_status.failed) {
      return buildFullscreenError();
    } else {
      return _buildResultWidget(_status.result);
    }
  }

  Widget _buildResultWidget(ContractorVerifyResult result) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildAccountsReceivableField(result),
          if (!result.allowed && result.stopFactor != null)
            _buildRow(buildVerifyErrorField(strings.stopFactorWithValue(result.stopFactor))),
        ],
      ),
    );
  }

  Widget buildAccountsReceivableField(ContractorVerifyResult result) {
    final text = strings.accountsReceivableWithValue(formatCurrencySafe(result.accountsReceivable));
    if (result.allowed) {
      return _buildRow(buildVerifyPermitField(text));
    } else {
      return _buildRow(buildVerifyWarningField(text));
    }
  }

  Widget _buildRow(Widget child) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: child,
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return buildFloatingActionButtonContainer(
      child: FloatingActionButton.extended(
        icon: Container(),
        label: Text(strings.continueUppercase),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _continue(context),
      ),
    );
  }

  void _verify(BuildContext context, Customer customer) async {
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
