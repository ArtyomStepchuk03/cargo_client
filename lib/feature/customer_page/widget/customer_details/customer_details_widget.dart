import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/form/contact/multiple_contact_form_group.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_verify/customer_verify_field.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/util/data_load_status.dart';
import 'package:manager_mobile_client/util/format/currency.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/price_type.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';

class CustomerDetailsWidget extends StatefulWidget {
  final Customer? customer;

  CustomerDetailsWidget({this.customer});

  @override
  State<StatefulWidget> createState() => CustomerDetailsState();
}

class CustomerDetailsState extends State<CustomerDetailsWidget> {
  CustomerDetailsState() : _status = DataLoadStatus.inProgress();

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
        title: Text(short.formatCustomerSafe(context, widget.customer)),
      ),
      body: _buildBody(),
    );
  }

  DataLoadStatus<ContractorVerifyResult, Exception> _status;

  Widget _buildBody() {
    return buildForm(children: [
      MultipleContactFormGroup(widget.customer?.contacts ?? []),
      _buildInformationGroup(widget.customer),
      _buildVerifyGroup(),
    ]);
  }

  Widget _buildInformationGroup(Customer? customer) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.account_balance_wallet,
        buildCustomNoneditableTextField(
            context: context,
            text: formatPriceTypeSafe(context, customer?.priceType),
            label: localizationUtil.priceTypeCustomer,
            enabled: false),
      ),
    ]);
  }

  Widget _buildVerifyGroup() {
    final localizationUtil = LocalizationUtil.of(context);
    if (_status.inProgress) {
      return buildFormGroup([
        buildFormRow(
          null,
          Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ]);
    } else if (_status.failed) {
      return buildFormGroup([
        buildFormRow(
            null,
            Text(localizationUtil.verifyErrorClient,
                style: TextStyle(color: Colors.red)))
      ]);
    }
    return _buildLoadedVerifyGroup(_status.result);
  }

  Widget _buildLoadedVerifyGroup(ContractorVerifyResult? result) {
    final localizationUtil = LocalizationUtil.of(context);
    final children = [
      buildFormRow(
        null,
        buildCustomNoneditableTextField(
            context: context,
            text: formatCurrencySafe(result?.accountsReceivable),
            label: localizationUtil.accountsReceivable,
            enabled: false),
        buildCustomNoneditableTextField(
            context: context,
            text: formatCurrencySafe(result?.accountsPayable),
            label: localizationUtil.accountsPayable,
            enabled: false),
      ),
      buildFormRow(
        null,
        buildCustomNoneditableTextField(
            context: context,
            text: formatDateOnlySafe(result?.lastPaymentDate),
            label: localizationUtil.lastPaymentDate,
            enabled: false),
      ),
    ];
    if (result?.allowed == false && result?.stopFactor != null) {
      children.add(buildFormRow(
          Icons.error_outline,
          buildVerifyErrorField(
              '${localizationUtil.stopFactor}: ${result?.stopFactor}')));
    }
    return buildFormGroup(children);
  }

  void _verify(BuildContext context, Customer? customer) async {
    final dependencyState = DependencyHolder.of(context);
    final serverAPI = dependencyState.network.serverAPI.customers;
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
}
