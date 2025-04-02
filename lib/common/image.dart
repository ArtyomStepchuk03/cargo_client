import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class CommonImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final WidgetBuilder errorBuilder;

  CommonImage(this.url,
      {this.width, this.height, this.onTap, required this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Image.network(
        url,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (onTap != null) {
            return GestureDetector(
              onTap: onTap,
              child: child,
            );
          }
          return child;
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return CircularProgressIndicator();
        },
        errorBuilder: (context, exception, stackTrace) => errorBuilder(context),
      ),
    );
  }
}

extension ThumbnailImage on CommonImage {
  static small(BuildContext context, String url,
      {double width = 80, double height = 80, VoidCallback? onTap}) {
    final localizationUtil = LocalizationUtil.of(context);
    return CommonImage(
      url,
      width: width,
      height: height,
      onTap: onTap,
      errorBuilder: (context) {
        return Container(
          decoration: BoxDecoration(border: Border.all()),
          child: Center(
              child: Text(localizationUtil.imageError,
                  textAlign: TextAlign.center)),
        );
      },
    );
  }
}
