import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:manager_mobile_client/src/logic/core/location_bounds.dart';
import 'package:manager_mobile_client/src/logic/server_api/transport_unit_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/supplier_server_api.dart';
import 'package:manager_mobile_client/src/ui/utility/types.dart';
import 'package:manager_mobile_client/src/ui/map_utility/map_cluster/geohash_map_cluster.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/format/transport_unit_status.dart';
import 'package:manager_mobile_client/src/ui/map_utility/camera_position.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'transport_unit_map_image_list.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';

class TransportUnitMapBody extends StatefulWidget {
  final TransportUnitStatus status;
  final Carrier carrier;
  final VoidCallback onCreated;
  final bool selecting;
  final TransportUnit initialValue;
  final ItemSelectCallback<TransportUnit> onSelect;

  TransportUnitMapBody({Key key, this.status, this.carrier, this.onCreated, this.selecting = false, this.initialValue, this.onSelect}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransportUnitMapBodyState();
}

class TransportUnitMapBodyState extends State<TransportUnitMapBody> {
  void select(TransportUnit transportUnit, {bool centerInView = false}) {
    _selectedValue = transportUnit;
    if (centerInView) {
      const zoom = 16.0;
      _mapController.moveCamera(CameraUpdate.newLatLngZoom(_selectedValue.coordinate, zoom));
      _lastZoom = zoom;
    }
    _updateMarkers();
  }

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _lastZoom = defaultCameraPosition.zoom;
  }

