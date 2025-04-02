import 'package:manager_mobile_client/src/logic/parse/query_builder.dart';

import 'internal_live_query_subscription.dart';
import 'live_query_connection.dart';
import 'live_query_server.dart';
import 'request_identifier_generator.dart';

export 'package:manager_mobile_client/src/logic/coder/decoder.dart';
export 'package:manager_mobile_client/src/logic/parse/query_builder.dart';

export 'live_query_subscription.dart';

class LiveQuerySubscriptionManager
    implements
        LiveQueryConnectionDelegate,
        LiveQueryServerSubscriptionDelegate {
  final LiveQueryServer server;
  final LiveQueryConnection connection;

  LiveQuerySubscriptionManager(this.server, this.connection)
      : _requestIdentifierGenerator = RequestIdentifierGenerator(),
        _activeSubscriptions = {},
        _inactiveSubscriptions = {} {
    connection.delegate = this;
    server.subscriptionDelegate = this;
  }

  LiveQuerySubscription<T?> subscribe<T>(
      QueryBuilder? query, ObjectDecodeInitializer<T?>? initializer) {
    final requestId = _requestIdentifierGenerator.getNext();
    final subscription = LiveQuerySubscriptionImplementation<T?>(
        requestId: requestId,
        className: query?.className,
        where: query?.where,
        initializer: initializer);
    _inactiveSubscriptions[requestId] = subscription;
    if (connection.connected) {
      print(
          'LiveQuery: Subscribing ${query?.className} with id: $requestId...');
      server.subscribe(requestId, subscription.className, subscription.where,
          subscription.fields);
    }
    return subscription;
  }

  void unsubscribe(OpaqueLiveQuerySubscription? subscription) {
    final InternalLiveQuerySubscription internalSubscription = subscription
        as InternalLiveQuerySubscription; // TODO: Костыль! Исправить!
    _activeSubscriptions.remove(internalSubscription.requestId);
    _inactiveSubscriptions.remove(internalSubscription.requestId);
    if (connection.connected) {
      print(
          'LiveQuery: Unsubscribing ${internalSubscription.className} with id: ${internalSubscription.requestId}...');
      server.unsubscribe(internalSubscription.requestId!);
    }
  }

  void onConnect() {
    for (final subscription in _inactiveSubscriptions.values) {
      print(
          'LiveQuery: Subscribing ${subscription.className} with id: ${subscription.requestId}...');
      server.subscribe(subscription.requestId, subscription.className,
          subscription.where, subscription.fields);
    }
  }

  void onDisconnect() {
    _inactiveSubscriptions.addAll(_activeSubscriptions);
    _activeSubscriptions.clear();
  }

  void onSubscribe(int? requestId) {
    print('LiveQuery: Subscribed with id: $requestId.');
    final subscription = _inactiveSubscriptions[requestId];
    if (subscription == null) {
      return;
    }
    _inactiveSubscriptions.remove(requestId);
    _activeSubscriptions[requestId!] = subscription;
  }

  void onUnsubscribe(int? requestId) {
    print('LiveQuery: Unsubscribed id: $requestId.');
  }

  void onCreate(int? requestId, Map<String, dynamic>? object) =>
      _activeSubscriptions[requestId]?.callOnCreate(object);
  void onEnter(int? requestId, Map<String, dynamic>? object) =>
      _activeSubscriptions[requestId]?.callOnEnter(object);
  void onUpdate(int? requestId, Map<String, dynamic>? object) =>
      _activeSubscriptions[requestId]?.callOnUpdate(object);
  void onLeave(int? requestId, Map<String, dynamic>? object) =>
      _activeSubscriptions[requestId]?.callOnLeave(object);
  void onDelete(int? requestId, Map<String, dynamic>? object) =>
      _activeSubscriptions[requestId]?.callOnDelete(object);

  RequestIdentifierGenerator _requestIdentifierGenerator;
  Map<int, InternalLiveQuerySubscription> _activeSubscriptions;
  Map<int, InternalLiveQuerySubscription> _inactiveSubscriptions;
}
