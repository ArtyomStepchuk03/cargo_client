import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class AuthorizationErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  AuthorizationErrorWidget({this.onRetry});

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return FullscreenPlaceholder(
      icon: Icons.error_outline,
      text: localizationUtil.logInUnavailable,
      button: buildButton(
        context,
        onPressed: onRetry,
        child: Text(localizationUtil.retryAuth),
      ),
    );
  }
}
