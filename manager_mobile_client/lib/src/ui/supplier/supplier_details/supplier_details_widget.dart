import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/server_api/supplier_server_api.dart';
import 'package:manager_mobile_client/src/ui/utility/data_load_status.dart';
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'package:manager_mobile_client/src/ui/format/currency.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/form/contact/multiple_contact_form_group.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'supplier_details_strings.dart' as strings;

class SupplierDetailsWidget extends StatefulWidget {
  final Supplier supplier;

  SupplierDetailsWidget({this.supplier});

  @override
  State<StatefulWidget> createState() => SupplierDetailsState();
}

class SupplierDetailsState extends State<SupplierDetailsWidget> {
  SupplierDetailsState() : _status = DataLoadStatus.inProgress();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_status.inProgress) {
      _verify(context, widget.supplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(short.formatSupplierSafe(widget.supplier)),
      ),
      body: _buildBody(),
    );
  }

  DataLoadStatus<ContractorVerifyResult, Exception> _status;

  Widget _buildBody() {
    return buildForm(children: [
      MultipleContactFormGroup(widget.supplier.contacts ?? []),
      _buildVerifyGroup(),
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

  void _verify(BuildContext context, Supplier supplier) async {
    final dependencyState = DependencyHolder.of(context);
    final serverAPI = dependencyState.network.serverAPI.suppliers;
    try {
      final result = await serverAPI.verify(supplier);
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
