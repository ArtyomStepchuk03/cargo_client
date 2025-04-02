import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/add_vehicle_page/widget/add_vehicle_form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class AddVehiclePage extends StatefulWidget {
  final Carrier? carrier;

  AddVehiclePage({this.carrier});

  @override
  State<StatefulWidget> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  VehicleBrand? _brand;

  final _formKey = GlobalKey<ScrollableFormState>();
  final _modelKey = GlobalKey<LoadingListFormFieldState<VehicleModel>>();
  final _numberKey = GlobalKey<FormFieldState<String>>();
  final _tonnageKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    final dependencyState = DependencyHolder.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newTruck),
        actions: _buildActions(context),
      ),
      body: buildForm(key: _formKey, children: [
        buildFormGroup([
          buildFormRow(
            Icons.local_shipping,
            buildVehicleBrandFormField(
              context,
              dependencyState!.network.serverAPI.vehicleBrands,
              dependencyState.caches.vehicleBrand,
              _handleBrandChanged,
            ),
          ),
          buildFormRow(
            null,
            buildVehicleModelFormField(
              context,
              _modelKey,
              dependencyState.network.serverAPI.vehicleModels,
              dependencyState.caches.vehicleModel,
              _brand,
            ),
          ),
          buildFormRow(
            null,
            CustomTextFormField(
              key: _numberKey,
              initialValue: '',
              label: localizationUtil.stateNumber,
              validator: VehicleNumberValidator.required(context),
            ),
          ),
          buildFormRow(
            null,
            buildCustomIntegerFormField(
              context,
              key: _tonnageKey,
              initialValue: '',
              label: localizationUtil.tonnage,
              validator: makeRequiredTonnageValidator(context, decimal: false),
            ),
          ),
        ]),
      ]),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final vehicle = validate();
    if (vehicle == null) {
      return;
    }

    try {
      final serverAPI =
          DependencyHolder.of(context)!.network.serverAPI.vehicles;
      showActivityDialog(context, localizationUtil.saving);

      final bool exist =
          await serverAPI.exists(vehicle.number, vehicle.carrier);
      if (exist) {
        Navigator.pop(context);
        showErrorDialog(context, localizationUtil.vehicleExists);
        return;
      }

      await serverAPI.create(vehicle);
      Navigator.pop(context);
      Navigator.pop(context, vehicle);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  Vehicle? validate() {
    if (!_formKey.currentState!.validate()!) {
      return null;
    }
    final vehicle = Vehicle();
    vehicle.model = _modelKey.currentState?.value;
    vehicle.number = _numberKey.currentState?.value;
    vehicle.tonnage = int.parse(_tonnageKey.currentState!.value!);
    vehicle.carrier = widget.carrier;
    return vehicle;
  }

  void _handleBrandChanged(VehicleBrand? value) {
    setState(() => _brand = value);
    _modelKey.currentState?.value = null;
  }
}
