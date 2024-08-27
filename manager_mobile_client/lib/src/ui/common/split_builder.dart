import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/utility/interface_idiom.dart';

typedef SplitWidgetBuilder = Widget Function(BuildContext context, bool split);

class SplitBuilder extends StatelessWidget {
  final SplitWidgetBuilder builder;

  SplitBuilder({this.builder});

  @override
  Widget build(BuildContext context) {
    bool split = _shouldSplit(context);
    return builder(context, split);
  }

  bool _shouldSplit(BuildContext context) {
    final idiom = getInterfaceIdiom(context);
    if (idiom == InterfaceIdiom.phone) {
      return false;
    }
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }
}
