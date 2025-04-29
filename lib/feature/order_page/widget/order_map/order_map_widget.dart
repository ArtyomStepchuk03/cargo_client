import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/fullscreen_activity_overlay.dart';
import 'package:manager_mobile_client/common/multiline_detail_window.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/location_tree/trip_marker_tree.dart';
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_subscription.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/transport_unit_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/trip_server_api.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/stage.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/map_utility/camera_position.dart';

import 'order_map_image_list.dart';
import 'transport_unit_map_overlay.dart';

class OrderMapWidget extends StatefulWidget {
  final Order order;

  OrderMapWidget(this.order);

  @override
  State<StatefulWidget> createState() => OrderMapState();
}

class OrderMapState extends State<OrderMapWidget> {
  @override
  void dispose() {
    _followResumeTimer?.cancel();
    if (_subscription != null)
      _transportUnitServerAPI?.unsubscribe(_subscription!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(title: Text(localizationUtil.orderOnMap)),
      body: FullscreenActivityOverlay(
        loading: _loaded != true,
        child: Stack(children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            initialCameraPosition: _getInitialCameraPosition(),
            onCameraMoveStarted: () => _handleCameraMoveGestureStarted(),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: _handleMapCreated,
            onCameraMove: _handleCameraMove,
          ),
          if (_transportUnit != null) TransportUnitMapOverlay(_transportUnit),
        ]),
      ),
    );
  }

  final _imageList = OrderMapImageList();
  OrderServerAPI? _orderServerAPI;
  TripServerAPI? _tripServerAPI;
  TransportUnitServerAPI? _transportUnitServerAPI;
  GoogleMapController? _controller;

  var _loaded = false;
  TransportUnit? _transportUnit;
  var _keyMarkers = <Marker>{};
  var _tripMarkers = <Marker>{};
  Marker? _transportUnitMarker;
  LocationTree<MarkerTreeItem>? _tripMarkerTree;
  LatLng? _lastCoordinate;
  parse.LiveQuerySubscription<TransportUnit?>? _subscription;
  var _followTransportUnit = true;
  Timer? _followResumeTimer;

  var _markers = <Marker>{};
  var _polylines = <Polyline>{};

  Marker _buildEntranceMarker(
      String identifier, BitmapDescriptor icon, Entrance entrance) {
    final localizationUtil = LocalizationUtil.of(context);
    return Marker(
      markerId: MarkerId(identifier),
      position: entrance.coordinate!,
      icon: icon,
      onTap: () {
        showMultilineDetailWindow(context: context, lines: [
          textOrEmpty(entrance.name),
          '${localizationUtil.address}: ${textOrEmpty(entrance.address)}',
        ]);
      },
    );
  }

  Marker _buildLoadingEntranceMarker(Entrance entrance) {
    return _buildEntranceMarker(
        'LoadingEntrance', _imageList.loadingEntranceIcon!, entrance);
  }

  Marker _buildUnloadingEntranceMarker(Entrance entrance) {
    return _buildEntranceMarker(
        'UnloadingEntrance', _imageList.unloadingEntranceIcon!, entrance);
  }

  Marker? _buildTransportUnitMarker(TransportUnit? transportUnit) {
    if (transportUnit?.coordinate == null) {
      return null;
    }
    return Marker(
      markerId: MarkerId('TransportUnit'),
      position: transportUnit!.coordinate!,
      icon: _imageList.transportUnitIcon!,
    );
  }

  Marker _buildUnloadedMarker(
      TransportUnit? transportUnit,
      TripHistoryRecord? inUnloadingPointRecord,
      TripHistoryRecord? unloadedRecord) {
    int? timeInterval;
    if (inUnloadingPointRecord?.date != null && unloadedRecord?.date != null) {
      timeInterval = unloadedRecord!.date!
          .difference(inUnloadingPointRecord!.date!)
          .inMilliseconds;
    }
    return Marker(
      markerId: MarkerId('Unloaded'),
      position: inUnloadingPointRecord!.coordinate!,
      icon: _imageList.unloadedIcon!,
      onTap: () {
        final localizationUtil = LocalizationUtil.of(context);
        showMultilineDetailWindow(context: context, lines: [
          '${localizationUtil.dateTime}: ${formatDateSafe(inUnloadingPointRecord.date)}',
          '${localizationUtil.unloadingDuration}: ${formatTimeIntervalSafe(context, timeInterval)}',
          '${localizationUtil.stateNumber}: ${textOrEmpty(transportUnit?.vehicle?.number)}',
          '${localizationUtil.address}: ${textOrEmpty(inUnloadingPointRecord.address)}',
        ]);
      },
    );
  }

  Marker _buildWaypointMarker(Trip? trip, int? index, Waypoint? waypoint,
      int historyRecordIndex, BitmapDescriptor? icon) {
    final localizationUtil = LocalizationUtil.of(context);
    final lines = <String>[];
    lines
        .add('${localizationUtil.dateTime}: ${formatDateSafe(waypoint?.date)}');

    if (historyRecordIndex != -1) {
      lines.add(
          '${localizationUtil.orderStage}: ${formatTripStage(context, trip?.historyRecords?[historyRecordIndex]?.stage)}');
    }

    return Marker(
      markerId: MarkerId('Waypoint$index'),
      position: waypoint!.coordinate!,
      icon: icon!,
      anchor: const Offset(0.5, 0.5),
      onTap: () => showMultilineDetailWindow(context: context, lines: lines),
    );
  }

  Marker _buildDirectionMarker(
      int index, LatLng coordinate, double heading, BitmapDescriptor icon) {
    return Marker(
        markerId: MarkerId('Direction$index'),
        flat: true,
        position: coordinate,
        rotation: heading,
        icon: icon);
  }

  Polyline _buildPolyline(
      String identifier, Color color, List<LatLng> coordinates) {
    return Polyline(
      polylineId: PolylineId(identifier),
      color: color,
      jointType: JointType.round,
      width: 6,
      points: coordinates,
    );
  }

  void _buildKeyMarkers() {
    if (widget.order.loadingEntrance != null &&
        widget.order.loadingEntrance?.coordinate != null) {
      _keyMarkers
          .add(_buildLoadingEntranceMarker(widget.order.loadingEntrance!));
    }
    if (widget.order.unloadingEntrance != null &&
        widget.order.unloadingEntrance?.coordinate != null) {
      _keyMarkers
          .add(_buildUnloadingEntranceMarker(widget.order.unloadingEntrance!));
    }

    final offer = widget.order.getAcceptedOffer();
    if (offer != null) {
      if (offer.trip != null) {
        final inUnloadingPointRecord =
            offer.trip?.getHistoryRecord(TripStage.inUnloadingPoint);
        final unloadedRecord = offer.trip?.getHistoryRecord(TripStage.unloaded);
        if (inUnloadingPointRecord != null &&
            unloadedRecord != null &&
            inUnloadingPointRecord.coordinate != null) {
          _keyMarkers.add(_buildUnloadedMarker(
              offer.transportUnit, inUnloadingPointRecord, unloadedRecord));
        }
      }
    }
  }

  void _buildTripOverlays(Trip? trip, List<Waypoint?> waypoints) {
    final index = _getLoadedWaypointIndex(trip, waypoints);

    List<Waypoint?>? loadingWaypoints;
    List<Waypoint?>? unloadingWaypoints;

    if (index == -1) {
      loadingWaypoints = waypoints;
    } else {
      loadingWaypoints = waypoints.sublist(0, index + 1);
      unloadingWaypoints = waypoints.sublist(index, waypoints.length);
    }

    _polylines.add(_buildPolyline('LoadingTrip', Colors.blue,
        loadingWaypoints.map((waypoint) => waypoint!.coordinate!).toList()));
    _buildTripMarkers(trip, loadingWaypoints, _imageList.loadingWaypointIcon,
        _imageList.loadingDirectionIcon);

    if (unloadingWaypoints != null) {
      _polylines.add(_buildPolyline(
          'UnloadingTrip',
          Colors.red,
          unloadingWaypoints
              .map((waypoint) => waypoint!.coordinate!)
              .toList()));
      _buildTripMarkers(trip, unloadingWaypoints,
          _imageList.unloadingWaypointIcon, _imageList.unloadingDirectionIcon);
    }
  }

  void _buildTripMarkers(Trip? trip, List<Waypoint?> waypoints,
      BitmapDescriptor? waypointIcon, BitmapDescriptor? directionIcon) {
    if (waypoints.isEmpty) {
      return;
    }

    double waypointDistance = 0;
    double directionDistance = 0;
    int historyRecordIndex = _getHistoryRecordIndex(trip, waypoints[0]);

    _tripMarkers.add(_buildWaypointMarker(
        trip, 0, waypoints[0], historyRecordIndex, waypointIcon));

    for (int counter = 0; counter < waypoints.length - 1; ++counter) {
      final one = waypoints[counter];
      final other = waypoints[counter + 1];

      final segmentLength = getDistance(one!.coordinate!, other!.coordinate!);
      historyRecordIndex =
          _getHistoryRecordIndex(trip, other, historyRecordIndex);

      waypointDistance += segmentLength;
      directionDistance += segmentLength / 2;

      if (waypointDistance > 400) {
        waypointDistance = 0;
        _tripMarkers.add(_buildWaypointMarker(trip, counter + 1,
            waypoints[counter + 1]!, historyRecordIndex, waypointIcon));
      }

      if (segmentLength > 10 && directionDistance > 800) {
        directionDistance = 0;

        final coordinate = LatLng(
            one.coordinate!.latitude +
                (other.coordinate!.latitude - one.coordinate!.latitude) / 2,
            one.coordinate!.longitude +
                (other.coordinate!.longitude - one.coordinate!.longitude) / 2);

        final heading = getHeading(one.coordinate!, other.coordinate!);
        _tripMarkers.add(_buildDirectionMarker(
            counter, coordinate, heading, directionIcon!));
      }

      directionDistance += segmentLength / 2;
    }
  }

  void _handleMapCreated(GoogleMapController controller) async {
    _controller = controller;
    if (_orderServerAPI == null) {
      final serverAPI = DependencyHolder.of(context).network.serverAPI;
      _orderServerAPI = serverAPI.orders;
      _tripServerAPI = serverAPI.trips;
      _transportUnitServerAPI = serverAPI.transportUnits;
      await _imageList.load(context);
      if (mounted != true) {
        return;
      }
      _loadTripData();
    }
  }

  void _handleFollowResumeTimer() {
    _followResumeTimer = null;
    _followTransportUnit = true;
  }

  void _handleCameraMoveGestureStarted() {
    _followTransportUnit = false;
    _followResumeTimer?.cancel();
    _followResumeTimer = Timer(Duration(seconds: 20), _handleFollowResumeTimer);
  }

  void _handleCameraMove(CameraPosition position) async {
    if (_shouldShowTripMarkers(position.zoom) != true) {
      if (_lastCoordinate == null) {
        return;
      }
      _lastCoordinate = null;
      setState(() => _markers = Set.from(_keyMarkers));
      return;
    }
    if (_tripMarkerTree == null) {
      return;
    }
    if (_lastCoordinate != null &&
        !shouldUpdateMarkers(_lastCoordinate!, position.target)) {
      return;
    }
    _lastCoordinate = position.target;
    final tripMarkers = getMarkers(_tripMarkerTree!, _lastCoordinate!);
    print('Updated with ${tripMarkers.length} markers.');
    setState(() {
      _markers.clear();
      _markers.addAll(_keyMarkers);
      _markers.addAll(tripMarkers);
    });
  }

  bool _shouldShowTripMarkers(double zoom) => zoom >= 14;

  void _loadTripData() async {
    await _orderServerAPI?.fetchProgress(widget.order);
    final offer = widget.order.getAcceptedOffer();
    _transportUnit = offer?.transportUnit;
    final orderFinished =
        offer?.trip != null && offer!.trip!.stage == TripStage.unloaded;

    List<Waypoint?>? waypoints;
    if (orderFinished) {
      waypoints = await _tripServerAPI!.listWaypoints(offer.trip!);
    }

    if (mounted != true) {
      return;
    }

    _buildKeyMarkers();
    _markers.addAll(_keyMarkers);
    if (_transportUnit != null && !orderFinished) {
      _transportUnitMarker = _buildTransportUnitMarker(_transportUnit!);
      if (_transportUnitMarker != null) _markers.add(_transportUnitMarker!);
    }

    if (waypoints != null && waypoints.isNotEmpty) {
      _buildTripOverlays(offer?.trip, waypoints);
      _tripMarkerTree = await buildTripMarkerTree(_tripMarkers);
      if (mounted != true) {
        return;
      }
    }
    _loaded = true;

    setState(() {});

    if (waypoints != null && waypoints.isNotEmpty) {
      final bounds = LatLngBoundsUtility.circumscribed(
          waypoints.map((waypoint) => waypoint!.coordinate!));
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20));
    } else if (_transportUnit?.coordinate != null) {
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(
          _transportUnit!.coordinate!, _followingZoom));
    }

    if (_transportUnit != null && !orderFinished) {
      subscribe(_transportUnit!);
    }
  }

  void subscribe(TransportUnit transportUnit) {
    _subscription = _transportUnitServerAPI?.subscribeToChanges(transportUnit);
    _subscription?.onUpdate = (updatedTransportUnit) async {
      await _transportUnitServerAPI?.fetch(_transportUnit);
      if (_transportUnitMarker != null) _markers.remove(_transportUnitMarker);
      _transportUnitMarker = _buildTransportUnitMarker(_transportUnit);
      if (_transportUnitMarker != null) _markers.add(_transportUnitMarker!);
      setState(() {});
      if (_transportUnitMarker != null && _followTransportUnit) {
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(
            updatedTransportUnit!.coordinate!, _followingZoom));
      }
    };
  }

  int _getLoadedWaypointIndex(Trip? trip, List<Waypoint?> waypoints) {
    final loadedRecord = trip?.getHistoryRecord(TripStage.loaded);
    if (loadedRecord == null) {
      return -1;
    }
    return waypoints.indexWhere(
        (waypoint) => waypoint?.date?.isBefore(loadedRecord.date!) == false);
  }

  int _getHistoryRecordIndex(Trip? trip, Waypoint? waypoint,
      [int startIndex = -1]) {
    if (trip?.historyRecords == null) {
      return -1;
    }
    while (startIndex + 1 < trip!.historyRecords!.length &&
        waypoint!.date!.isAfter(trip.historyRecords![startIndex + 1]!.date!)) {
      ++startIndex;
    }
    return startIndex;
  }

  CameraPosition _getInitialCameraPosition() {
    if (widget.order.unloadingEntrance != null &&
        widget.order.unloadingEntrance!.coordinate != null) {
      return CameraPosition(
          target: widget.order.unloadingEntrance!.coordinate!,
          zoom: defaultCameraPosition.zoom);
    }
    return defaultCameraPosition;
  }

  final _followingZoom = 13.0;
}
