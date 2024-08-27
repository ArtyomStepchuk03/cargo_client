import 'live_query_server.dart';
import 'live_query_connection.dart';
import 'live_query_subscription_manager.dart';

export 'live_query_configuration.dart';
export 'live_query_subscription.dart';

class LiveQueryManager {
  factory LiveQueryManager(LiveQueryConfiguration configuration) {
    final server = LiveQueryServer(configuration);
    final connection = LiveQueryConnection(server);
    final subscriptionManager = LiveQuerySubscriptionManager(server, connection);
    return LiveQueryManager._internal(server, connection, subscriptionManager);
  }

  String get sessionToken => _server.sessionToken;
  set sessionToken(String sessionToken) => _server.sessionToken = sessionToken;

  void connect() => _connection.connect();
  void disconnect() => _connection.disconnect();

  LiveQuerySubscription<T> subscribe<T>(QueryBuilder query, ObjectDecodeInitializer<T> initializer) => _subscriptionManager.subscribe(query, initializer);
  void unsubscribe(OpaqueLiveQuerySubscription subscription) => _subscriptionManager.unsubscribe(subscription);

  LiveQuerySubscription<T> subscribeToObjectChanges<T>(String className, String id, ObjectDecodeInitializer<T> initializer) {
    final queryBuilder = QueryBuilder(className);
    queryBuilder.equalTo('objectId', id);
    return subscribe(queryBuilder, initializer);
  }

  final LiveQueryServer _server;
  final LiveQueryConnection _connection;
  final LiveQuerySubscriptionManager _subscriptionManager;

  LiveQueryManager._internal(this._server, this._connection, this._subscriptionManager);
}
