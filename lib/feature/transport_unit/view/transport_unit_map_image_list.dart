import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:manager_mobile_client/util/image.dart';

class MapClusterImageSet {
  final BitmapDescriptor? icon2Plus;
  final BitmapDescriptor? icon5Plus;
  final BitmapDescriptor? icon10Plus;
  final BitmapDescriptor? icon25Plus;
  final BitmapDescriptor? icon50Plus;
  final BitmapDescriptor? icon100Plus;

  MapClusterImageSet(
      {this.icon2Plus,
      this.icon5Plus,
      this.icon10Plus,
      this.icon25Plus,
      this.icon50Plus,
      this.icon100Plus});

  BitmapDescriptor? iconForCount(int count) {
    if (count >= 100) {
      return icon100Plus;
    } else if (count >= 50) {
      return icon50Plus;
    } else if (count >= 25) {
      return icon25Plus;
    } else if (count >= 10) {
      return icon10Plus;
    } else if (count >= 5) {
      return icon5Plus;
    } else if (count >= 2) {
      return icon2Plus;
    } else {
      return null;
    }
  }
}

class TransportUnitMapImageList {
  BitmapDescriptor? get transportUnitIcon => _transportUnitIcon;
  BitmapDescriptor? get transportUnitSelectedIcon => _transportUnitSelectedIcon;
  BitmapDescriptor? get loadingPointIcon => _loadingPointIcon;
  MapClusterImageSet? get transportUnitClusterIcons =>
      _transportUnitClusterIcons;
  MapClusterImageSet? get loadingPointClusterIcons => _loadingPointClusterIcons;

  Future<void> load(BuildContext context) async {
    final configuration = createLocalImageConfiguration(context);
    _transportUnitIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/marker_truck'));
    _transportUnitSelectedIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/marker_truck_checked'));
    _loadingPointIcon = await BitmapDescriptor.fromAssetImage(
        configuration, pathForImage('markers/marker_supplier'));
    _transportUnitClusterIcons =
        await _loadClusters(configuration, 'markers/cluster_truck');
    _loadingPointClusterIcons =
        await _loadClusters(configuration, 'markers/cluster_supplier');
  }

  BitmapDescriptor? _transportUnitIcon;
  BitmapDescriptor? _transportUnitSelectedIcon;
  BitmapDescriptor? _loadingPointIcon;
  MapClusterImageSet? _transportUnitClusterIcons;
  MapClusterImageSet? _loadingPointClusterIcons;

  Future<MapClusterImageSet> _loadClusters(
      ImageConfiguration configuration, String imageName) async {
    return MapClusterImageSet(
      icon2Plus: await BitmapDescriptor.fromAssetImage(
          configuration, pathForImage('${imageName}_2')),
      icon5Plus: await BitmapDescriptor.fromAssetImage(
          configuration, pathForImage('${imageName}_5')),
      icon10Plus: await BitmapDescriptor.fromAssetImage(
          configuration, pathForImage('${imageName}_10')),
      icon25Plus: await BitmapDescriptor.fromAssetImage(
          configuration, pathForImage('${imageName}_25')),
      icon50Plus: await BitmapDescriptor.fromAssetImage(
          configuration, pathForImage('${imageName}_50')),
      icon100Plus: await BitmapDescriptor.fromAssetImage(
          configuration, pathForImage('${imageName}_100')),
    );
  }
}
