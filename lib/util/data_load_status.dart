class DataLoadStatus<R, E> {
  DataLoadStatus.inProgress(this._result, this._exception)
      : _internal = _DataLoadInternalStatus.inProgress;
  DataLoadStatus.succeeded(R result, this._exception)
      : _internal = _DataLoadInternalStatus.succeeded,
        _result = result;
  DataLoadStatus.failed(this._result, [E? exception])
      : _internal = _DataLoadInternalStatus.failed,
        _exception = exception;

  bool get inProgress => _internal == _DataLoadInternalStatus.inProgress;
  bool get succeeded => _internal == _DataLoadInternalStatus.succeeded;
  bool get failed => _internal == _DataLoadInternalStatus.failed;

  R? get result => _result;
  E? get exception => _exception;

  final _DataLoadInternalStatus _internal;
  final R? _result;
  final E? _exception;
}

enum _DataLoadInternalStatus { inProgress, succeeded, failed }
