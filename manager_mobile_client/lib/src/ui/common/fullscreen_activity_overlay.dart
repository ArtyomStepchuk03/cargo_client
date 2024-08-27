import 'package:flutter/material.dart';

class FullscreenActivityOverlay extends StatelessWidget {
  final bool loading;
  final Widget child;

  FullscreenActivityOverlay({this.loading, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Container(
            color: Colors.black.withAlpha(0x88),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
