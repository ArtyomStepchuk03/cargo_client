import 'package:flutter/material.dart';
import 'network_system.dart';
import 'location_system.dart';
import 'cache_collection.dart';

class DependencyHolder extends StatefulWidget {
  final Widget child;

  DependencyHolder({this.child});

  static DependencyState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_DependencyScopeWidget>().state;
  }

  @override
  State createState() => DependencyState.standard();
}

class DependencyState extends State<DependencyHolder> {
  final NetworkSystem network;
  final LocationSystem location;
  final CacheCollection caches;

  DependencyState(this.network, this.location, this.caches);

  factory DependencyState.standard() {
    final networkSystem = NetworkSystem.standard();
    final locationSystem = LocationSystem.standard();
    final caches = CacheCollection();
    return DependencyState(networkSystem, locationSystem, caches);
  }

  @override
  Widget build(BuildContext context) {
    return _DependencyScopeWidget(
      state: this,
      child: widget.child,
    );
  }
}

class _DependencyScopeWidget extends InheritedWidget {
  final DependencyState state;

  const _DependencyScopeWidget({this.state, Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_DependencyScopeWidget old) => false;
}
