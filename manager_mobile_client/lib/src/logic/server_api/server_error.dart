class CloudFunctionFailedException implements Exception {
  final String error;

  CloudFunctionFailedException(this.error);

  @override
  String toString() => 'CloudFunctionFailed: $error';
}

class ServerError {
  static const notApproved = 'NotApproved';
  static const invalidTripStageForCancel = 'InvalidTripStageForCancel';
  static const noSupplierForArticle = 'NoSupplierForArticle';
  static const cannotCancelByCustomer = 'CannotCancelByCustomer';
}
