import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/driver.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'driver_add_strings.dart' as strings;
import 'driver_add_body.dart';

class DriverAddWidget extends StatefulWidget {
  final Carrier carrier;

  DriverAddWidget({this.carrier});

  @override
  State<StatefulWidget> createState() => DriverAddState();
}

class DriverAddState extends State<DriverAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: DriverAddBody(key: _bodyKey, carrier: widget.carrier),
    );
  }

  final _bodyKey = GlobalKey<DriverAddBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final createInformation = _bodyKey.currentState.validate();
    if (createInformation != null) {
      showActivityDialog(context, strings.saving);

      final serverAPI = DependencyHolder.of(context).network.serverAPI;

      try {
        final driver = Driver();
        driver.name = createInformation.name;
        driver.carrier = createInformation.carrier;

        if (createInformation.files != null) {
          driver.attachedDocuments = [];
          for (final file in createInformation.files) {
            final remoteFile = await serverAPI.files.createImage(file);
            driver.attachedDocuments.add(remoteFile);
          }
        }

        await serverAPI.drivers.create(driver);

        Navigator.pop(context);
        Navigator.pop(context, driver);
      } on Exception {
        Navigator.pop(context);
        showDefaultErrorDialog(context);
      }
    }
  }
}
