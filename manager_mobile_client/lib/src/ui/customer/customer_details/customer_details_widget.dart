import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/utility/data_load_status.dart';
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'package:manager_mobile_client/src/ui/format/currency.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/format/price_type.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/form/contact/multiple_contact_form_group.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/customer/customer_verify/customer_verify_field.dart';
import 'customer_details_strings.dart' as strings;

class CustomerDetailsWidget extends StatefulWidget {
  final Customer customer;

  CustomerDetailsWidget({this.customer});

  @override
  State<StatefulWidget> createState() => CustomerDetailsState();
}

class CustomerDetailsState extends State<CustomerDetailsWidget> {
  CustomerDetailsState() : _status = DataLoadStatus.inProgress();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.customer.internal && _status.inProgress) {
      _verify(context, widget.customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(short.formatCustomerSafe(widget.customer)),
      ),
      body: _buildBody(),
    );
  }

  DataLoadStatus<ContractorVerifyResult, Exception> _status;

  Widget _buildBody() {
    return buildForm(children: [
      MultipleContactFormGroup(widget.customer.contacts ?? []),
      _buildInformationGroup(widget.customer),
      if (!widget.customer.internal) _buildVerifyGroup(),
    ]);
  }

  Widget _buildInformationGroup(Customer customer) {
    return buildFormGroup([
      buildFormRow(Icons.account_balance_wallet,
        buildCustomNoneditableTextField(context: context, text: formatPriceTypeSafe(customer.priceType), label: strings.priceTypeCustomer, enabled: false),
      ),
    ]);
  }

  Widget _buildVerifyGroup() {
    if (_status.inProgress) {
      return buildFormGroup([
        buildFormRow(null, Center(child: CircularProgressIndicator()))
      ]);
    } else if (_status.failed) {
      return buildFormGroup([
        buildFormRow(null, Text(strings.verifyError, style: TextStyle(color: Colors.red)))
      ]);
    } else {
      return _buildLoadedVerifyGroup(_status.result);
    }
  }

  Widget _buildLoadedVerifyGroup(ContractorVerifyResult result) {
    final children = [
      buildFormRow(null,
        buildCustomNoneditableTextField(context: context, text: formatCurrencySafe(result.accountsReceivable), label: strings.accountsReceivable, enabled: false),
        buildCustomNoneditableTextField(context: context, text: formatCurrencySafe(result.accountsPayable), label: strings.accountsPayable, enabled: false),
      ),
      buildFormRow(null,
        buildCustomNoneditableTextField(context: context, text: formatDateOnlySafe(result.lastPaymentDate), label: strings.lastPaymentDate, enabled: false),
      ),
    ];
    if (!result.allowed && result.stopFactor != null) {
      children.add(buildFormRow(Icons.error_outline,
        buildVerifyErrorField(strings.stopFactorWithValue(result.stopFactor))
      ));
    }
    return buildFormGroup(children);
  }

  void _verify(BuildContext context, Customer customer) async {
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
