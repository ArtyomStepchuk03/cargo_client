import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/loading_list_form_field/loading_list_form_field.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'transport_unit_add_data_sources.dart';
import 'transport_unit_add_form_fields.dart';

class CreateCarriagePage extends StatefulWidget {
  final User? user;

  CreateCarriagePage({this.user});

  @override
  State<StatefulWidget> createState() => _CreateCarriagePageState();
}

class _CreateCarriagePageState extends State<CreateCarriagePage> {
  final _formKey = GlobalKey<ScrollableFormState>();

  final _carrierKey = GlobalKey<LoadingListFormFieldState<Carrier>>();
  final _driverKey = GlobalKey<LoadingListFormFieldState<Driver>>();
  final _vehicleKey = GlobalKey<LoadingListFormFieldState<Vehicle>>();
  final _trailerKey = GlobalKey<LoadingListFormFieldState<Trailer>>();

  @override
  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.createCarriage),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () => _save(context),
          )
        ],
      ),
      body: _buildForm(dependencyState),
    );
  }

  Widget _buildForm(DependencyState? dependencyState) {
    return ScrollableForm(
      key: _formKey,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      children: [
        if (_shouldShowCarrierSelection)
          buildFormRow(
            null,
            buildCarrierFormField(
              context,
              key: _carrierKey,
              serverAPI: dependencyState!.network.serverAPI.carriers,
              cache: dependencyState.caches.carrier,
              onChanged: _handleCarrierChanged,
            ),
          ),
        buildFormRow(
          Icons.person,
          buildDriverFormField(
            context,
            key: _driverKey,
            serverAPI: dependencyState!.network.serverAPI.drivers,
            cacheMap: dependencyState.caches.driver,
            carrier: _filterCarrier,
          ),
        ),
        buildFormRow(
          Icons.local_shipping,
          buildVehicleFormField(
            context,
            key: _vehicleKey,
            serverAPI: dependencyState.network.serverAPI.vehicles,
            cacheMap: dependencyState.caches.vehicle,
            carrier: _filterCarrier,
          ),
        ),
        buildFormRow(
          null,
          buildTrailerFormField(
            context,
            key: _trailerKey,
            serverAPI: dependencyState.network.serverAPI.trailers,
            cacheMap: dependencyState.caches.trailer,
            carrier: _filterCarrier,
          ),
        ),
      ],
    );
  }

  void _handleCarrierChanged(Carrier? value) {
    _driverKey.currentState?.value = null;
    _vehicleKey.currentState?.value = null;
    _trailerKey.currentState?.value = null;
    setState(() {});
  }

  Carrier? get _filterCarrier => _shouldShowCarrierSelection
      ? _carrierKey.currentState?.value
      : widget.user?.carrier;
  bool get _shouldShowCarrierSelection => widget.user?.role != Role.dispatcher;

  void _save(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final information = validate();
    if (information != null) {
      showActivityDialog(context, localizationUtil.saving);
      final serverAPI =
          DependencyHolder.of(context)!.network.serverAPI.transportUnits;

      try {
        final transportUnit = await serverAPI.create(
            information.driver, information.vehicle, information.trailer);
        Navigator.pop(context);
        Navigator.pop(context, transportUnit);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  TransportUnitAddInformation? validate() {
    if (!_formKey.currentState!.validate()!) {
      return null;
    }
    final createInformation = TransportUnitAddInformation();
    createInformation.driver = _driverKey.currentState?.value;
    createInformation.vehicle = _vehicleKey.currentState?.value;
    createInformation.trailer = _trailerKey.currentState?.value;
    return createInformation;
  }
}

class TransportUnitAddInformation {
  Driver? driver;
  Vehicle? vehicle;
  Trailer? trailer;
}
