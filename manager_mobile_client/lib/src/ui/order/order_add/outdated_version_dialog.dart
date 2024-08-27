
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:manager_mobile_client/src/logic/core/version_compare.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'order_add_strings.dart' as strings;

Future<bool> checkVersionForOrderAddition(BuildContext context, {bool reservation = false}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final configurationLoader = DependencyHolder.of(context).network.configurationLoader;
  final version = packageInfo.version;
  final minimumVersion = configurationLoader.configuration.minimumVersion;
  if (Version.compare(version, minimumVersion) >= 0) {
    return true;
  }
  await _showOutdatedVersionDialog(context, reservation: reservation);
  return false;
}

Future<void> _showOutdatedVersionDialog(BuildContext context, {bool reservation = false}) async {
  await showErrorDialog(context, reservation ? strings.outdatedVersionReservationErrorText : strings.outdatedVersionOrderErrorText);
}
