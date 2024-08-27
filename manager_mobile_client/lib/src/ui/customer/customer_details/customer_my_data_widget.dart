import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/src/ui/utility/data_load_status.dart';
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'package:manager_mobile_client/src/ui/format/currency.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/form/contact/multiple_contact_form_group.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/authorization/authorization_widget.dart';
import '../../common/app_bar.dart';
import 'customer_my_data_strings.dart' as strings;

class CustomerMyDataWidget extends StatefulWidget {
  final Drawer drawer;
  final TransitionBuilder containerBuilder;

  CustomerMyDataWidget(this.drawer, this.containerBuilder);

  @override
  State<StatefulWidget> createState() => CustomerMyDataState();
}

class CustomerMyDataState extends State<CustomerMyDataWidget> {
  CustomerMyDataState() : _loadStatus = DataLoadStatus.inProgress();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null) {
      _user = AuthorizationWidget.of(context).user;
      if (!_user.customer.internal) {
        _getStatus(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
      ),
      drawer: widget.drawer,
      body: widget.containerBuilder(context, _buildBody()),
    );
  }

  User _user;
  DataLoadStatus<ContractorVerifyResult, Exception> _loadStatus;

  Widget _buildBody() {
    return buildForm(children: [
      MultipleContactFormGroup(_user.customer.contacts ?? []),
      if (!_user.customer.internal) _buildStatusGroup(),
    ]);
  }

  Widget _buildStatusGroup() {
    if (_loadStatus.inProgress) {
      return buildFormGroup([
        buildFormRow(null, Center(child: CircularProgressIndicator()))
      ]);
    }
    if (_loadStatus.failed) {
      return buildFormGroup([
        buildFormRow(null, Text(strings.getStatusError, style: TextStyle(color: Colors.red)))
      ]);
    }
    return _buildLoadedStatusGroup(_loadStatus.result);
  }

  Widget _buildLoadedStatusGroup(ContractorVerifyResult result) {
    return buildFormGroup([
      buildFormRow(null,
        buildCustomNoneditableTextField(context: context, text: formatCurrencySafe(result.accountsReceivable), label: strings.accountsReceivable, enabled: false),
        buildCustomNoneditableTextField(context: context, text: formatCurrencySafe(result.accountsPayable), label: strings.accountsPayable, enabled: false),
      ),
      buildFormRow(null,
        buildCustomNoneditableTextField(context: context, text: formatDateOnlySafe(result.lastPaymentDate), label: strings.lastPaymentDate, enabled: false),
      ),
    ]);
  }

  void _getStatus(BuildContext context) async {
    try {
      final serverAPI = DependencyHolder.of(context).network.serverAPI.customers;
      final result = await serverAPI.getStatus();
      if (mounted) {
        setState(() => _loadStatus = DataLoadStatus.succeeded(result));
      }
    } on Exception catch (exception) {
      if (mounted) {
        setState(() => _loadStatus = DataLoadStatus.failed(exception));
      }
    }
  }
}
