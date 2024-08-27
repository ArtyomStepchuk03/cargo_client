import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/number_parse.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/form/attachment/attachment_form_group.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/validators/common_validators.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/order/order_details/order_distance_form_row.dart';
import 'package:manager_mobile_client/src/ui/transport_unit/transport_unit_tab_strings.dart' as transport_unit_tab_strings;
import 'order_finish_strings.dart' as strings;

class OrderFinishWidget extends StatefulWidget {
  final Order order;

  OrderFinishWidget(this.order);

  @override
  State<StatefulWidget> createState() => OrderFinishState();
}

class OrderFinishState extends State<OrderFinishWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: _buildForm(),
    );
  }

  final _formKey = GlobalKey<ScrollableFormState>();
  final _loadedDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _loadedTonnageKey = GlobalKey<FormFieldState<String>>();
  final _distanceKey = GlobalKey<OrderDistanceFormRowState>();
  final _loadedPhotoFormGroupKey = GlobalKey<AttachmentFormGroupState>();
  final _unloadedDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _unloadedTonnageKey = GlobalKey<FormFieldState<String>>();
  final _unloadedPhotoFormGroupKey = GlobalKey<AttachmentFormGroupState>();

  Widget _buildForm() {
    final trip = widget.order.getAcceptedOffer().trip;
    return buildForm(key: _formKey, children: [
      _buildLoadedGroup(widget.order, trip),
      _buildUnloadedGroup(widget.order, trip),
    ]);
  }

  Widget _buildLoadedGroup(Order order, Trip trip) {
    final tripHistoryRecord = trip.getHistoryRecord(TripStage.loaded);
    return buildFormGroup([
      buildFormRow(Icons.event_note,
        _buildDateFormField(key: _loadedDateKey, label: strings.loadedDate, value: tripHistoryRecord?.date, enabled: tripHistoryRecord == null)
      ),
      buildFormRow(Icons.local_mall,
        _buildTonnageFormField(key: _loadedTonnageKey, label: strings.loadedTonnage, value: tripHistoryRecord?.tonnage, enabled: tripHistoryRecord == null)
      ),
      OrderDistanceFormRow(
        key: _distanceKey,
        initialValue: tripHistoryRecord?.additionalData?.distance,
        loadingPoint: widget.order.loadingPoint,
        unloadingPoint: widget.order.unloadingPoint,
        validator: NumberValidator.required(decimal: false, minimum: 0),
        editing: tripHistoryRecord == null,
        manualEditing: true,
      ),
      if (tripHistoryRecord == null)
        _buildAttachmentFormGroup(_loadedPhotoFormGroupKey, strings.loadedPhotoButtonTitle),
    ]);
  }

  Widget _buildUnloadedGroup(Order order, Trip trip) {
    return buildFormGroup([
      buildFormRow(Icons.event_note,
        _buildDateFormField(key: _unloadedDateKey, label: strings.unloadedDate)
      ),
      buildFormRow(Icons.local_mall,
        _buildTonnageFormField(key: _unloadedTonnageKey, label: strings.unloadedTonnage)
      ),
      _buildAttachmentFormGroup(_unloadedPhotoFormGroupKey, strings.unloadedPhotoButtonTitle),
    ]);
  }

  Widget _buildDateFormField({Key key, String label, DateTime value, bool enabled = true}) {
    return DateFormField(key: key, initialValue: value, label: label, validator: RequiredValidator(), enabled: enabled);
  }

  Widget _buildTonnageFormField({Key key, String label, num value, bool enabled = true}) {
    return buildCustomNumberFormField(key: key, initialValue: numberOrEmpty(value), label: label, validator: makeRequiredTonnageValidator(), enabled: enabled);
  }

  Widget _buildAttachmentFormGroup(Key key, String buttonTitle) {
    return AttachmentFormGroup(
      key: key,
      buttonTitle: buttonTitle,
      attachedText: strings.photoAttached,
      notAttachedText: strings.photoNotAttached,
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _finish(context)),
    ];
  }

  void _finish(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    final trip = widget.order.getAcceptedOffer().trip;
    final setLoadedStage = trip.stage == null || trip.stage.index < TripStage.loaded.index;

    final loadedDate = setLoadedStage ? _loadedDateKey.currentState.value : null;
    final loadedTonnage = setLoadedStage ? parseDecimal(_loadedTonnageKey.currentState.value) : null;
    final distance = setLoadedStage ? _distanceKey.currentState?.distance : null;
    final loadedPhoto = setLoadedStage ? _loadedPhotoFormGroupKey.currentState.file : null;
    final unloadedDate = _unloadedDateKey.currentState.value;
    final unloadedTonnage = parseDecimal(_unloadedTonnageKey.currentState.value);
    final unloadedPhoto = _unloadedPhotoFormGroupKey.currentState.file;

    final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;

    showDefaultActivityDialog(context);

    try {
      await serverAPI.finish(widget.order, loadedDate, loadedTonnage, loadedPhoto, distance, unloadedDate, unloadedTonnage, unloadedPhoto);
      Navigator.pop(context);
    } on Exception {
      Navigator.pop(context);
      await showDefaultErrorDialog(context);
      return;
    }

    await _disband(context);
    Navigator.pop(context, widget.order);
  }

  Future<void> _disband(BuildContext context) async {
    final offer = widget.order.getAcceptedOffer();
    if (offer == null) {
      return;
    }

    bool disbandConfirmed = await showQuestionDialog(context, transport_unit_tab_strings.confirmDisband);
    if (!disbandConfirmed) {
      return;
    }

    final serverAPI = DependencyHolder.of(context).network.serverAPI.transportUnits;

    showDefaultActivityDialog(context);

    try {
      await serverAPI.disband(offer.transportUnit);
      Navigator.pop(context);
    } on Exception {
      Navigator.pop(context);
      await showDefaultErrorDialog(context);
    }
  }
}
