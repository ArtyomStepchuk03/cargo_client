import 'package:flutter/widgets.dart';

typedef ItemTapCallback<T> = void Function(T item);
typedef ItemSelectCallback<T> = void Function(T item);
typedef ItemConfirmCallback<T> = void Function(T item);

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

typedef Formatter<T> = String Function(T value);

class FilterValue<T> {
  final T underlying;
  FilterValue(this.underlying);
  FilterValue.none() : this(null);
}
