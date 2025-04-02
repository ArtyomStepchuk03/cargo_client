import 'dart:async';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'live_query_configuration.dart';
import 'live_query_message.dart';

export 'live_query_configuration.dart';

abstract class LiveQueryServerConnectionDelegate {
  void onConnect();
  void onError(LiveQueryError? error);
}

abstract class LiveQueryServerSubscriptionDelegate {
  void onSubscribe(int? requestId);
  void onUnsubscribe(int? requestId);

  void onCreate(int? requestId, Map<String, dynamic>? object);
  void onEnter(int? requestId, Map<String, dynamic>? object);
  void onUpdate(int? requestId, Map<String, dynamic>? object);
  void onLeave(int? requestId, Map<String, dynamic>? object);
  void onDelete(int? requestId, Map<String, dynamic>? object);
}

class LiveQueryServer {
  final LiveQueryConfiguration configuration;

  LiveQueryServer(this.configuration);

  String? sessionToken;

  void connect() async {
    _channel = IOWebSocketChannel.connect(configuration.url!);
    _streamSubscription = _channel?.stream.listen(_handleEvent);

    _sendMessage(LiveQueryMessage.connect(
      applicationId: configuration.applicationId,
      clientKey: configuration.clientKey,
      sessionToken: sessionToken,
    ));
  }

  void disconnect() {
    _channel?.sink.close();
    _streamSubscription?.cancel();
  }

  void subscribe(int? requestId, String? className, Map<String, dynamic>? where,
      [List<String>? fields]) {
    _sendMessage(LiveQueryMessage.subscribe(
      requestId: requestId,
      className: className,
      where: where,
      fields: fields,
      sessionToken: sessionToken,
    ));
  }

  void unsubscribe(int requestId) {
    _sendMessage(LiveQueryMessage.unsubscribe(requestId: requestId));
  }

  LiveQueryServerConnectionDelegate? connectionDelegate;
  LiveQueryServerSubscriptionDelegate? subscriptionDelegate;

  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;

  void _sendMessage(Map<String, dynamic> message) {
    final encodedMessage = message.encode();
    _channel?.sink.add(encodedMessage);
  }

  void _handleEvent(dynamic event) {
    final message = LiveQueryMessage.decode(event);
    if (message == null) {
      return;
    }
    final operation = message.operation;
    switch (operation) {
      case 'connected':
        connectionDelegate?.onConnect();
        break;
      case 'error':
        connectionDelegate?.onError(message.error);
        break;

      case 'subscribed':
        subscriptionDelegate?.onSubscribe(message.requestId);
        break;
      case 'unsubscribed':
        subscriptionDelegate?.onUnsubscribe(message.requestId);
        break;

      case 'create':
        subscriptionDelegate?.onCreate(message.requestId, message.object);
        break;
      case 'enter':
        subscriptionDelegate?.onEnter(message.requestId, message.object);
        break;
      case 'update':
        subscriptionDelegate?.onUpdate(message.requestId, message.object);
        break;
      case 'leave':
        subscriptionDelegate?.onLeave(message.requestId, message.object);
        break;
      case 'delete':
        subscriptionDelegate?.onDelete(message.requestId, message.object);
        break;
    }
  }
}
