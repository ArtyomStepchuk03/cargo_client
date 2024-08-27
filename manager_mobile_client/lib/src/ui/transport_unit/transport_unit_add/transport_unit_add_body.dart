import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'transport_unit_add_form_fields.dart';

class TransportUnitAddInformation {
  Driver driver;
  Vehicle vehicle;
  Trailer trailer;
}

class TransportUnitAddBody extends StatefulWidget {
  final User user;

  TransportUnitAddBody({Key key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransportUnitAddBodyState();
}

class TransportUnitAddBodyState extends State<TransportUnitAddBody> {
  TransportUnitAddInformation validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final createInformation = TransportUnitAddInformation();
    createInformation.driver = _driverKey.currentState.value;
    createInformation.vehicle = _vehicleKey.currentState.value;
    createInformation.trailer = _trailerKey.currentState.value;
    return createInformation;
  }

  @override
  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    return buildForm(key: _formKey, children: [
      _buildMainGroup(dependencyState),
    ]);
  }

  final _formKey = GlobalKey<ScrollableFormState>();

  final _carrierKey = GlobalKey<LoadingListFormFieldState<Carrier>>();
  final _driverKey = GlobalKey<LoadingListFormFieldState<Driver>>();
  final _vehicleKey = GlobalKey<LoadingListFormFieldState<Vehicle>>();
  final _trailerKey = GlobalKey<LoadingListFormFieldState<Trailer>>();

  Widget _buildMainGroup(DependencyState dependencyState) {
    return buildFormGroup([
      if (_shouldShowCarrierSelection)
        buildFormRow(null,
          buildCarrierFormField(
            key: _carrierKey,
            serverAPI: dependencyState.network.serverAPI.carriers,
            cache: dependencyState.caches.carrier,
            onChanged: _handleCarrierChanged,
          )
        ),
      buildFormRow(Icons.person,
        buildDriverFormField(
          key: _driverKey,
          serverAPI: dependencyState.network.serverAPI.drivers,
          cacheMap: dependencyState.caches.driver,
          carrier: _filterCarrier,
        )
      ),
      buildFormRow(Icons.local_shipping,
        buildVehicleFormField(
          key: _vehicleKey,
          serverAPI: dependencyState.network.serverAPI.vehicles,
          cacheMap: dependencyState.caches.vehicle,
          carrier: _filterCarrier,
        )
      ),
      buildFormRow(null,
        buildTrailerFormField(
          key: _trailerKey,
          serverAPI: dependencyState.network.serverAPI.trailers,
          cacheMap: dependencyState.caches.trailer,
          carrier: _filterCarrier,
        )
      ),
    ]);
  }

  void _handleCarrierChanged(Carrier value) {
    _driverKey.currentState.value = null;
    _vehicleKey.currentState.value = null;
    _trailerKey.currentState.value = null;
    setState(() {});
  }

  Carrier get _filterCarrier => _shouldShowCarrierSelection ? _carrierKey.currentState?.value : widget.user.carrier;
  bool get _shouldShowCarrierSelection => widget.user.role != Role.dispatcher;
}
