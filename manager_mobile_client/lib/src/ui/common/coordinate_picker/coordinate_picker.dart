import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/map_utility/camera_position.dart';
import 'coordinate_picker_strings.dart' as strings;

class CoordinatePicker extends StatefulWidget {
  final LatLng initialCoordinate;

  CoordinatePicker({this.initialCoordinate});

  @override
  State createState() => CoordinatePickerState();
}

class CoordinatePickerState extends State<CoordinatePicker> {
  @override
  void initState() {
    super.initState();
    _marker = _buildMarker(_getInitialCoordinate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: _buildMap(),
    );
  }

  Marker _marker;

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.done),
        onPressed: _confirm,
      )
    ];
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: _getInitialCameraPosition(),
      markers: {_marker},
      onCameraMove: _handleCameraMove,
    );
  }

  Marker _buildMarker(LatLng position) {
    return  Marker(
      markerId: MarkerId('CoordinateMarker'),
      position: position,
    );
  }

  void _handleCameraMove(CameraPosition position) {
    setState(() {
      _marker = _buildMarker(position.target);
    });
  }

  void _confirm() {
    final coordinate = _marker.position;
    Navigator.pop(context, coordinate);
  }

  LatLng _getInitialCoordinate() {
    if (widget.initialCoordinate != null) {
      return widget.initialCoordinate;
    }
    return defaultCameraPosition.target;
  }

  CameraPosition _getInitialCameraPosition() {
    if (widget.initialCoordinate != null) {
      return CameraPosition(target: widget.initialCoordinate, zoom: 17);
    }
    return defaultCameraPosition;
  }
}
