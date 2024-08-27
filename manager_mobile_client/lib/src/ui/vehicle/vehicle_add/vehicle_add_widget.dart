import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'vehicle_add_strings.dart' as strings;
import 'vehicle_add_body.dart';

class VehicleAddWidget extends StatefulWidget {
  final Carrier carrier;

  VehicleAddWidget({this.carrier});

  @override
  State<StatefulWidget> createState() => VehicleAddState();
}

class VehicleAddState extends State<VehicleAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: VehicleAddBody(key: _bodyKey, carrier: widget.carrier),
    );
  }

  final _bodyKey = GlobalKey<VehicleAddBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final vehicle = _bodyKey.currentState.validate();
    if (vehicle == null) {
      return;
    }

    try {
      final serverAPI = DependencyHolder.of(context).network.serverAPI.vehicles;
      showActivityDialog(context, strings.saving);

      final bool exist = await serverAPI.exists(vehicle.number, vehicle.carrier);
      if (exist) {
        Navigator.pop(context);
        showErrorDialog(context, strings.vehicleExists);
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
}
