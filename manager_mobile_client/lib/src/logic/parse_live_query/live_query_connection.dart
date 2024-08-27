import 'live_query_server.dart';
import 'live_query_message.dart';

abstract class LiveQueryConnectionDelegate {
  void onConnect();
  void onDisconnect();
}

class LiveQueryConnection implements LiveQueryServerConnectionDelegate {
  final LiveQueryServer server;

  LiveQueryConnection(this.server);

  void connect() {
    server.connectionDelegate = this;
    print('LiveQuery: Connecting...');
    server.connect();
  }

  void disconnect() {
    server.disconnect();
    _connected = false;
    delegate?.onDisconnect();
  }

  bool get connected => _connected;

  LiveQueryConnectionDelegate delegate;

  void onConnect() {
    print('LiveQuery: Connected.');
    _connected = true;
    delegate?.onConnect();
  }

  void onError(LiveQueryError error) {
    print('LiveQuery: Error ${error.code} (${error.message}, reconnect: ${error.reconnect}).');
  }

  var _connected = false;
}
