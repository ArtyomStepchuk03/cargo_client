import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/common_strings.dart' as strings;
import 'package:manager_mobile_client/src/ui/common/fullscreen_placeholder.dart';

class NoInternetWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FullscreenPlaceholder(
      icon: Icons.cloud_off,
      text: strings.noInternet,
    );
  }
}
