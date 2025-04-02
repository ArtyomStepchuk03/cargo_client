import 'package:flutter/widgets.dart';

String pathForImage(String imageName) => 'assets/images/$imageName.png';

extension ImageUtility on Image {
  static Image named(String name) => Image.asset(pathForImage(name));
}
