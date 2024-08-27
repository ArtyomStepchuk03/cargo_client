import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/trailer.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'trailer_add_strings.dart' as strings;
import 'trailer_add_body.dart';

class TrailerAddWidget extends StatefulWidget {
  final Carrier carrier;

  TrailerAddWidget({this.carrier});

  @override
  State<StatefulWidget> createState() => TrailerAddState();
}

class TrailerAddState extends State<TrailerAddWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: TrailerAddBody(key: _bodyKey, carrier: widget.carrier),
    );
  }

  final _bodyKey = GlobalKey<TrailerAddBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.done), onPressed: () => _save(context)),
    ];
  }

  void _save(BuildContext context) async {
    final trailer = _bodyKey.currentState.validate();
    if (trailer == null) {
      return;
    }

    try {
      final serverAPI = DependencyHolder.of(context).network.serverAPI.trailers;
      showActivityDialog(context, strings.saving);

      final bool exist = await serverAPI.exists(trailer.number, trailer.carrier);
      if (exist) {
        Navigator.pop(context);
        showErrorDialog(context, strings.trailerExists);
        return;
      }

      await serverAPI.create(trailer);
      Navigator.pop(context);
      Navigator.pop(context, trailer);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }
}
