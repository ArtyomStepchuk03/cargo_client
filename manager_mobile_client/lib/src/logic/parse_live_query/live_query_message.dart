import 'dart:convert';
import 'package:manager_mobile_client/src/logic/core/safe_cast.dart';

class LiveQueryError {
  final int code;
  final String message;
  final bool reconnect;
  LiveQueryError(this.code, this.message, this.reconnect);
}

extension LiveQueryMessage on Map<String, dynamic> {
  String get operation => safeCast<String>(this['op']);
  int get requestId => safeCast<int>(this['requestId']);

  Map<String, dynamic> get object => safeCast<Map<String, dynamic>>(this['object']);

  LiveQueryError get error {
    final code = safeCast<int>(this['code']);
    final message = safeCast<String>(this['error']);
    final reconnect = safeCast<bool>(this['reconnect']);
    if (code == null || message == null || reconnect == null) {
      return null;
    }
    return LiveQueryError(code, message, reconnect);
  }

  static Map<String, dynamic> connect({
    String applicationId,
    String clientKey,
    String sessionToken,
  }) {
    return {
      'op': 'connect',
      'applicationId': applicationId,
      'clientKey': clientKey,
      if (sessionToken != null) 'sessionToken': sessionToken,
    };
  }

  static Map<String, dynamic> subscribe({
    int requestId,
    String className,
    Map<String, dynamic> where,
    List<String> fields,
    String sessionToken,
  }) {
    return {
      'op': 'subscribe',
      'requestId': requestId,
      'query': {
        'className': className,
        'where': where,
        if (fields != null) 'fields': fields,
      },
      if (sessionToken != null) 'sessionToken': sessionToken,
    };
  }

  static Map<String, dynamic> unsubscribe({int requestId}) {
    return {
      'op': 'unsubscribe',
      'requestId': requestId,
    };
  }

  static Map<String, dynamic> decode(dynamic data) {
    if (data is! String) {
      return null;
    }
    final jsonData = json.decode(data);
    if (jsonData is! Map<String, dynamic>) {
      return null;
    }
    final Map<String, dynamic> message = jsonData;
    if (message.operation == null) {
      return null;
    }
    return message;
  }

  String encode() {
    return json.encode(this);
  }
}
