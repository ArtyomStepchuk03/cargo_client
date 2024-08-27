import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'transport_unit_add_strings.dart' as strings;
import 'transport_unit_add_body.dart';

class TransportUnitAddWidget extends StatefulWidget {
  final User user;

  TransportUnitAddWidget({this.user});

  @override
  State<StatefulWidget> createState() => TransportUnitAddState();
}

class TransportUnitAddState extends State<TransportUnitAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: TransportUnitAddBody(key: _bodyKey, user: widget.user),
    );
  }

  final _bodyKey = GlobalKey<TransportUnitAddBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final information = _bodyKey.currentState.validate();
    if (information != null) {
      showActivityDialog(context, strings.saving);
      final serverAPI = DependencyHolder.of(context).network.serverAPI.transportUnits;

      try {
        final transportUnit = await serverAPI.create(information.driver, information.vehicle, information.trailer);
        Navigator.pop(context);
        Navigator.pop(context, transportUnit);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }
}
