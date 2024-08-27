import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/button.dart';
import 'package:manager_mobile_client/src/ui/common/fullscreen_placeholder.dart';
import 'authorization_strings.dart' as strings;

class AuthorizationErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  AuthorizationErrorWidget({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FullscreenPlaceholder(
      icon: Icons.error_outline,
      text: strings.logInUnavailable,
      button: buildButton(context,
        onPressed: onRetry,
        child: Text(strings.retry),
      ),
    );
  }
}
