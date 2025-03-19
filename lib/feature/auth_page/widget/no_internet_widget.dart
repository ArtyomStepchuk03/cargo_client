import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class NoInternetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return FullscreenPlaceholder(
      icon: Icons.cloud_off,
      text: localizationUtil.noInternet,
    );
  }
}
