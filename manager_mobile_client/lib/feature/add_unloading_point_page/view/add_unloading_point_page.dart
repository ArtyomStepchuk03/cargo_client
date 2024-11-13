import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/common/coordinate_picker/coordinate_picker.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/src/logic/external/places_service.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/unloading_point_server_api.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class PlacePickInformation {
  String address;
  LatLng coordinate;
}

class AddUnloadingPointPage extends StatefulWidget {
  final Customer customer;
  final Manager manager;

  AddUnloadingPointPage({this.customer, this.manager});

  @override
  State<StatefulWidget> createState() => _AddUnloadingPointPageState();
}

class _AddUnloadingPointPageState extends State<AddUnloadingPointPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_placesService == null) {
      _placesService = DependencyHolder.of(context).location.placesService;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newAddress),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () => _save(context),
          )
        ],
      ),
      body: buildForm(key: _formKey, children: [_buildGroup()]),
    );
  }

  void _save(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final placePickInformation = validate();
    if (placePickInformation == null) {
      return;
    }
    showActivityDialog(context, localizationUtil.saving);
    final serverAPI = DependencyHolder.of(context).network.serverAPI;
    try {
      final unloadingPoint =
          await _addUnloadingPoint(serverAPI.customers, placePickInformation);
      await _addEntrance(
          serverAPI.unloadingPoints, unloadingPoint, placePickInformation);
      Navigator.pop(context);
      Navigator.pop(context, unloadingPoint);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  Future<UnloadingPoint> _addUnloadingPoint(CustomerServerAPI customerServerAPI,
      PlacePickInformation placePickInformation) async {
    final unloadingPoint = UnloadingPoint();
    unloadingPoint.address = placePickInformation.address;
    unloadingPoint.equipmentRequirements = VehicleEquipment();
    await customerServerAPI.addUnloadingPoint(
        widget.customer, unloadingPoint, widget.manager);
    return unloadingPoint;
  }

  Future<Entrance> _addEntrance(
      UnloadingPointServerAPI unloadingPointServerAPI,
      UnloadingPoint unloadingPoint,
      PlacePickInformation placePickInformation) async {
    final localizationUtil = LocalizationUtil.of(context);
    final entrance = Entrance();
    entrance.name = localizationUtil.defaultEntranceName;
    entrance.address = placePickInformation.address;
    entrance.coordinate = placePickInformation.coordinate;
    await unloadingPointServerAPI.addEntrance(unloadingPoint, entrance);
    return entrance;
  }

  final _formKey = GlobalKey<ScrollableFormState>();
  final _addressKey = GlobalKey<AddressFormFieldState>();

  PlacesService _placesService;
  LatLng _coordinate;

  Widget _buildGroup() {
    final localizationUtil = LocalizationUtil.of(context);
    return buildFormGroup([
      buildFormRow(
        Icons.location_on,
        _buildAddressFormField(),
      ),
      buildFormRow(
        null,
        buildButton(context,
            onPressed: _pickCoordinate,
            child: Text(localizationUtil.pickOnMap)),
      ),
    ]);
  }

  Widget _buildAddressFormField() {
    final localizationUtil = LocalizationUtil.of(context);
    return AddressFormField(
      key: _addressKey,
      placesService: _placesService,
      allowCustomAddress: false,
      label: localizationUtil.address,
      onChanged: _handleAddressChanged,
      validator: RequiredValidator(context),
    );
  }

  void _pickCoordinate() async {
    final coordinate = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CoordinatePicker(initialCoordinate: _coordinate),
          fullscreenDialog: true,
        ));
    if (coordinate != null) {
      _coordinate = coordinate;
      _addressKey.currentState.value = '';
      _decodeAddress(coordinate);
    }
  }

  void _handleAddressChanged(String address) {
    _coordinate = null;
    if (address.isEmpty) {
      return;
    }
    _encodeAddress(address, _addressKey.currentState.placesSearchResult);
  }

  void _encodeAddress(
      String address, PlacesSearchResult placesSearchResult) async {
    showDefaultActivityDialog(context);
    try {
      final detailsResult = await _placesService.getDetails(placesSearchResult);
      _coordinate = detailsResult.coordinate;
    } on Exception {
    } finally {
      Navigator.pop(context);
    }
  }

  void _decodeAddress(LatLng coordinate) async {
    showDefaultActivityDialog(context);
    try {
      final detailsResult = await _placesService.getAddress(coordinate);
      _addressKey.currentState.value = detailsResult.address;
    } on Exception {
    } finally {
      Navigator.pop(context);
    }
  }

  PlacePickInformation validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final information = PlacePickInformation();
    information.address = _addressKey.currentState.value;
    information.coordinate = _coordinate;
    return information;
  }
}
