import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/src/logic/external/zoomable_image.dart';

class FullImageWidget extends StatelessWidget {
  final String url;
  final String title;

  FullImageWidget(this.url, {required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: Text(title)),
      body: Center(
        child: ZoomableImage(
          url,
          errorBuilder: (context) {
            return buildFullscreenError(context);
          },
        ),
      ),
    );
  }
}
