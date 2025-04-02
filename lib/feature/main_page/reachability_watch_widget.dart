import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/external/reachability.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class ReachabilityWatchWidget extends StatefulWidget {
  final Widget? child;

  ReachabilityWatchWidget({this.child});

  @override
  State<StatefulWidget> createState() => ReachabilityWatchState();
}

class ReachabilityWatchState extends State<ReachabilityWatchWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reachability == null) {
      final dependencyState = DependencyHolder.of(context);
      _reachability = dependencyState?.network.reachability;
      _startWatching();
    }
  }

  @override
  void dispose() {
    _stopWatching();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child!;

  Reachability? _reachability;
  StreamSubscription<bool>? _subscription;

  SnackBar _buildSnackBar() {
    final localizationUtil = LocalizationUtil.of(context);
    return SnackBar(
      content: Text(localizationUtil.noInternet),
      duration: Duration(minutes: 60),
    );
  }

  void _startWatching() {
    _subscription = _reachability?.onStatusChanged?.listen((bool connected) {
      if (connected) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar());
      }
    });
  }

  void _stopWatching() {
    _subscription?.cancel();
  }
}
