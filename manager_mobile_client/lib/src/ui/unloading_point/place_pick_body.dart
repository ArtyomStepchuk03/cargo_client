import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/external/places_service.dart';
import 'package:manager_mobile_client/src/ui/common/button.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/coordinate_picker/coordinate_picker.dart';
import 'package:manager_mobile_client/src/ui/validators/common_validators.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'unloading_point_add_strings.dart' as strings;

class PlacePickInformation {
  String address;
  LatLng coordinate;
}

class PlacePickBody extends StatefulWidget {
  PlacePickBody({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlacePickBodyState();
}

class PlacePickBodyState extends State<PlacePickBody> {
  PlacePickInformation validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final information = PlacePickInformation();
    information.address = _addressKey.currentState.value;
    information.coordinate = _coordinate;
    return information;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_placesService == null) {
      _placesService = DependencyHolder.of(context).location.placesService;
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildForm(key: _formKey, children: [_buildGroup()]);
  }

  final _formKey = GlobalKey<ScrollableFormState>();
  final _addressKey = GlobalKey<AddressFormFieldState>();

  PlacesService _placesService;
  LatLng _coordinate;

  Widget _buildGroup() {
    return buildFormGroup([
      buildFormRow(Icons.location_on,
        _buildAddressFormField(),
      ),
      buildFormRow(null,
        buildButton(context, onPressed: _pickCoordinate, child: Text(strings.pickOnMap)),
      ),
    ]);
  }

  Widget _buildAddressFormField() {
    return AddressFormField(
      key: _addressKey,
      placesService: _placesService,
      allowCustomAddress: false,
      label: strings.address,
      onChanged: _handleAddressChanged,
      validator: RequiredValidator(),
    );
  }

  void _pickCoordinate() async {
    final coordinate = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => CoordinatePicker(initialCoordinate: _coordinate),
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

  void _encodeAddress(String address, PlacesSearchResult placesSearchResult) async {
    showDefaultActivityDialog(context);
    try {
      final detailsResult = await _placesService.getDetails(placesSearchResult);
      _coordinate = detailsResult.coordinate;
      Navigator.pop(context);
    } on Exception {
      Navigator.pop(context);
    }
  }

  void _decodeAddress(LatLng coordinate) async {
    showDefaultActivityDialog(context);
    try {
      final detailsResult = await _placesService.getAddress(coordinate);
      _addressKey.currentState.value = detailsResult.address;
      Navigator.pop(context);
    } on Exception {
      Navigator.pop(context);
    }
  }
}
