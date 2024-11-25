import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/feature/add_entrance_page/view/add_entrance_body.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class EntranceAddPage extends StatefulWidget {
  final UnloadingPoint unloadingPoint;

  EntranceAddPage(this.unloadingPoint);

  @override
  State<StatefulWidget> createState() => _EntranceAddPageState();
}

class _EntranceAddPageState extends State<EntranceAddPage> {
  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newUnloadingPoint),
        actions: _buildActions(context),
      ),
      body: EntranceAddBody(
          key: _bodyKey, initialAddress: widget.unloadingPoint.address),
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
    final localizationUtil = LocalizationUtil.of(context);
    if (editedEntrance != null) {
      showActivityDialog(context, localizationUtil.saving);
      final serverAPI =
          DependencyHolder.of(context).network.serverAPI.unloadingPoints;
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
