import 'package:manager_mobile_client/src/logic/coder/decoder.dart';

import 'live_query_subscription.dart';

export 'package:manager_mobile_client/src/logic/coder/decoder.dart';

export 'live_query_subscription.dart';

abstract class InternalLiveQuerySubscription
    implements OpaqueLiveQuerySubscription {
  int? get requestId;
  String? get className;
  Map<String, dynamic>? get where;
  List<String>? get fields;

  void callOnCreate(Map<String, dynamic>? objectData);
  void callOnEnter(Map<String, dynamic>? objectData);
  void callOnUpdate(Map<String, dynamic>? objectData);
  void callOnLeave(Map<String, dynamic>? objectData);
  void callOnDelete(Map<String, dynamic>? objectData);
}

class LiveQuerySubscriptionImplementation<T>
    implements LiveQuerySubscription<T>, InternalLiveQuerySubscription {
  final int? requestId;
  final String? className;
  final Map<String, dynamic>? where;
  final List<String>? fields;
  final ObjectDecodeInitializer<T>? initializer;

  LiveQuerySubscriptionImplementation(
      {this.requestId,
      this.className,
      this.where,
      this.fields,
      this.initializer});

  LiveQuerySubscriptionListener<T>? onCreate;
  LiveQuerySubscriptionListener<T>? onEnter;
  LiveQuerySubscriptionListener<T>? onUpdate;
  LiveQuerySubscriptionListener<T>? onLeave;
  LiveQuerySubscriptionListener<T>? onDelete;

  LiveQuerySubscriptionListener<T>? onAdd;
  LiveQuerySubscriptionListener<T>? onRemove;

  void callOnCreate(Map<String, dynamic>? objectData) {
    print(
        'LiveQuery: On create: ${objectData?['className']} ${objectData?['objectId']}.');
    final object = initializer!(Decoder(objectData));
    if (onCreate != null) onCreate!(object);
    if (onAdd != null) onAdd!(object);
  }

  void callOnEnter(Map<String, dynamic>? objectData) {
    print(
        'LiveQuery: On enter: ${objectData?['className']} ${objectData?['objectId']}.');
    final object = initializer!(Decoder(objectData));
    if (onEnter != null) onEnter!(object);
    if (onAdd != null) onAdd!(object);
  }

  void callOnUpdate(Map<String, dynamic>? objectData) {
    print(
        'LiveQuery: On update: ${objectData?['className']} ${objectData?['objectId']}.');
    if (onUpdate == null) return;
    onUpdate!(initializer!(Decoder(objectData)));
  }

  void callOnLeave(Map<String, dynamic>? objectData) {
    print(
        'LiveQuery: On leave: ${objectData?['className']} ${objectData?['objectId']}.');
    final object = initializer!(Decoder(objectData));
    if (onLeave != null) onLeave!(object);
    if (onRemove != null) onRemove!(object);
  }

  void callOnDelete(Map<String, dynamic>? objectData) {
    print(
        'LiveQuery: On delete: ${objectData?['className']} ${objectData?['objectId']}.');
    final object = initializer!(Decoder(objectData));
    if (onDelete != null) onDelete!(object);
    if (onRemove != null) onRemove!(object);
  }
}
