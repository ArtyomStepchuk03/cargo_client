class ConnectionErrorException implements Exception {
  @override
  String toString() => 'ConnectionError';
}

class RequestFailedException implements Exception {
  @override
  String toString() => 'RequestFailed';
}

class InvalidResponseException implements Exception {
  @override
  String toString() => 'InvalidResponse';
}
