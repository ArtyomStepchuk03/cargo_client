import 'package:flutter/widgets.dart';

enum InterfaceIdiom {
  phone,
  pad
}

InterfaceIdiom getInterfaceIdiom(BuildContext context) {
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  if (shortestSide < 600) {
    return InterfaceIdiom.phone;
  } else {
    return InterfaceIdiom.pad;
  }
}
