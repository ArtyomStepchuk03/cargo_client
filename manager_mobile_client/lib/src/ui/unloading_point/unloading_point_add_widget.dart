import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/src/logic/server_api/unloading_point_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import '../common/app_bar.dart';
import 'place_pick_body.dart';
import 'unloading_point_add_strings.dart' as strings;

class UnloadingPointAddWidget extends StatefulWidget {
  final Customer customer;
  final Manager manager;

  UnloadingPointAddWidget({this.customer, this.manager});

  @override
  State<StatefulWidget> createState() => UnloadingPointAddState();
}

class UnloadingPointAddState extends State<UnloadingPointAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: PlacePickBody(key: _bodyKey)
    );
  }

  final _bodyKey = GlobalKey<PlacePickBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final placePickInformation = _bodyKey.currentState.validate();
    if (placePickInformation == null) {
      return;
    }
    showActivityDialog(context, strings.saving);
    final serverAPI = DependencyHolder.of(context).network.serverAPI;
    try {
      final unloadingPoint = await _addUnloadingPoint(serverAPI.customers, placePickInformation);
      await _addEntrance(serverAPI.unloadingPoints, unloadingPoint, placePickInformation);
      Navigator.pop(context);
      Navigator.pop(context, unloadingPoint);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  Future<UnloadingPoint> _addUnloadingPoint(CustomerServerAPI customerServerAPI, PlacePickInformation placePickInformation) async {
    final unloadingPoint = UnloadingPoint();
    unloadingPoint.address = placePickInformation.address;
    unloadingPoint.equipmentRequirements = VehicleEquipment();
    await customerServerAPI.addUnloadingPoint(widget.customer, unloadingPoint, widget.manager);
    return unloadingPoint;
  }

  Future<Entrance> _addEntrance(UnloadingPointServerAPI unloadingPointServerAPI, UnloadingPoint unloadingPoint, PlacePickInformation placePickInformation) async {
    final entrance = Entrance();
    entrance.name = strings.defaultEntranceName;
    entrance.address = placePickInformation.address;
    entrance.coordinate = placePickInformation.coordinate;
    await unloadingPointServerAPI.addEntrance(unloadingPoint, entrance);
    return entrance;
  }
}
