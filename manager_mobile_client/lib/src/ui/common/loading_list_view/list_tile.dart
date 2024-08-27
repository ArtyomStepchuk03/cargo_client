import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/common_strings.dart' as strings;

class SimpleListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  SimpleListTile(this.title, [this.subtitle, this.icon]);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title != null ? Text(title) : Text(strings.notSpecified, style: TextStyle(color: Colors.grey)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: icon != null ? Icon(icon) : null,
    );
  }
}

class ActivityListFooterTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(16),
      child: CircularProgressIndicator(),
    );
  }
}

class PlaceholderListFooterTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(
        strings.noRecords,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ErrorListFooterTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(
        strings.errorOccurred,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