  @override
  void didUpdateWidget(TransportUnitMapBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      _reloadDataAndUpdateMarkers();
    } else {
      _updateMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: defaultCameraPosition,
      markers: _markers,
      onMapCreated: _onMapCreated,
      onCameraIdle: _onCameraIdle,
      onCameraMove: _onCameraMove,
    );
  }

  final _imageList = TransportUnitMapImageList();
  TransportUnitServerAPI _transportUnitServerAPI;
  SupplierServerAPI _supplierServerAPI;
  GoogleMapController _mapController;
  TransportUnit _selectedValue;
  var _markers = <Marker>{};
  List<GeohashMapClusterItem<TransportUnit>> _transportUnitItems;
  List<GeohashMapClusterItem<Tuple2<Supplier, LoadingPoint>>> _loadingPointItems;
  double _lastZoom;
  double _lastUpdateZoom;

  Marker _buildTransportUnitClusterMarker(MapCluster<TransportUnit> cluster) {
    if (cluster.values.length == 1) {
      return _buildSingleTransportUnitMarker(cluster.values[0]);
    }
    return Marker(
      markerId: MarkerId('cluster_${cluster.values[0].id}'),
      position: cluster.coordinate,
      icon: _imageList.transportUnitClusterIcons.iconForCount(cluster.values.length),
      onTap: () => _onClusterMarkerTap(cluster.values.map((transportUnit) => transportUnit.coordinate)),
    );
  }

  Marker _buildSingleTransportUnitMarker(TransportUnit transportUnit) {
    return Marker(
      markerId: MarkerId(transportUnit.id),
      position: transportUnit.coordinate,
      icon: _selectedValue != null && transportUnit == _selectedValue ? _imageList.transportUnitSelectedIcon : _imageList.transportUnitIcon,
      infoWindow: InfoWindow(
        title: short.formatDriverSafe(transportUnit.driver),
        snippet: _buildTransportUnitSnippet(transportUnit),
      ),
      onTap: () => _onMarkerTap(transportUnit),
    );
  }

  String _buildTransportUnitSnippet(TransportUnit transportUnit) {
    final number = transportUnit.vehicle?.number;
    final status = formatTransportUnitStatus(transportUnit.status);
    if (number == null || status == null) {
      return null;
    }
    return '$number ($status)';
  }

  Marker _buildLoadingPointClusterMarker(MapCluster<Tuple2<Supplier, LoadingPoint>> cluster) {
    if (cluster.values.length == 1) {
      return _buildSingleLoadingPointMarker(cluster.values[0].item1, cluster.values[0].item2);
    }
    return Marker(
      markerId: MarkerId('cluster_${cluster.values[0].item2.id}'),
      position: cluster.coordinate,
      icon: _imageList.loadingPointClusterIcons.iconForCount(cluster.values.length),
      onTap: () => _onClusterMarkerTap(cluster.values.map((value) => value.item2.entrances[0].coordinate)),
    );
  }

  Marker _buildSingleLoadingPointMarker(Supplier supplier, LoadingPoint loadingPoint) {
    return Marker(
      markerId: MarkerId(loadingPoint.id),
      position: loadingPoint.entrances[0].coordinate,
      icon: _imageList.loadingPointIcon,
      infoWindow: InfoWindow(
        title: short.formatSupplierSafe(supplier),
        snippet: short.formatLoadingPointSafe(loadingPoint),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (_transportUnitServerAPI == null) {
      final serverAPI = DependencyHolder.of(context).network.serverAPI;
      _transportUnitServerAPI = serverAPI.transportUnits;
      _supplierServerAPI = serverAPI.suppliers;
      await _imageList.load(context);
      await _reloadDataAndUpdateMarkers();
    } else {
      _updateMarkers();
    }
    if (widget.onCreated != null) {
      widget.onCreated();
    }
  }

  void _onCameraIdle() {
    _updateMarkersIfNeeded();
  }

  void _onCameraMove(CameraPosition position) {
    _lastZoom = position.zoom;
  }

  void _onClusterMarkerTap(Iterable<LatLng> coordinates) {
    final bounds = LatLngBoundsUtility.circumscribed(coordinates);
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 40));
  }

  void _onMarkerTap(TransportUnit transportUnit) {
    if (_selectedValue == null || transportUnit.id != _selectedValue.id) {
      _selectedValue = transportUnit;
      _updateMarkers();
      if (widget.onSelect != null) {
        widget.onSelect(transportUnit);
      }
    }
  }

  void _updateMarkersIfNeeded() {
    if (_lastUpdateZoom != null && !shouldRebuildClusters(_lastUpdateZoom, _lastZoom)) {
      return;
    }
    _updateMarkers();
  }

  void _updateMarkers() {
    if (_transportUnitItems == null) {
      return;
    }
    final transportUnitClusters = _transportUnitItems.buildClusters(_lastZoom);
    final loadingPointClusters = _loadingPointItems.buildClusters(_lastZoom);
    _markers = <Marker>{};
    _markers.addAll(transportUnitClusters.map(_buildTransportUnitClusterMarker));
    _markers.addAll(loadingPointClusters.map(_buildLoadingPointClusterMarker));
    _lastUpdateZoom = _lastZoom;
    setState(() {});
  }

  Future<void> _reloadDataAndUpdateMarkers() async {
    await _loadData();
    if (!mounted) {
      return;
    }
    _updateMarkers();
  }

  Future<void> _loadData() async {
    final transportUnits = await _transportUnitServerAPI.listForMap(widget.status, widget.carrier);
    final suppliers = await _supplierServerAPI.listForMap();
    _transportUnitItems = transportUnits.map((transportUnit) => GeohashMapClusterItem.encode(transportUnit.coordinate, transportUnit)).toList();
    _loadingPointItems = _expandSuppliers(suppliers);
  }

  List<GeohashMapClusterItem> _expandSuppliers(List<Supplier> suppliers) {
    var items = <GeohashMapClusterItem<Tuple2<Supplier, LoadingPoint>>>[];
    for (final supplier in suppliers) {
      if (supplier.loadingPoints == null || supplier.loadingPoints.isEmpty) {
        continue;
      }
      for (final loadingPoint in supplier.loadingPoints) {
        if (loadingPoint.entrances == null || loadingPoint.entrances.isEmpty) {
          continue;
        }
        final entrance = loadingPoint.entrances[0];
        if (entrance.coordinate == null) {
          continue;
        }
        items.add(GeohashMapClusterItem.encode(entrance.coordinate, Tuple2(supplier, loadingPoint)));
      }
    }
    return items;
  }
}
