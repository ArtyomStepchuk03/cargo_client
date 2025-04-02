import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class Reachability {
  Reachability() : _underlying = Connectivity();

  Future<bool> checkStatus() async {
    final result = await _underlying.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<bool>? get onStatusChanged {
    if (_stream == null) {
      _stream = _underlying.onConnectivityChanged.map(
        (List<ConnectivityResult> results) =>
            results.isNotEmpty &&
            results.any((r) => r != ConnectivityResult.none),
      );
    }
    return _stream;
  }

  final Connectivity _underlying;
  Stream<bool>? _stream;
}
