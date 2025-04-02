import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manager_mobile_client/util/image.dart';

class OrderMapImageList {
  BitmapDescriptor? get loadingEntranceIcon => _loadingEntranceIcon;
  BitmapDescriptor? get unloadingEntranceIcon => _unloadingEntranceIcon;
  BitmapDescriptor? get transportUnitIcon => _transportUnitIcon;
  BitmapDescriptor? get unloadedIcon => _unloadedIcon;

  BitmapDescriptor? get loadingWaypointIcon => _loadingWaypointIcon;
  BitmapDescriptor? get unloadingWaypointIcon => _unloadingWaypointIcon;
  BitmapDescriptor? get loadingDirectionIcon => _loadingDirectionIcon;
  BitmapDescriptor? get unloadingDirectionIcon => _unloadingDirectionIcon;

  Future<void> load(BuildContext context) async {
    final configuration = createLocalImageConfiguration(context);
    _loadingEntranceIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/marker_start'));
    _unloadingEntranceIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/marker_finish'));
    _transportUnitIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/marker_truck'));
    _unloadedIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/marker_unloaded'));

    _loadingWaypointIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/waypoint_loading'));
    _unloadingWaypointIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/waypoint_unloading'));
    _loadingDirectionIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/direction_loading'));
    _unloadingDirectionIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/direction_unloading'));
  }

  BitmapDescriptor? _loadingEntranceIcon;
  BitmapDescriptor? _unloadingEntranceIcon;
  BitmapDescriptor? _transportUnitIcon;
  BitmapDescriptor? _unloadedIcon;

  BitmapDescriptor? _loadingWaypointIcon;
  BitmapDescriptor? _unloadingWaypointIcon;
  BitmapDescriptor? _loadingDirectionIcon;
  BitmapDescriptor? _unloadingDirectionIcon;
}
