class DataLoadStatus<R, E> {
  DataLoadStatus.inProgress() : _internal = _DataLoadInternalStatus.inProgress;
  DataLoadStatus.succeeded(R result)
      : _internal = _DataLoadInternalStatus.succeeded,
        _result = result;
  DataLoadStatus.failed([E? exception])
      : _internal = _DataLoadInternalStatus.failed,
        _exception = exception;

  bool get inProgress => _internal == _DataLoadInternalStatus.inProgress;
  bool get succeeded => _internal == _DataLoadInternalStatus.succeeded;
  bool get failed => _internal == _DataLoadInternalStatus.failed;

  R? get result => _result;
  E? get exception => _exception;

  _DataLoadInternalStatus? _internal;
  R? _result;
  E? _exception;
}

enum _DataLoadInternalStatus { inProgress, succeeded, failed }
