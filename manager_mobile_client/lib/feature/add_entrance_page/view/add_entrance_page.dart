import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/common/coordinate_picker/coordinate_picker.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/src/logic/core/number_parse.dart';
import 'package:manager_mobile_client/src/logic/external/places_service.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class EntranceAddPage extends StatefulWidget {
  final UnloadingPoint unloadingPoint;

  EntranceAddPage(this.unloadingPoint);

  @override
  State<StatefulWidget> createState() => _EntranceAddPageState();
}

class _EntranceAddPageState extends State<EntranceAddPage> {
  final _formKey = GlobalKey<ScrollableFormState>();
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _addressKey = GlobalKey<AddressFormFieldState>();
  final _latitudeKey = GlobalKey<CustomTextFormFieldState>();
  final _longitudeKey = GlobalKey<CustomTextFormFieldState>();

  PlacesService _placesService;
  bool _loadingAddress;
  bool _loadingCoordinate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final initialAddress = widget.unloadingPoint.address;
    if (_placesService == null) {
      _placesService = DependencyHolder.of(context).location.placesService;
      if (initialAddress != null) {
        _encodeAddress(initialAddress, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newUnloadingPoint),
        actions: _buildActions(context),
      ),
      body: buildFormGroup([
        buildFormRow(
          Icons.edit,
          _buildNameFormField(),
        ),
        buildFormRow(
          Icons.location_on,
          _buildAddressFormField(),
        ),
        buildFormRow(
          Icons.my_location,
          _buildCoordinateFormField(
              _latitudeKey,
              localizationUtil.latitude,
              NumberValidator.required(context,
                  decimal: true, minimum: -90, maximum: 90)),
          _buildCoordinateFormField(
              _longitudeKey,
              localizationUtil.longitude,
              NumberValidator.required(context,
                  decimal: true, minimum: -180, maximum: 180)),
        ),
        buildFormRow(
          null,
          buildButton(context,
              onPressed: _pickCoordinate,
              child: Text(localizationUtil.pickOnMap)),
        ),
      ]),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.done),
        onPressed: () => _save(context),
      ),
    ];
  }

  void _save(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final editedEntrance = validate();
    if (editedEntrance != null) {
      showActivityDialog(context, localizationUtil.saving);
      final serverAPI =
          DependencyHolder.of(context).network.serverAPI.unloadingPoints;
      try {
        await serverAPI.addEntrance(widget.unloadingPoint, editedEntrance);
        Navigator.pop(context);
        Navigator.pop(context, editedEntrance);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }

  Widget _buildNameFormField() {
    final localizationUtil = LocalizationUtil.of(context);
    return CustomTextFormField(
      key: _nameKey,
      initialValue: localizationUtil.defaultEntranceName,
      label: localizationUtil.name,
      validator: RequiredValidator(context),
    );
  }

  Widget _buildAddressFormField() {
    final localizationUtil = LocalizationUtil.of(context);
    final initialAddress = widget.unloadingPoint.address;
    return AddressFormField(
      key: _addressKey,
      initialValue: initialAddress,
      placesService: _placesService,
      label: localizationUtil.address,
      loading: _loadingAddress,
      onChanged: _handleAddressChanged,
      validator: RequiredValidator(context),
    );
  }

  Widget _buildCoordinateFormField(
      Key key, String label, FormFieldValidator validator) {
    return buildCustomNumberFormField(
      context,
      key: key,
      label: label,
      loading: _loadingCoordinate,
      validator: validator,
    );
  }

  void _pickCoordinate() async {
    final coordinate = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CoordinatePicker(initialCoordinate: _getCoordinate()),
          fullscreenDialog: true,
        ));
    if (coordinate != null) {
      _setCoordinate(coordinate);
      _addressKey.currentState.value = '';
      _decodeAddress(coordinate);
    }
  }

  void _handleAddressChanged(String address) {
    _setCoordinate(null);
    if (address.isEmpty) {
      return;
    }
    _encodeAddress(address, _addressKey.currentState.placesSearchResult);
  }

  void _encodeAddress(
      String address, PlacesSearchResult placesSearchResult) async {
    setState(() => _loadingCoordinate = true);
    try {
      PlacesDetailsResult detailsResult;
      if (placesSearchResult != null) {
        detailsResult = await _placesService.getDetails(placesSearchResult);
      } else {
        detailsResult = await _placesService.getCoordinate(address);
      }
      if (mounted) {
        _setCoordinate(detailsResult.coordinate);
        setState(() => _loadingCoordinate = false);
      }
    } on Exception {
      if (mounted) {
        setState(() => _loadingCoordinate = false);
      }
    }
  }

  void _decodeAddress(LatLng coordinate) async {
    setState(() => _loadingAddress = true);
    try {
      final detailsResult = await _placesService.getAddress(coordinate);
      if (mounted) {
        _addressKey.currentState.value = detailsResult.address;
        setState(() => _loadingAddress = false);
      }
    } on Exception {
      if (mounted) {
        setState(() => _loadingAddress = false);
      }
    }
  }

  void _setCoordinate(LatLng coordinate) {
    _latitudeKey.currentState.value =
        coordinate != null ? coordinate.latitude.toStringAsFixed(6) : '';
    _longitudeKey.currentState.value =
        coordinate != null ? coordinate.longitude.toStringAsFixed(6) : '';
  }

  LatLng _getCoordinate() {
    final latitude = _latitudeKey.currentState.value;
    final longitude = _longitudeKey.currentState.value;
    if (latitude.isEmpty || longitude.isEmpty) {
      return null;
    }
    return LatLng(parseDecimal(latitude), parseDecimal(longitude));
  }

  Entrance validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final entrance = Entrance();
    entrance.name = _nameKey.currentState.value;
    entrance.address = _addressKey.currentState.value;
    entrance.coordinate = _getCoordinate();
    return entrance;
  }
}
