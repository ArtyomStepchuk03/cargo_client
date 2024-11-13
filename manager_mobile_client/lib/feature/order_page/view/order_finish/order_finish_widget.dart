import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/attachment/attachment_form_group.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_details/order_distance_form_row.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/core/number_parse.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class OrderFinishWidget extends StatefulWidget {
  final Order order;

  OrderFinishWidget(this.order);

  @override
  State<StatefulWidget> createState() => OrderFinishState();
}

class OrderFinishState extends State<OrderFinishWidget> {
  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.completeOrder),
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
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
          Icons.event_note,
          _buildDateFormField(
              key: _loadedDateKey,
              label: localizationUtil.loadingDateTime,
              value: tripHistoryRecord?.date,
              enabled: tripHistoryRecord == null)),
      buildFormRow(
          Icons.local_mall,
          _buildTonnageFormField(
              key: _loadedTonnageKey,
              label: localizationUtil.loadedTonnage,
              value: tripHistoryRecord?.tonnage,
              enabled: tripHistoryRecord == null)),
      OrderDistanceFormRow(
        key: _distanceKey,
        initialValue: tripHistoryRecord?.additionalData?.distance,
        loadingPoint: widget.order.loadingPoint,
        unloadingPoint: widget.order.unloadingPoint,
        validator:
            NumberValidator.required(context, decimal: false, minimum: 0),
        editing: tripHistoryRecord == null,
        manualEditing: true,
      ),
      if (tripHistoryRecord == null)
        _buildAttachmentFormGroup(
            _loadedPhotoFormGroupKey, localizationUtil.loadedPhotoButtonTitle),
    ]);
  }

  Widget _buildUnloadedGroup(Order order, Trip trip) {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
          Icons.event_note,
          _buildDateFormField(
              key: _unloadedDateKey,
              label: localizationUtil.unloadingDateTime)),
      buildFormRow(
          Icons.local_mall,
          _buildTonnageFormField(
              key: _unloadedTonnageKey,
              label: localizationUtil.unloadedTonnage)),
      _buildAttachmentFormGroup(_unloadedPhotoFormGroupKey,
          localizationUtil.unloadedPhotoButtonTitle),
    ]);
  }

  Widget _buildDateFormField(
      {Key key, String label, DateTime value, bool enabled = true}) {
    return DateFormField(
        key: key,
        initialValue: value,
        label: label,
        validator: RequiredValidator(context),
        enabled: enabled);
  }

  Widget _buildTonnageFormField(
      {Key key, String label, num value, bool enabled = true}) {
    return buildCustomNumberFormField(context,
        key: key,
        initialValue: numberOrEmpty(value),
        label: label,
        validator: makeRequiredTonnageValidator(context),
        enabled: enabled);
  }

  Widget _buildAttachmentFormGroup(Key key, String buttonTitle) {
    final localizationUtil = LocalizationUtil.of(context);
    return AttachmentFormGroup(
      key: key,
      buttonTitle: buttonTitle,
      attachedText: localizationUtil.photoAttached,
      notAttachedText: localizationUtil.photoNotAttached,
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
    final setLoadedStage =
        trip.stage == null || trip.stage.index < TripStage.loaded.index;

    final loadedDate =
        setLoadedStage ? _loadedDateKey.currentState.value : null;
    final loadedTonnage = setLoadedStage
        ? parseDecimal(_loadedTonnageKey.currentState.value)
        : null;
    final distance =
        setLoadedStage ? _distanceKey.currentState?.distance : null;
    final loadedPhoto =
        setLoadedStage ? _loadedPhotoFormGroupKey.currentState.file : null;
    final unloadedDate = _unloadedDateKey.currentState.value;
    final unloadedTonnage =
        parseDecimal(_unloadedTonnageKey.currentState.value);
    final unloadedPhoto = _unloadedPhotoFormGroupKey.currentState.file;

    final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;

    showDefaultActivityDialog(context);

    try {
      await serverAPI.finish(widget.order, loadedDate, loadedTonnage,
          loadedPhoto, distance, unloadedDate, unloadedTonnage, unloadedPhoto);
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
    final localizationUtil = LocalizationUtil.of(context);
    final offer = widget.order.getAcceptedOffer();
    if (offer == null) {
      return;
    }

    bool disbandConfirmed =
        await showQuestionDialog(context, localizationUtil.confirmDisband);
    if (!disbandConfirmed) {
      return;
    }

    final serverAPI =
        DependencyHolder.of(context).network.serverAPI.transportUnits;

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
