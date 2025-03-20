import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/contact/multiple_contact_form_group.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/server_api/supplier_server_api.dart';
import 'package:manager_mobile_client/util/data_load_status.dart';
import 'package:manager_mobile_client/util/format/currency.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';

class SupplierDetailsWidget extends StatefulWidget {
  final Supplier? supplier;

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
        title: Text(short.formatSupplierSafe(context, widget.supplier)),
      ),
      body: _buildContent(),
    );
  }

  DataLoadStatus<ContractorVerifyResult, Exception> _status;

  Widget _buildContent() {
    return buildForm(children: [
      MultipleContactFormGroup(widget.supplier?.contacts ?? []),
      _buildVerifyGroup(),
    ]);
  }

  Widget _buildVerifyGroup() {
    final localizationUtil = LocalizationUtil.of(context);
    if (_status.inProgress) {
      return buildFormGroup(
          [buildFormRow(null, Center(child: CircularProgressIndicator()))]);
    } else if (_status.failed) {
      return buildFormGroup([
        buildFormRow(
            null,
            Text(localizationUtil.verifyErrorSupplier,
                style: TextStyle(color: Colors.red)))
      ]);
    }
    return _buildLoadedVerifyGroup(_status.result);
  }

  Widget _buildLoadedVerifyGroup(ContractorVerifyResult? result) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
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
    ]);
  }

  void _verify(BuildContext context, Supplier? supplier) async {
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
