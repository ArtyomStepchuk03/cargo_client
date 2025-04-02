import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/core/version_compare.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<bool> checkVersionForOrderAddition(BuildContext context,
    {bool reservation = false}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final configurationLoader =
      DependencyHolder.of(context)?.network.configurationLoader;
  final version = packageInfo.version;
  final minimumVersion = configurationLoader?.configuration?.minimumVersion;
  if (Version.compare(version, minimumVersion) >= 0) {
    return true;
  }
  await _showOutdatedVersionDialog(context, reservation: reservation);
  return false;
}

Future<void> _showOutdatedVersionDialog(BuildContext context,
    {bool reservation = false}) async {
  final localizationUtil = LocalizationUtil.of(context);
  await showErrorDialog(
      context,
      reservation
          ? localizationUtil.outdatedVersionReservationErrorText
          : localizationUtil.outdatedVersionOrderErrorText);
}
