import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomableImage extends StatelessWidget {
  final String url;
  final WidgetBuilder errorBuilder;

  ZoomableImage(this.url, {this.errorBuilder});

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: NetworkImage(url),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 4,
      loadingBuilder: (context, event) {
        return CircularProgressIndicator();
      },
      errorBuilder: (context, exception, stackTrace) {
        return errorBuilder(context);
      },
    );
  }
}
