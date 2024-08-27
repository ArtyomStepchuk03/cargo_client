import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'entrance_add_body.dart';
import 'entrance_add_strings.dart' as strings;

class EntranceAddWidget extends StatefulWidget {
  final UnloadingPoint unloadingPoint;

  EntranceAddWidget(this.unloadingPoint);

  @override
  State<StatefulWidget> createState() => EntranceAddState();
}

class EntranceAddState extends State<EntranceAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: EntranceAddBody(key: _bodyKey, initialAddress: widget.unloadingPoint.address)
    );
  }

  final _bodyKey = GlobalKey<EntranceAddBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final editedEntrance = _bodyKey.currentState.validate();
    if (editedEntrance != null) {
      showActivityDialog(context, strings.saving);
      final serverAPI = DependencyHolder.of(context).network.serverAPI.unloadingPoints;
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
}
