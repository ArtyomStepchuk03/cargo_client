abstract class OpaqueLiveQuerySubscription {}

typedef LiveQuerySubscriptionListener<T> = void Function(T object);

abstract class LiveQuerySubscription<T> implements OpaqueLiveQuerySubscription {
  LiveQuerySubscriptionListener<T> onCreate;
  LiveQuerySubscriptionListener<T> onEnter;
  LiveQuerySubscriptionListener<T> onUpdate;
  LiveQuerySubscriptionListener<T> onLeave;
  LiveQuerySubscriptionListener<T> onDelete;

  LiveQuerySubscriptionListener<T> onAdd;
  LiveQuerySubscriptionListener<T> onRemove;
}
