import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/validators/common_validators.dart';
import 'vehicle_add_strings.dart' as strings;
import 'vehicle_add_form_fields.dart';

class VehicleAddBody extends StatefulWidget {
  final Carrier carrier;

  VehicleAddBody({Key key, this.carrier}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VehicleAddBodyState();
}

class VehicleAddBodyState extends State<VehicleAddBody> {
  Vehicle validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final vehicle = Vehicle();
    vehicle.model = _modelKey.currentState.value;
    vehicle.number = _numberKey.currentState.value;
    vehicle.tonnage = int.parse(_tonnageKey.currentState.value);
    vehicle.carrier = widget.carrier;
    return vehicle;
  }

  @override
  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    return buildForm(key: _formKey, children: [
      _buildMainGroup(dependencyState),
    ]);
  }

  final _formKey = GlobalKey<ScrollableFormState>();

  final _modelKey = GlobalKey<LoadingListFormFieldState<VehicleModel>>();
  final _numberKey = GlobalKey<FormFieldState<String>>();
  final _tonnageKey = GlobalKey<FormFieldState<String>>();

  VehicleBrand _brand;

  Widget _buildMainGroup(DependencyState dependencyState) {
    return buildFormGroup([
      buildFormRow(Icons.local_shipping,
        buildVehicleBrandFormField(
          dependencyState.network.serverAPI.vehicleBrands,
          dependencyState.caches.vehicleBrand,
          _handleBrandChanged,
        )
      ),
      buildFormRow(null,
        buildVehicleModelFormField(
          _modelKey,
          dependencyState.network.serverAPI.vehicleModels,
          dependencyState.caches.vehicleModel,
          _brand,
        )
      ),
      buildFormRow(null,
        CustomTextFormField(
          key: _numberKey,
          initialValue: '',
          label: strings.stateNumber,
          validator: VehicleNumberValidator.required(),
        )
      ),
      buildFormRow(null,
        buildCustomIntegerFormField(
          key: _tonnageKey,
          initialValue: '',
          label: strings.tonnage,
          validator: makeRequiredTonnageValidator(decimal: false),
        )
      ),
    ]);
  }

  void _handleBrandChanged(VehicleBrand value) {
    setState(() {
      _brand = value;
    });
    _modelKey.currentState.value = null;
  }
}
