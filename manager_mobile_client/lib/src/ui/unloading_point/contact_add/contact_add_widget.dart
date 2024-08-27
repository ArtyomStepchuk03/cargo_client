import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import '../../common/app_bar.dart';
import 'contact_add_strings.dart' as strings;
import 'contact_add_body.dart';

class ContactAddWidget extends StatefulWidget {
  final UnloadingPoint unloadingPoint;

  ContactAddWidget({this.unloadingPoint});

  @override
  State<StatefulWidget> createState() => ContactAddState();
}

class ContactAddState extends State<ContactAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: ContactAddBody(key: _bodyKey)
    );
  }

  final _bodyKey = GlobalKey<ContactAddBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final contact = _bodyKey.currentState.validate();
    if (contact == null) {
      return;
    }
    showActivityDialog(context, strings.saving);
    final serverAPI = DependencyHolder.of(context).network.serverAPI.unloadingPoints;
    try {
      await serverAPI.addContact(widget.unloadingPoint, contact);
      Navigator.pop(context);
      Navigator.pop(context, contact);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }
}
