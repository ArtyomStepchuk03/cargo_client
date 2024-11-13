import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/form/contact/multiple_contact_form_group.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/auth_page/auth_page.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/util/data_load_status.dart';
import 'package:manager_mobile_client/util/format/currency.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

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
      _user = AuthPage.of(context).user;
      if (!_user.customer.internal) {
        _getStatus(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.myDetails),
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
    final localizationUtil = LocalizationUtil.of(context);
    if (_loadStatus.inProgress) {
      return buildFormGroup(
          [buildFormRow(null, Center(child: CircularProgressIndicator()))]);
    }
    if (_loadStatus.failed) {
      return buildFormGroup([
        buildFormRow(
            null,
            Text(localizationUtil.getMyDetailsStatusError,
                style: TextStyle(color: Colors.red)))
      ]);
    }
    return _buildLoadedStatusGroup(_loadStatus.result);
  }

  Widget _buildLoadedStatusGroup(ContractorVerifyResult result) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        null,
        buildCustomNoneditableTextField(
            context: context,
            text: formatCurrencySafe(result.accountsReceivable),
            label: localizationUtil.accountsReceivable,
            enabled: false),
        buildCustomNoneditableTextField(
            context: context,
            text: formatCurrencySafe(result.accountsPayable),
            label: localizationUtil.accountsPayable,
            enabled: false),
      ),
      buildFormRow(
        null,
        buildCustomNoneditableTextField(
            context: context,
            text: formatDateOnlySafe(result.lastPaymentDate),
            label: localizationUtil.lastPaymentDate,
            enabled: false),
      ),
    ]);
  }

  void _getStatus(BuildContext context) async {
    try {
      final serverAPI =
          DependencyHolder.of(context).network.serverAPI.customers;
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
